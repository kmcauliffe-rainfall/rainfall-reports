#!/usr/bin/env Rscript
# Restore / install R dependencies.

args <- commandArgs(trailingOnly = TRUE)
use_renv <- !("--no-renv" %in% args)

if (use_renv && requireNamespace("renv", quietly = TRUE) && file.exists("renv.lock")) {
  message("Restoring from renv.lock...")
  renv::restore(prompt = FALSE)
  quit(status = 0)
}

desc <- read.dcf("DESCRIPTION")
imports <- desc[, "Imports"]
pkgs <- trimws(strsplit(imports, ",")[[1]])
pkgs <- sub("\\s*\\(.*$", "", pkgs)
pkgs <- pkgs[nzchar(pkgs)]

missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) == 0) {
  message("All DESCRIPTION Imports already installed.")
  quit(status = 0)
}

message("Installing: ", paste(missing, collapse = ", "))
install.packages(
  missing,
  repos = "https://cloud.r-project.org",
  Ncpus = max(1L, parallel::detectCores() - 1L)
)
message("Done.")
