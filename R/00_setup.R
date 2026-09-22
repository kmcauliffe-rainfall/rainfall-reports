# Paths, packages, brand theme, DM Sans for ggplot.
# Reports live two levels below repo root (states/<slug> or regions/<slug>).

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(forcats)
  library(scales)
  library(jsonlite)
  library(knitr)
})

if (capabilities("aqua")) {
  options(bitmapType = "quartz")
}
knitr::opts_chunk$set(dev = "png", dpi = 150)

`%||%` <- function(x, y) if (is.null(x)) y else x

report_dir <- function() {
  normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

repo_root <- function() {
  d <- report_dir()
  for (i in 1:5) {
    if (file.exists(file.path(d, "data", "territoryHospitals.json"))) {
      return(d)
    }
    parent <- dirname(d)
    if (identical(parent, d)) break
    d <- parent
  }
  stop("Could not find repo root (data/territoryHospitals.json).")
}

REPO_ROOT <- repo_root()
REPORT_DIR <- report_dir()
DATA_DIR <- file.path(REPO_ROOT, "data")
FONT_DIR <- file.path(REPO_ROOT, "fonts")
ASSET_DIR <- file.path(REPO_ROOT, "assets")
FIG_DIR <- file.path(REPORT_DIR, "figures")
OUT_FIG_DIR <- file.path(REPORT_DIR, "outputs", "figures")

dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(OUT_FIG_DIR, showWarnings = FALSE, recursive = TRUE)

NAVY <- "#1e293b"
BLUE <- "#2b62e7"
BLUE_LIGHT <- "#3b82f6"
BLUE_PALE <- "#93c5fd"
TEAL <- "#0d9488"
GRAY <- "#64748b"
GRAY_LINE <- "#e2e8f0"
PAPER <- "#ffffff"

FONT_FAMILY <- "sans"
if (requireNamespace("sysfonts", quietly = TRUE) &&
      requireNamespace("showtext", quietly = TRUE)) {
  regular <- file.path(FONT_DIR, "DMSans-Regular.ttf")
  bold <- file.path(FONT_DIR, "DMSans-Bold.ttf")
  if (file.exists(regular)) {
    sysfonts::font_add(
      "DM Sans",
      regular = regular,
      bold = if (file.exists(bold)) bold else regular,
      italic = regular,
      bolditalic = if (file.exists(bold)) bold else regular
    )
    showtext::showtext_auto()
    showtext::showtext_opts(dpi = 300)
    FONT_FAMILY <- "DM Sans"
  }
}

rain_theme_wp <- function(base_size = 11) {
  theme_minimal(base_size = base_size, base_family = FONT_FAMILY) +
    theme(
      plot.background = element_rect(fill = PAPER, color = NA),
      panel.background = element_rect(fill = PAPER, color = NA),
      panel.grid.major.x = element_line(color = GRAY_LINE, linewidth = 0.5),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text = element_text(color = GRAY, size = 9, family = FONT_FAMILY),
      axis.title = element_text(color = NAVY, size = 10, family = FONT_FAMILY),
      axis.title.y = element_text(margin = margin(r = 6)),
      plot.title = element_text(
        color = NAVY, size = 12, face = "bold", hjust = 0, family = FONT_FAMILY,
        margin = margin(b = 4)
      ),
      plot.title.position = "plot",
      plot.subtitle = element_text(
        color = GRAY, size = 9, hjust = 0, margin = margin(b = 8), family = FONT_FAMILY
      ),
      plot.caption = element_text(
        color = GRAY, size = 8, hjust = 0, margin = margin(t = 8), family = FONT_FAMILY
      ),
      plot.caption.position = "plot",
      legend.text = element_text(color = GRAY, size = 8.5, family = FONT_FAMILY),
      legend.title = element_text(color = NAVY, size = 9, face = "bold", family = FONT_FAMILY),
      plot.margin = margin(8, 28, 10, 8),
      legend.position = "bottom",
      legend.justification = "left",
      legend.margin = margin(t = 4, b = 0)
    )
}

save_wp_fig <- function(plot, filename, width = 7.1, height = 4.6) {
  path_primary <- file.path(FIG_DIR, filename)
  path_mirror <- file.path(OUT_FIG_DIR, filename)
  ggsave(
    path_primary,
    plot = plot,
    width = width,
    height = height,
    dpi = 300,
    bg = PAPER,
    limitsize = FALSE
  )
  file.copy(path_primary, path_mirror, overwrite = TRUE)
  invisible(path_primary)
}

en_dash <- function(x) {
  gsub("-", "\u2013", x, fixed = TRUE)
}

cbsa_display_name <- function(cbsa) {
  short <- sub(",\\s*[A-Z]{2}$", "", cbsa)
  en_dash(short)
}

rel_asset <- function(filename) {
  # Report folders symlink `assets/` (tools/link_report_assets.sh) for Typst + HTML.
  file.path("assets", filename)
}
