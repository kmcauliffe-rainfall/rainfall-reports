# CMS Hospital Readmissions Reduction Program (HRRP) condition-level analysis.
#
# Source: CMS Provider Data Catalog dataset 9n3s-kdb3, pulled through the
# metastore API (dataset id -> distribution downloadURL -> CSV), cached to
# data/cache/ so a render survives a CMS outage or an offline machine.
#
# Hospitals are joined to the TEAM roster on CMS Certification Number, so the
# comparison is exact -- no hospital-name matching and no unmatched residual.
#
# What the file supports: condition-level Excess Readmission Ratios (ERR), the
# ratio of predicted to expected 30-day readmissions for a hospital's case mix.
# ERR > 1.00 means more readmissions than the risk-adjusted expectation.
# What it does not support: CMS's actual HRRP payment-adjustment factor, which
# is calculated from inputs not published in this file. Nothing here should be
# described as a penalty rate.

HRRP_DATASET_ID <- "9n3s-kdb3"

HRRP_CONDITIONS <- tibble::tribble(
  ~measure,                  ~condition,            ~cohort,
  "READM-30-HIP-KNEE-HRRP",  "Hip/knee replacement", "TEAM surgical",
  "READM-30-CABG-HRRP",      "CABG",                 "TEAM surgical",
  "READM-30-AMI-HRRP",       "Heart attack (AMI)",   "Medical",
  "READM-30-HF-HRRP",        "Heart failure",        "Medical",
  "READM-30-PN-HRRP",        "Pneumonia",            "Medical",
  "READM-30-COPD-HRRP",      "COPD",                 "Medical"
)

hrrp_meta_url <- function() {
  paste0(
    "https://data.cms.gov/provider-data/api/1/metastore/schemas/dataset/items/",
    HRRP_DATASET_ID, "?show-reference-ids=false"
  )
}

hrrp_cache_dir <- function() file.path(DATA_DIR, "cache")
hrrp_cache_csv <- function() file.path(hrrp_cache_dir(), "hrrp_live.csv")
hrrp_cache_meta <- function() file.path(hrrp_cache_dir(), "hrrp_live_meta.json")

# "NA" is included because write.csv serialises missing values that way; without
# it the cached re-read returns the ERR column as character.
HRRP_NA_STRINGS <- c("N/A", "NA", "", " ")

#' Fetch the HRRP file, preferring a cache newer than `cache_days`.
fetch_hrrp <- function(cache_days = 30) {
  dir.create(hrrp_cache_dir(), showWarnings = FALSE, recursive = TRUE)

  cache_age_days <- if (file.exists(hrrp_cache_csv())) {
    as.numeric(Sys.time() - file.info(hrrp_cache_csv())$mtime, units = "days")
  } else {
    Inf
  }

  if (cache_age_days >= cache_days) {
    live <- tryCatch(
      {
        meta <- jsonlite::fromJSON(hrrp_meta_url())
        download_url <- meta$distribution$data$downloadURL
        csv <- utils::read.csv(
          download_url,
          na.strings = HRRP_NA_STRINGS,
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
        utils::write.csv(csv, hrrp_cache_csv(), row.names = FALSE)
        jsonlite::write_json(
          list(
            dataset_id = HRRP_DATASET_ID,
            source_url = download_url,
            dataset_modified = meta$modified %||% NA_character_,
            fetched_at = as.character(Sys.time())
          ),
          hrrp_cache_meta(),
          auto_unbox = TRUE
        )
        csv
      },
      error = function(e) NULL
    )
    if (!is.null(live)) return(list(data = live, status = "live"))
  }

  if (file.exists(hrrp_cache_csv())) {
    cached <- utils::read.csv(
      hrrp_cache_csv(),
      na.strings = HRRP_NA_STRINGS,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    return(list(data = cached, status = "cached"))
  }

  list(data = NULL, status = "unavailable")
}

hrrp_summary_csv <- function() file.path(DATA_DIR, "hrrp_condition_summary.csv")
hrrp_summary_meta <- function() file.path(DATA_DIR, "hrrp_condition_summary_source.json")

#' Compute the profile from the full CMS file and vendor the derived summary.
#' Run deliberately, like refresh_team_roster(): the published numbers then
#' change only through a reviewable diff, never silently between renders.
refresh_hrrp_summary <- function(ccns, scope_label = "California TEAM hospitals") {
  profile <- compute_hrrp_profile(ccns)
  if (identical(profile$status, "unavailable")) {
    stop("Could not reach the CMS HRRP file and no cached copy is available.")
  }

  utils::write.csv(profile$by_condition, hrrp_summary_csv(), row.names = FALSE, na = "")
  jsonlite::write_json(
    profile[c(
      "dataset_id", "dataset_modified", "period_start", "period_end",
      "scope_hospitals_total", "scope_hospitals_in_file",
      "scope_mean_err", "national_mean_err", "national_hospitals"
    )] |>
      c(list(
        scope_label = scope_label,
        source_url = paste0("https://data.cms.gov/provider-data/dataset/", HRRP_DATASET_ID),
        refreshed_at = as.character(Sys.Date())
      )),
    hrrp_summary_meta(),
    auto_unbox = TRUE
  )
  invisible(profile)
}

#' Read the vendored summary back in the shape the figures and report expect.
load_hrrp_summary <- function() {
  if (!file.exists(hrrp_summary_csv()) || !file.exists(hrrp_summary_meta())) {
    stop(
      "Missing vendored HRRP summary. Regenerate it with:\n",
      "  refresh_hrrp_summary(load_team_hospitals('CA')$ccn)"
    )
  }
  by_condition <- utils::read.csv(hrrp_summary_csv(), stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    dplyr::mutate(condition = factor(condition, levels = HRRP_CONDITIONS$condition))
  meta <- jsonlite::fromJSON(hrrp_summary_meta())
  c(list(status = "vendored", by_condition = by_condition), meta)
}

#' Condition-level readmission profile for a set of hospitals (by CCN),
#' benchmarked against every hospital in the national HRRP file.
compute_hrrp_profile <- function(ccns) {
  fetched <- fetch_hrrp()
  required <- c("Facility ID", "Measure Name", "Excess Readmission Ratio", "Start Date", "End Date")
  if (is.null(fetched$data) || !all(required %in% names(fetched$data))) {
    return(list(status = "unavailable"))
  }

  clean <- fetched$data |>
    dplyr::rename(
      ccn = `Facility ID`,
      measure = `Measure Name`,
      err = `Excess Readmission Ratio`
    ) |>
    dplyr::mutate(ccn = pad_ccn(ccn)) |>
    dplyr::filter(!is.na(err))

  ccns <- pad_ccn(ccns)
  scoped <- dplyr::filter(clean, ccn %in% ccns)

  by_condition <- HRRP_CONDITIONS |>
    dplyr::left_join(
      scoped |>
        dplyr::group_by(measure) |>
        dplyr::summarise(
          scope_err = mean(err),
          scope_above = 100 * mean(err > 1),
          scope_n = dplyr::n(),
          .groups = "drop"
        ),
      by = "measure"
    ) |>
    dplyr::left_join(
      clean |>
        dplyr::group_by(measure) |>
        dplyr::summarise(
          national_err = mean(err),
          national_above = 100 * mean(err > 1),
          national_n = dplyr::n(),
          .groups = "drop"
        ),
      by = "measure"
    ) |>
    dplyr::mutate(
      gap = scope_err - national_err,
      condition = factor(condition, levels = HRRP_CONDITIONS$condition)
    )

  release <- if (file.exists(hrrp_cache_meta())) {
    jsonlite::fromJSON(hrrp_cache_meta())
  } else {
    list()
  }

  list(
    status = fetched$status,
    by_condition = by_condition,
    scope_hospitals_in_file = dplyr::n_distinct(scoped$ccn),
    scope_hospitals_total = length(unique(ccns)),
    scope_mean_err = mean(scoped$err),
    national_mean_err = mean(clean$err),
    national_hospitals = dplyr::n_distinct(clean$ccn),
    # Parse before comparing: these are mm/dd/yyyy strings, so a plain min()
    # would order them lexicographically rather than chronologically.
    period_start = format(
      min(as.Date(fetched$data$`Start Date`, format = "%m/%d/%Y"), na.rm = TRUE),
      "%m/%d/%Y"
    ),
    period_end = format(
      max(as.Date(fetched$data$`End Date`, format = "%m/%d/%Y"), na.rm = TRUE),
      "%m/%d/%Y"
    ),
    dataset_id = HRRP_DATASET_ID,
    dataset_modified = release$dataset_modified %||% NA_character_,
    fetched_at = release$fetched_at %||% NA_character_
  )
}
