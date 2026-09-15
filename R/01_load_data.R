# Load the CMS TEAM participant roster.
#
# Preferred source is the vendored parse of the CMS participant list
# (data/team_participant_list.csv), which carries each hospital's CCN and so
# supports exact joins to other CMS datasets. The older name-and-CBSA JSON
# extract remains as a fallback for environments where the CSV is absent.

# Participant-list helpers live in 06_cms_roster.R. Source them here so this
# file works standalone for callers that don't go through R/report.R.
if (!exists("team_roster_csv")) {
  source(file.path(REPO_ROOT, "R", "06_cms_roster.R"))
}

hospitals_json_path <- function() {
  path <- file.path(DATA_DIR, "territoryHospitals.json")
  if (!file.exists(path)) {
    stop("Missing data/territoryHospitals.json")
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

flatten_roster_json <- function(path = hospitals_json_path()) {
  raw <- jsonlite::fromJSON(path, simplifyVector = FALSE)
  rows <- list()
  for (st in names(raw)) {
    block <- raw[[st]]
    if (!is.list(block)) next
    for (tier in names(block)) {
      for (h in block[[tier]]) {
        rows[[length(rows) + 1]] <- list(
          hospital = h$name,
          cbsa = h$cbsa,
          state = st
        )
      }
    }
  }
  dplyr::bind_rows(rows) |>
    dplyr::mutate(
      # Columns the participant-list CSV carries, kept here as NA so both
      # roster sources present the same schema to downstream code.
      ccn = NA_character_,
      participation = NA_character_,
      start_date = NA_character_,
      end_date = NA_character_,
      newly_identified = NA_character_,
      cbsa_label = cbsa_display_name(cbsa),
      source_file = basename(path),
      roster_label = "CMS TEAM participant list (repo JSON extract)"
    )
}

flatten_roster <- function(path = NULL) {
  if (!is.null(path)) return(flatten_roster_json(path))
  if (file.exists(team_roster_csv())) {
    prov <- team_roster_provenance()
    label <- prov$list_label %||% "CMS TEAM participant list"
    return(
      load_team_roster() |>
        dplyr::select(
          hospital, cbsa, cbsa_label, state, ccn, participation,
          start_date, end_date, newly_identified
        ) |>
        dplyr::mutate(
          source_file = basename(team_roster_csv()),
          roster_label = label
        )
    )
  }
  flatten_roster_json()
}

load_team_hospitals <- function(states, path = NULL) {
  states <- toupper(states)
  flatten_roster(path) |>
    dplyr::filter(.data$state %in% states)
}

load_territories <- function() {
  jsonlite::fromJSON(file.path(DATA_DIR, "territories.json"), simplifyVector = TRUE)
}

load_territory_hospitals <- function(territory_id, path = NULL) {
  defs <- load_territories()
  spec <- defs[[territory_id]]
  if (is.null(spec)) stop("Unknown territory: ", territory_id)
  all_h <- flatten_roster(path)
  ca_cbsas <- spec$ca_cbsas
  if (is.null(ca_cbsas)) ca_cbsas <- character()
  dplyr::filter(
    all_h,
    .data$state %in% spec$states |
      (.data$state == "CA" & .data$cbsa %in% ca_cbsas)
  )
}

editorial_for <- function(key) {
  ed <- jsonlite::fromJSON(file.path(DATA_DIR, "editorial.json"), simplifyVector = TRUE)
  row <- ed[[key]]
  if (is.null(row)) {
    list(
      medicare = "See guide",
      hrrp = "See guide",
      lejr = "See guide",
      why_hospitals = "TEAM roster"
    )
  } else {
    as.list(row)
  }
}

NATIONAL_TOTAL <- nrow(flatten_roster())
