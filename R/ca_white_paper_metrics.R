# Metrics, formatters, and narration export for states/california/california.qmd.

participation_n <- function(hospitals, level) {
  counts <- table(hospitals$participation)
  val <- unname(counts[level])
  if (length(val) == 0 || is.na(val)) 0L else as.integer(val)
}

pretty_date <- function(x) {
  format(as.Date(x, format = "%m/%d/%Y"), "%B %e, %Y") |>
    trimws() |>
    gsub(pattern = "  ", replacement = " ")
}

pretty_month <- function(x) {
  format(as.Date(x, format = "%m/%d/%Y"), "%B %Y")
}

cbsa_hospitals <- function(cbsa_table, pattern) {
  idx <- grep(pattern, cbsa_table$cbsa_label, ignore.case = TRUE)[1]
  if (is.na(idx)) NA_integer_ else as.integer(cbsa_table$hospitals[idx])
}

#' Compute every inline figure and write california-narration.txt.
compute_ca_white_paper_metrics <- function(
    hospitals,
    hrrp,
    cbsa_table,
    region_table,
    report_dir = getwd(),
    system_rollup = NULL) {
  roster_prov <- team_roster_provenance()
  roster_label <- roster_prov$list_label %||% "CMS TEAM participant list"

  mandatory_n <- participation_n(hospitals, "Mandatory")
  voluntary_n <- participation_n(hospitals, "Voluntary")
  national_share <- round(100 * SCOPE_N / NATIONAL_TOTAL, 1)

  ranks <- cbsa_national_ranks(c(
    "San Francisco-Oakland-Fremont, CA",
    "Riverside-San Bernardino-Ontario, CA"
  ))
  sf_rank <- ranks$rank[1]
  riverside_rank <- ranks$rank[2]

  start_dates <- as.Date(hospitals$start_date, format = "%m/%d/%Y")
  end_dates <- as.Date(hospitals$end_date, format = "%m/%d/%Y")
  performance_window <- paste(
    pretty_date(format(min(start_dates, na.rm = TRUE), "%m/%d/%Y")), "–",
    pretty_date(format(max(end_dates, na.rm = TRUE), "%m/%d/%Y"))
  )

  cond <- hrrp$by_condition
  cval <- function(condition, column) {
    cond[[column]][match(condition, as.character(cond$condition))]
  }
  fmt_err <- function(x) sprintf("%.3f", x)
  fmt_pct <- function(x) sprintf("%.0f%%", x)

  sd_n_val <- cbsa_hospitals(cbsa_table, "San Diego")
  bay_n <- region_table$hospitals[as.character(region_table$region) == "Bay Area"]
  inland_n <- region_table$hospitals[as.character(region_table$region) == "Inland Empire"]

  metrics <- list(
    roster_label = roster_label,
    mandatory_n = mandatory_n,
    voluntary_n = voluntary_n,
    national_share = national_share,
    sf_rank = sf_rank,
    riverside_rank = riverside_rank,
    performance_window = performance_window,
    fmt_err = fmt_err,
    fmt_pct = fmt_pct,
    hk_scope = cval("Hip/knee replacement", "scope_err"),
    hk_nat = cval("Hip/knee replacement", "national_err"),
    cabg_scope = cval("CABG", "scope_err"),
    cabg_nat = cval("CABG", "national_err"),
    pn_scope = cval("Pneumonia", "scope_err"),
    pn_nat = cval("Pneumonia", "national_err"),
    ami_scope = cval("Heart attack (AMI)", "scope_err"),
    hf_scope = cval("Heart failure", "scope_err"),
    ami_nat = cval("Heart attack (AMI)", "national_err"),
    hf_nat = cval("Heart failure", "national_err"),
    copd_scope = cval("COPD", "scope_err"),
    copd_nat = cval("COPD", "national_err"),
    hk_scope_above = cval("Hip/knee replacement", "scope_above"),
    hk_nat_above = cval("Hip/knee replacement", "national_above"),
    pn_scope_above = cval("Pneumonia", "scope_above"),
    pn_nat_above = cval("Pneumonia", "national_above"),
    cabg_scope_above = cval("CABG", "scope_above"),
    cabg_nat_above = cval("CABG", "national_above"),
    ami_scope_above = cval("Heart attack (AMI)", "scope_above"),
    ami_nat_above = cval("Heart attack (AMI)", "national_above"),
    hf_scope_above = cval("Heart failure", "scope_above"),
    hf_nat_above = cval("Heart failure", "national_above"),
    copd_scope_above = cval("COPD", "scope_above"),
    copd_nat_above = cval("COPD", "national_above"),
    sd_n = sd_n_val,
    sf_pct = round(100 * sf_n / SCOPE_N, 0),
    riverside_pct = round(100 * riverside_n / SCOPE_N, 0),
    sd_pct = round(100 * sd_n_val / SCOPE_N, 0),
    bay_n = bay_n,
    inland_n = inland_n,
    bay_pct = round(100 * bay_n / SCOPE_N, 0),
    inland_pct = round(100 * inland_n / SCOPE_N, 0),
    reporting_n = hrrp$scope_hospitals_in_file,
    non_reporting_n = hrrp$scope_hospitals_total - hrrp$scope_hospitals_in_file,
    hrrp_period = paste(pretty_month(hrrp$period_start), "–", pretty_month(hrrp$period_end)),
    render_date = format(Sys.Date(), "%B %e, %Y") |> trimws() |> gsub(pattern = "  ", replacement = " ")
  )

  if (!is.null(system_rollup)) {
    metrics$multi_system_hospital_n <- system_rollup$multi_system_hospital_n
    metrics$multi_system_system_n <- system_rollup$multi_system_system_n
    metrics$largest_system_label <- system_rollup$largest_system_label
    metrics$largest_system_n <- system_rollup$largest_system_n
    metrics$largest_system_pct <- system_rollup$largest_system_pct
  }

  repo_root_path <- normalizePath(file.path(report_dir, "../.."), winslash = "/", mustWork = TRUE)
  source(file.path(repo_root_path, "R", "write_ca_narration.R"))
  write_ca_narration(
    file.path(report_dir, "california-narration.txt"),
    SCOPE_N = SCOPE_N,
    SCOPE_CBSA_N = SCOPE_CBSA_N,
    NATIONAL_TOTAL = NATIONAL_TOTAL,
    national_share = metrics$national_share,
    mandatory_n = metrics$mandatory_n,
    voluntary_n = metrics$voluntary_n,
    performance_window = metrics$performance_window,
    sf_n = sf_n,
    sf_pct = metrics$sf_pct,
    sf_rank = scales::ordinal(metrics$sf_rank),
    riverside_n = riverside_n,
    riverside_pct = metrics$riverside_pct,
    riverside_rank = scales::ordinal(metrics$riverside_rank),
    sd_n = metrics$sd_n,
    sd_pct = metrics$sd_pct,
    bay_n = metrics$bay_n,
    bay_pct = metrics$bay_pct,
    inland_n = metrics$inland_n,
    inland_pct = metrics$inland_pct,
    multi_system_hospital_n = metrics$multi_system_hospital_n %||% 0L,
    multi_system_system_n = metrics$multi_system_system_n %||% 0L,
    largest_system_label = metrics$largest_system_label %||% "",
    largest_system_n = metrics$largest_system_n %||% 0L,
    largest_system_pct = metrics$largest_system_pct %||% 0L,
    reporting_n = metrics$reporting_n,
    non_reporting_n = metrics$non_reporting_n,
    hrrp_period = metrics$hrrp_period,
    hk_scope = metrics$hk_scope,
    hk_nat = metrics$hk_nat,
    cabg_scope = metrics$cabg_scope,
    cabg_nat = metrics$cabg_nat,
    ami_scope = metrics$ami_scope,
    ami_nat = metrics$ami_nat,
    hf_scope = metrics$hf_scope,
    hf_nat = metrics$hf_nat,
    pn_scope = metrics$pn_scope,
    pn_nat = metrics$pn_nat,
    copd_scope = metrics$copd_scope,
    copd_nat = metrics$copd_nat,
    hk_scope_above = metrics$hk_scope_above,
    hk_nat_above = metrics$hk_nat_above,
    cabg_scope_above = metrics$cabg_scope_above,
    cabg_nat_above = metrics$cabg_nat_above,
    ami_scope_above = metrics$ami_scope_above,
    ami_nat_above = metrics$ami_nat_above,
    hf_scope_above = metrics$hf_scope_above,
    hf_nat_above = metrics$hf_nat_above,
    pn_scope_above = metrics$pn_scope_above,
    pn_nat_above = metrics$pn_nat_above,
    copd_scope_above = metrics$copd_scope_above,
    copd_nat_above = metrics$copd_nat_above
  )

  metrics
}

#' Bind computed metrics into the knitr environment.
assign_ca_white_paper_metrics <- function(metrics) {
  for (nm in names(metrics)) {
    assign(nm, metrics[[nm]], envir = parent.frame())
  }
  invisible(metrics)
}
