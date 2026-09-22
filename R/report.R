# Orchestrate a report. Set REPORT_KIND and REPORT_ID before sourcing.

.report_repo_root <- function() {
  d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  for (i in 1:6) {
    if (file.exists(file.path(d, "data", "territoryHospitals.json"))) {
      return(d)
    }
    parent <- dirname(d)
    if (identical(parent, d)) {
      break
    }
    d <- parent
  }
  stop("Could not find rainfall-reports repo root (data/territoryHospitals.json).")
}

.r_dir <- file.path(.report_repo_root(), "R")
source(file.path(.r_dir, "00_setup.R"))
source(file.path(.r_dir, "06_cms_roster.R"))
source(file.path(.r_dir, "01_load_data.R"))
source(file.path(.r_dir, "02_charts.R"))
source(file.path(.r_dir, "03_readmission_figures.R"))
source(file.path(.r_dir, "05_cms_hrrp.R"))
source(file.path(.r_dir, "ca_system_rollup.R"))

if (!exists("REPORT_KIND") || !exists("REPORT_ID")) {
  stop("Set REPORT_KIND ('state' or 'territory') and REPORT_ID before sourcing R/report.R")
}

if (identical(REPORT_KIND, "state")) {
  hospitals <- load_team_hospitals(REPORT_ID)
} else if (identical(REPORT_KIND, "territory")) {
  hospitals <- load_territory_hospitals(REPORT_ID)
} else {
  stop("REPORT_KIND must be 'state' or 'territory'")
}

ca_mode <- identical(REPORT_KIND, "state") && identical(REPORT_ID, "CA")
meta <- prepare_report_tables(hospitals, REPORT_KIND, ca_mode = ca_mode)
hospitals <- meta$hospitals
cbsa_table <- meta$cbsa_table
state_table <- meta$state_table
region_table <- meta$region_table
SCOPE_N <- meta$n
SCOPE_CBSA_N <- meta$cbsa_n
SCOPE_STATE_N <- meta$state_n
top_cbsa <- meta$top_cbsa
top_cbsa_n <- meta$top_cbsa_n
editorial <- editorial_for(REPORT_ID)

sf_n <- NA_integer_
riverside_n <- NA_integer_
bay_inland_n <- NA_integer_
bay_inland_share <- NA_integer_
reconciliation_note <- ""

ca_system_rollup <- NULL
if (ca_mode) {
  rec <- ca_reconciliation(meta)
  sf_n <- rec$sf_n
  riverside_n <- rec$riverside_n
  bay_inland_n <- rec$bay_inland_n
  bay_inland_share <- rec$bay_inland_share
  reconciliation_note <- rec$note
  CA_TOTAL <- SCOPE_N
  CA_CBSA_N <- SCOPE_CBSA_N
  ca_system_rollup <- compute_ca_system_rollup(hospitals, scope_n = SCOPE_N)
}

build_fig1_fig2(meta, REPORT_KIND)

# Condition-level readmission analysis. Read from the vendored summary that
# refresh_hrrp_summary() produces, so a render never depends on network access
# and never changes its published numbers without a reviewed data refresh.
hrrp <- list(status = "unavailable")
if (ca_mode) {
  hrrp <- load_hrrp_summary()
  build_readmission_figs(hrrp)
}

logo_path <- rel_asset("rainfall-logo.png")
ca_sil_path <- rel_asset("california-silhouette.svg")
