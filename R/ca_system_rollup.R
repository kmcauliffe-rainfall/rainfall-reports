# California TEAM roster: health-system concentration from a vendored CCN map.
#
# System labels are assigned from hospital names on the CMS participant list and
# checked against public system branding. Independent hospitals are omitted from
# system counts; hospitals in systems with two or more TEAM sites in California
# are counted toward multi_system_hospital_n.

ca_system_affiliations_path <- function() {
  file.path(DATA_DIR, "ca_team_system_affiliations.csv")
}

# Multi-state investor-owned chains that rebrand hospitals under local names,
# so the chain's own name never appears in the CMS-registered hospital name
# and name-regex matching in ca_system_label_from_name() cannot find them.
# Verified hospital-by-hospital against public ownership records (Sept 2026
# review); see essays/rainfall-team-cjrx-research/data/ownership-concentration-findings.md
# for the source per hospital. Checked before the name-based fallback below.
CA_SYSTEM_CCN_OVERRIDES <- c(
  "050022" = "HCA Healthcare",
  "050586" = "Prime Healthcare",
  "050709" = "Prime Healthcare",
  "050758" = "Prime Healthcare",
  "050024" = "Prime Healthcare",
  "050329" = "Southwest Healthcare (UHS)",
  "050701" = "Southwest Healthcare (UHS)",
  "050775" = "Southwest Healthcare (UHS)",
  "050390" = "KPC Health",
  "050684" = "KPC Health",
  "050517" = "KPC Health"
)

#' Assign a system label from a Medicare hospital name (California TEAM roster).
ca_system_label_from_name <- function(hospital_name) {
  n <- toupper(trimws(as.character(hospital_name)))
  if (grepl("^KAISER ", n)) return("Kaiser Permanente")
  if (grepl(
    "SUTTER|ALTA BATES|MILLS-PENINSULA|CALIFORNIA PACIFIC|EDEN MED|SEQUOIA HOSP|NOVATO COMMUNITY|MARINHEALTH",
    n
  )) {
    return("Sutter Health")
  }
  if (grepl("PROVIDENCE", n)) return("Providence")
  if (grepl("ADVENTIST", n)) return("Adventist Health")
  if (grepl("^SHARP ", n)) return("Sharp HealthCare")
  if (grepl("SCRIPPS", n)) return("Scripps Health")
  if (grepl("^UCSF|^UC SAN DIEGO", n)) return("University of California")
  if (grepl("STANFORD", n)) return("Stanford Medicine")
  if (grepl("JOHN MUIR", n)) return("John Muir Health")
  if (grepl("EL CAMINO", n)) return("El Camino Health")
  if (grepl("PALOMAR", n)) return("Palomar Health")
  if (grepl("LOMA LINDA", n)) return("Loma Linda University Health")
  NA_character_
}

#' Build or refresh the vendored CCN → system map for California TEAM hospitals.
refresh_ca_system_affiliations <- function(hospitals = load_team_hospitals("CA")) {
  rows <- lapply(seq_len(nrow(hospitals)), function(i) {
    ccn <- hospitals$ccn[i]
    override_label <- unname(CA_SYSTEM_CCN_OVERRIDES[ccn])
    if (!is.na(override_label)) {
      label <- override_label
      source_note <- "CCN-verified ownership override — name-regex matching misses chains that rebrand hospitals locally (Sept 2026 review)"
    } else {
      label <- ca_system_label_from_name(hospitals$hospital[i])
      source_note <- "Hospital name on CMS TEAM participant list matched to public system branding (Sept 2026 review)"
    }
    system_id <- if (is.na(label)) {
      "independent"
    } else {
      gsub("[^a-z0-9]+", "_", tolower(label))
    }
    system_label <- if (is.na(label)) "Independent / other" else label
    tibble::tibble(
      ccn = ccn,
      hospital = hospitals$hospital[i],
      system_id = system_id,
      system_label = system_label,
      source_note = source_note
    )
  })
  out <- dplyr::bind_rows(rows)
  utils::write.csv(out, ca_system_affiliations_path(), row.names = FALSE, na = "")
  invisible(out)
}

load_ca_system_affiliations <- function() {
  path <- ca_system_affiliations_path()
  if (!file.exists(path)) {
    refresh_ca_system_affiliations()
  }
  utils::read.csv(path, colClasses = "character", stringsAsFactors = FALSE) |>
    tibble::as_tibble()
}

#' Roll up multi-hospital system concentration for California prose.
compute_ca_system_rollup <- function(hospitals, scope_n = nrow(hospitals)) {
  aff <- load_ca_system_affiliations()
  joined <- hospitals |>
    dplyr::left_join(
      aff |> dplyr::select(ccn, system_id, system_label),
      by = "ccn"
    )
  by_system <- joined |>
    dplyr::filter(system_id != "independent") |>
    dplyr::count(system_label, name = "hospitals", sort = TRUE)

  multi_system_hospital_n <- by_system |>
    dplyr::filter(hospitals >= 2L) |>
    dplyr::summarise(n = sum(hospitals), .groups = "drop") |>
    dplyr::pull(n)
  if (length(multi_system_hospital_n) == 0 || is.na(multi_system_hospital_n)) {
    multi_system_hospital_n <- 0L
  }

  largest_row <- by_system |> dplyr::slice_head(n = 1)
  largest_system_label <- largest_row$system_label %||% "—"
  largest_system_n <- as.integer(largest_row$hospitals %||% 0L)
  largest_system_pct <- if (scope_n > 0) {
    round(100 * largest_system_n / scope_n, 0)
  } else {
    0L
  }
  multi_system_system_n <- sum(by_system$hospitals >= 2L)

  list(
    affiliations = aff,
    by_system = by_system,
    multi_system_hospital_n = as.integer(multi_system_hospital_n),
    multi_system_system_n = as.integer(multi_system_system_n),
    largest_system_label = largest_system_label,
    largest_system_n = largest_system_n,
    largest_system_pct = largest_system_pct
  )
}
