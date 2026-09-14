# Load CMS TEAM participant roster (March 2026 extract used sitewide).

hospitals_json_path <- function() {
  path <- file.path(DATA_DIR, "territoryHospitals.json")
  if (!file.exists(path)) {
    stop("Missing data/territoryHospitals.json")
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

flatten_roster <- function(path = hospitals_json_path()) {
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
          tier = tier,
          state = st
        )
      }
    }
  }
  dplyr::bind_rows(rows) |>
    dplyr::mutate(
      cbsa_label = cbsa_display_name(cbsa),
      source_file = basename(path),
      roster_label = "CMS TEAM participant list (repo extract: March 2026)"
    )
}

load_team_hospitals <- function(states, path = hospitals_json_path()) {
  states <- toupper(states)
  flatten_roster(path) |>
    dplyr::filter(.data$state %in% states)
}

load_territories <- function() {
  jsonlite::fromJSON(file.path(DATA_DIR, "territories.json"), simplifyVector = TRUE)
}

load_territory_hospitals <- function(territory_id, path = hospitals_json_path()) {
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
