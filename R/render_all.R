#!/usr/bin/env Rscript
# Render the HTML website and Typst PDFs for every report.

args <- commandArgs(trailingOnly = TRUE)
do_html <- length(args) == 0 || "html" %in% args || "all" %in% args
do_pdf <- length(args) == 0 || "pdf" %in% args || "all" %in% args

root <- if (file.exists("index.qmd")) {
  normalizePath(".", winslash = "/", mustWork = TRUE)
} else {
  stop("Run from the rainfall-reports repo root")
}

reports <- c(
  list.files(file.path(root, "states"), pattern = "index\\.qmd$", recursive = TRUE, full.names = TRUE),
  list.files(file.path(root, "regions"), pattern = "index\\.qmd$", recursive = TRUE, full.names = TRUE)
)

if (do_html) {
  message("Rendering HTML website...")
  status <- system2("quarto", c("render"), stdout = TRUE, stderr = TRUE)
  writeLines(status)
}

if (do_pdf) {
  for (qmd in reports) {
    message("Typst PDF: ", qmd)
    status <- system2(
      "quarto",
      c("render", qmd, "--to", "typst"),
      stdout = TRUE,
      stderr = TRUE
    )
    writeLines(status)
    if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
      stop("Failed: ", qmd)
    }
  }
}

message("Done.")
