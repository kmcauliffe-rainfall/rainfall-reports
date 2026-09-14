# Orchestrate a report. Set REPORT_KIND and REPORT_ID before sourcing.

source("../../R/00_setup.R")
source("../../R/01_load_data.R")
source("../../R/02_charts.R")
source("../../R/03_exposure_figures.R")
source("../../R/04_hrrp_figures.R")

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

if (ca_mode) {
  rec <- ca_reconciliation(meta)
  sf_n <- rec$sf_n
  riverside_n <- rec$riverside_n
  bay_inland_n <- rec$bay_inland_n
  bay_inland_share <- rec$bay_inland_share
  reconciliation_note <- rec$note
  CA_TOTAL <- SCOPE_N
  CA_CBSA_N <- SCOPE_CBSA_N
}

build_fig1_fig2(meta, REPORT_KIND)
if (ca_mode) {
  build_fig3()
  build_fig4()
}

logo_path <- file.path("..", "..", "assets", "rainfall-logo.png")
ca_sil_path <- file.path("..", "..", "assets", "california-silhouette.svg")
