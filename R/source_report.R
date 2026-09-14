# Locate repo root from the knitr working directory and source R/report.R.
# Set REPORT_KIND and REPORT_ID in the calling chunk first.

if (!exists("REPORT_KIND") || !exists("REPORT_ID")) {
  stop("Set REPORT_KIND and REPORT_ID before sourcing R/source_report.R")
}

.d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
for (.i in 1:6) {
  if (file.exists(file.path(.d, "R", "report.R"))) {
    source(file.path(.d, "R", "report.R"))
    break
  }
  .p <- dirname(.d)
  if (identical(.p, .d)) {
    stop("Could not find rainfall-reports repo root (R/report.R).")
  }
  .d <- .p
}
