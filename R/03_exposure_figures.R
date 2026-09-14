# California-only illustrative exposure (no invented dollars).

exposure_methodology <- tibble(
  Step = 1:5,
  Element = c(
    "System universe",
    "Episode mix",
    "Relative pressure index",
    "Safety-net flag",
    "Output"
  ),
  Description = c(
    "Seventeen California TEAM-aligned systems ranked for relative episode-cost pressure.",
    "LEJR-weighted episode mix with qualitative adjustments for service-line concentration.",
    "Unitless index (peer-relative). No CMS target, reconciliation, or dollar tick marks.",
    "Zuckerberg San Francisco General placed in the low modeled-exposure band under this method.",
    "Illustrative ranking chart for executive briefing — not a hospital-specific forecast."
  )
)

exposure_data_gap_note <- paste(
  "No hospital- or system-level TEAM exposure dollar series is vendored in this repository.",
  "To replace Figure 3's illustrative index with modeled dollars, add a reproducible extract with",
  "system identifiers, LEJR (and other TEAM episode) volume, baseline episode spend, and",
  "TEAM target prices (Rainfall California Episode Economics Analysis inputs), then re-render.",
  "Until that file lands, Figure 3 stays a unitless relative index — not invented dollar amounts."
)

exposure_illustrative <- tibble(
  system = c(
    "System A\n(integrated)",
    "System B",
    "System C",
    "System D",
    "System E\n(safety-net)",
    "Zuckerberg\nSF General*"
  ),
  exposure_index = c(0.35, 0.55, 0.70, 0.90, 1.15, 0.28),
  series = c(
    "Illustrative peer systems",
    "Illustrative peer systems",
    "Illustrative peer systems",
    "Illustrative peer systems",
    "Illustrative peer systems",
    "Zuckerberg SF General (low band)"
  )
)

fig3_exposure_plot <- function(tbl = exposure_illustrative) {
  plot_data <- tbl |>
    mutate(
      system = factor(system, levels = system),
      series = factor(
        series,
        levels = c("Illustrative peer systems", "Zuckerberg SF General (low band)")
      ),
      label = if_else(
        grepl("Zuckerberg", system),
        "low modeled\nexposure",
        sprintf("%.2f", exposure_index)
      )
    )

  ggplot(plot_data, aes(x = system, y = exposure_index, fill = series)) +
    geom_col(width = 0.68) +
    geom_text(
      aes(label = label),
      vjust = -0.2,
      color = NAVY,
      size = 2.6,
      lineheight = 0.95,
      family = FONT_FAMILY
    ) +
    scale_fill_manual(
      name = "Series (illustrative index — not $)",
      values = c(
        "Illustrative peer systems" = BLUE,
        "Zuckerberg SF General (low band)" = TEAL
      )
    ) +
    scale_y_continuous(
      limits = c(0, 1.48),
      expand = expansion(mult = c(0, 0.1)),
      labels = function(x) sprintf("%.2f", x)
    ) +
    coord_cartesian(clip = "off") +
    labs(
      x = NULL,
      y = "Illustrative relative episode-cost exposure\n(index; Rainfall 17-system method)",
      caption = "Illustrative index only — Rainfall California Episode Economics Analysis. Not CMS reconciliation dollars."
    ) +
    rain_theme_wp() +
    theme(
      axis.text.x = element_text(size = 7.5, lineheight = 0.95, family = FONT_FAMILY),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = GRAY_LINE, linewidth = 0.5),
      plot.caption = element_text(color = TEAL, size = 7.5, face = "italic", family = FONT_FAMILY),
      plot.margin = margin(16, 18, 10, 8),
      legend.position = "bottom"
    ) +
    guides(fill = guide_legend(title.position = "top", nrow = 1))
}

build_fig3 <- function() {
  save_wp_fig(fig3_exposure_plot(), "fig3-exposure.png", width = 7.2, height = 3.9)
}
