# CMS TEAM participant list (CCN-keyed).
#
# The participant list is the authoritative roster: it carries each hospital's
# CMS Certification Number (CCN), which lets every other CMS dataset be joined
# exactly rather than by hospital name. CMS republishes the file quarterly at
# https://www.cms.gov/team-model-participant-list as an .xlsx.
#
# A parsed copy is vendored to data/team_participant_list.csv so reports render
# reproducibly offline; refresh_team_roster() re-pulls and rewrites it.

TEAM_PARTICIPANT_URL <- "https://www.cms.gov/team-model-participant-list"

team_roster_csv <- function() file.path(DATA_DIR, "team_participant_list.csv")
team_roster_meta <- function() file.path(DATA_DIR, "team_participant_list_source.json")

#' Pad a CMS Certification Number back to six characters. CCNs are strings
#' with meaningful leading zeros, but CSV readers parse them as integers.
pad_ccn <- function(x) {
  x <- trimws(as.character(x))
  numeric_only <- grepl("^[0-9]+$", x)
  x[numeric_only] <- formatC(
    as.numeric(x[numeric_only]),
    width = 6, format = "d", flag = "0"
  )
  x
}

#' Minimal .xlsx reader: unzip the package and walk the sheet XML with xml2.
#' Avoids adding readxl/openxlsx to the dependency set for a single file.
read_xlsx_sheet <- function(path, sheet = 1L) {
  exdir <- file.path(tempdir(), paste0("xlsx-", as.integer(Sys.time())))
  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)
  utils::unzip(path, exdir = exdir)

  shared <- character()
  shared_path <- file.path(exdir, "xl", "sharedStrings.xml")
  if (file.exists(shared_path)) {
    doc <- xml2::read_xml(shared_path)
    xml2::xml_ns_strip(doc)
    shared <- vapply(
      xml2::xml_find_all(doc, "//si"),
      function(node) paste0(xml2::xml_text(xml2::xml_find_all(node, ".//t")), collapse = ""),
      character(1)
    )
  }

  sheet_path <- file.path(exdir, "xl", "worksheets", paste0("sheet", sheet, ".xml"))
  doc <- xml2::read_xml(sheet_path)
  xml2::xml_ns_strip(doc)

  rows <- lapply(xml2::xml_find_all(doc, "//row"), function(row) {
    cells <- xml2::xml_find_all(row, "c")
    if (length(cells) == 0) return(NULL)
    refs <- gsub("[0-9]", "", xml2::xml_attr(cells, "r"))
    types <- xml2::xml_attr(cells, "t")
    vals <- vapply(cells, function(c) {
      v <- xml2::xml_find_first(c, "v")
      if (inherits(v, "xml_missing")) NA_character_ else xml2::xml_text(v)
    }, character(1))
    is_shared <- !is.na(types) & types == "s" & !is.na(vals)
    vals[is_shared] <- shared[as.integer(vals[is_shared]) + 1L]
    stats::setNames(vals, refs)
  })
  rows[!vapply(rows, is.null, logical(1))]
}

#' Pull the current participant list from CMS and return it as a tibble.
fetch_team_roster_live <- function() {
  tmp <- tempfile(fileext = ".xlsx")
  on.exit(unlink(tmp), add = TRUE)
  utils::download.file(TEAM_PARTICIPANT_URL, tmp, mode = "wb", quiet = TRUE)

  rows <- read_xlsx_sheet(tmp)
  header_idx <- which(vapply(rows, function(r) any(r %in% "Hospital CCN"), logical(1)))[1]
  if (is.na(header_idx)) stop("Participant list layout changed: no 'Hospital CCN' header row.")

  header <- rows[[header_idx]]
  body <- rows[seq(header_idx + 1L, length(rows))]
  cols <- names(header)

  pull_col <- function(name) {
    col <- names(header)[match(name, header)]
    vapply(body, function(r) {
      v <- r[[col]]
      if (is.null(v) || length(v) == 0) NA_character_ else as.character(v)
    }, character(1))
  }

  tibble::tibble(
    participation = pull_col("Mandatory or Voluntary Participant"),
    ccn = pad_ccn(pull_col("Hospital CCN")),
    hospital = pull_col("Hospital Name"),
    cbsa_code = pull_col("CBSA"),
    cbsa = pull_col("CBSA Name"),
    state = pull_col("CBSA State"),
    start_date = pull_col("Participation Start Date"),
    end_date = pull_col("Participation End Date"),
    newly_identified = pull_col("Newly Identified TEAM Participant Relative to Previous List")
  ) |>
    dplyr::filter(!is.na(ccn), !is.na(state))
}

#' Refresh the vendored copy from CMS. Run deliberately, not at render time,
#' so a report never changes its numbers because of an unreviewed CMS update.
refresh_team_roster <- function(list_label = NULL) {
  roster <- fetch_team_roster_live()
  utils::write.csv(roster, team_roster_csv(), row.names = FALSE, na = "")
  jsonlite::write_json(
    list(
      source_url = TEAM_PARTICIPANT_URL,
      list_label = list_label %||% NA_character_,
      hospitals = nrow(roster),
      states = length(unique(roster$state)),
      retrieved_at = as.character(Sys.Date())
    ),
    team_roster_meta(),
    auto_unbox = TRUE
  )
  invisible(roster)
}

#' Load the vendored participant list.
load_team_roster <- function() {
  path <- team_roster_csv()
  if (!file.exists(path)) stop("Missing vendored participant list: ", path)
  utils::read.csv(path, colClasses = "character", check.names = FALSE) |>
    tibble::as_tibble() |>
    dplyr::mutate(
      ccn = pad_ccn(ccn),
      cbsa_label = cbsa_display_name(cbsa)
    )
}

team_roster_provenance <- function() {
  path <- team_roster_meta()
  if (!file.exists(path)) return(list())
  jsonlite::fromJSON(path)
}
