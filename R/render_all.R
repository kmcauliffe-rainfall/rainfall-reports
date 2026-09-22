#!/usr/bin/env Rscript
# Render each standalone Quarto project under states/, regions/, and newsletter/.

args <- commandArgs(trailingOnly = TRUE)
do_html <- length(args) == 0 || "html" %in% args || "all" %in% args
do_pdf <- length(args) == 0 || "pdf" %in% args || "all" %in% args

root <- if (file.exists("R/render_all.R")) {
  normalizePath(".", winslash = "/", mustWork = TRUE)
} else {
  stop("Run from the rainfall-reports repo root")
}

find_project_dirs <- function(base) {
  if (!dir.exists(base)) return(character())
  top <- list.dirs(base, full.names = TRUE, recursive = FALSE)
  top[file.exists(file.path(top, "_quarto.yml"))]
}

# White papers build both HTML and a Typst PDF.
report_projects <- c(
  find_project_dirs(file.path(root, "states")),
  find_project_dirs(file.path(root, "regions"))
)

# Newsletter articles are HTML-only. They define no Typst format, so they take
# part in the HTML pass and are skipped by the PDF pass below.
newsletter_projects <- find_project_dirs(file.path(root, "newsletter"))

projects <- c(report_projects, newsletter_projects)

if (length(projects) == 0) {
  stop("No projects found (expected _quarto.yml under states/, regions/, or newsletter/)")
}

if (do_html) {
  for (proj in projects) {
    message("Quarto project (HTML): ", proj)
    status <- system2("quarto", "render", stdout = TRUE, stderr = TRUE, wd = proj)
    writeLines(status)
    if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
      stop("Failed: ", proj)
    }
  }
}

if (do_pdf) {
  for (proj in report_projects) {
    qmds <- list.files(proj, pattern = "\\.qmd$", full.names = TRUE)
    for (qmd in qmds) {
      message("Typst PDF: ", qmd)
      status <- system2(
        "quarto",
        c("render", basename(qmd), "--to", "typst"),
        stdout = TRUE,
        stderr = TRUE,
        wd = proj
      )
      writeLines(status)
      if (!is.null(attr(status, "status")) && attr(status, "status") != 0) {
        stop("Failed: ", qmd)
      }
    }
  }
}

message("Done.")
