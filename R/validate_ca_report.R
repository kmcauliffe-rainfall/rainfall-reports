# Pre-flight checks for the California white paper render.

validate_ca_report <- function(
    hospitals,
    cbsa_table,
    region_table,
    hrrp,
    system_rollup = NULL,
    warn_only = TRUE) {
  issues <- character()

  scope_n <- nrow(hospitals)
  cbsa_sum <- sum(cbsa_table$hospitals)
  if (!identical(as.integer(scope_n), as.integer(cbsa_sum))) {
    issues <- c(
      issues,
      sprintf("CBSA table sums to %d but scope has %d hospitals", cbsa_sum, scope_n)
    )
  }

  prov <- team_roster_provenance()
  if (length(prov$hospitals) && !identical(as.integer(NATIONAL_TOTAL), as.integer(prov$hospitals))) {
    issues <- c(
      issues,
      sprintf(
        "NATIONAL_TOTAL (%d) differs from team_participant_list_source.json (%d)",
        NATIONAL_TOTAL, prov$hospitals
      )
    )
  }

  if (identical(hrrp$status, "unavailable")) {
    issues <- c(issues, "HRRP summary unavailable")
  }

  if (!is.null(system_rollup)) {
    if (system_rollup$largest_system_n < 1L) {
      issues <- c(issues, "System rollup returned no largest system")
    }
    aff_n <- nrow(system_rollup$affiliations)
    if (!identical(as.integer(aff_n), as.integer(scope_n))) {
      issues <- c(
        issues,
        sprintf("System affiliations map has %d rows, expected %d", aff_n, scope_n)
      )
    }
  }

  if (length(issues) == 0) {
    return(invisible(TRUE))
  }

  msg <- paste(c("California report validation:", issues), collapse = "\n")
  if (warn_only) {
    warning(msg, call. = FALSE)
    return(invisible(FALSE))
  }
  stop(msg)
}
