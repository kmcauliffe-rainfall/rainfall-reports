# Compute CMS TEAM Impact Report metrics from vendored raw files.

impact_report_dir <- function() {
  d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  for (i in 1:8) {
    if (file.exists(file.path(d, "data", "team_participant_list.xlsx"))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) break
    d <- parent
  }
  stop("Could not locate reports/cms-team-impact root")
}

compute_impact_metrics <- function(root = impact_report_dir()) {
  data_dir <- file.path(root, "data")
  src_hcup <- file.path(root, "sources", "hcup", "sb281-operating-room-procedures-2018.pdf")

  source(file.path(root, "R", "impact_xlsx.R"), local = TRUE)

  roster <- read_team_roster_xlsx(file.path(data_dir, "team_participant_list.xlsx"))
  cjrx_ccns <- read_cjrx_roster_xlsx(file.path(data_dir, "cjrx_participant_list.xlsx"))
  prices <- read_target_prices(file.path(data_dir, "team_py1_prelim_target_prices.xlsx"))

  ca <- roster[roster$state == "CA", , drop = FALSE]
  n_team <- nrow(roster)
  n_ca <- nrow(ca)
  n_ca_cbsa <- length(unique(ca$cbsa))
  n_cjrx <- length(cjrx_ccns)

  drg331 <- prices[prices$drg == "331", , drop = FALSE]
  drg426 <- prices[prices$drg == "426", , drop = FALSE]
  tp_min_331 <- min(drg331$target_price)
  tp_max_426 <- max(drg426$target_price)

  track3_cap_pct <- 20

  census_path <- file.path(data_dir, "census_np2023_t2.xlsx")
  census_grid <- read_xlsx_grid(census_path, 1L)
  pop_2030 <- as.numeric(census_grid[["D16"]]) * 1000
  pop_2050 <- as.numeric(census_grid[["H16"]]) * 1000
  if (is.na(pop_2030)) stop("Census Table 2 layout changed (65+ / 2030 cell D16)")

  hcup_json <- file.path(data_dir, "hcup_or_stay_age_shares.json")
  if (!file.exists(hcup_json)) {
    system2("python3", file.path(root, "scripts", "extract_hcup_figure2_shares.py"))
  }
  hcup <- jsonlite::fromJSON(hcup_json)
  pct_65_74 <- hcup$pct_65_74_with_or
  pct_75plus <- hcup$pct_75_plus_with_or
  pct_surgical_stays_65plus <- hcup$pct_65_plus_with_or

  list(
    n_team = n_team,
    n_ca = n_ca,
    n_ca_cbsa = n_ca_cbsa,
    n_cjrx = n_cjrx,
    tp_min_331 = tp_min_331,
    tp_max_426 = tp_max_426,
    track3_cap_pct = track3_cap_pct,
    pop_2030 = pop_2030,
    pop_2050 = pop_2050,
    pct_surgical_stays_65plus = pct_surgical_stays_65plus,
    roster_retrieved = jsonlite::fromJSON(file.path(data_dir, "sources.json"))$retrieved
  )
}
