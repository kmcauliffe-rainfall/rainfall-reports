impact_root <- function() {
  d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  for (i in 1:6) {
    if (file.exists(file.path(d, "_quarto.yml"))) return(d)
    d <- dirname(d)
  }
  stop("Could not find impact report root")
}

facsimile_asset_subdir <- function(version) {
  switch(
    version,
    v1 = "v1-jun25",
    v2 = "v1-jun25",
    v3 = "v3-published",
    v4 = "v3-published",
    v5 = "v5-final",
    stop("Unknown version ", version)
  )
}

list_facsimile_pages <- function(version) {
  root <- impact_root()
  sub <- facsimile_asset_subdir(version)
  d <- file.path(root, "assets", "facsimile", sub)
  fs <- sort(list.files(d, pattern = "^page-.*\\.png$", full.names = TRUE))
  if (length(fs) == 0) stop("No facsimile PNGs in ", d, " — run scripts/stage_assets.sh")
  fs
}

#' @param web_from versions/ or site root — path prefix to assets
render_facsimile_html <- function(version, web_prefix = "../assets/facsimile") {
  sub <- facsimile_asset_subdir(version)
  pages <- list_facsimile_pages(version)
  out <- character()
  for (i in seq_along(pages)) {
    fn <- basename(pages[i])
    src <- file.path(web_prefix, sub, fn)
    out <- c(
      out,
      sprintf(
        paste0(
          '<div class="facsimile-page-wrap" id="page-%d">',
          '<span class="facsimile-page-label">Page %d</span>',
          '<img class="facsimile-page" src="%s" alt="Page %d" loading="lazy">',
          "</div>"
        ),
        i, i, src, i
      )
    )
  }
  paste(out, collapse = "\n")
}
