# California HRRP comparison from locked CMS-derived rates used sitewide.

hrrp_comparison <- tibble(
  group = c("California TEAM\nhospitals", "National\nIPPS average"),
  penalty_rate = c(55.2, 48.1),
  series = c("California TEAM hospitals", "National IPPS average")
)

hrrp_provenance <- paste(
  "Source: CMS HRRP FY2025 supplemental data (dataset 9n3s-kdb3).",
  "Rates reused from rainfall-corp-website scripts/r/rainfall_charts.R",
  "(CA TEAM 55.2% vs national 48.1%).",
  "Raw hospital-level HRRP CSV is not vendored in this repository."
)

fig4_hrrp_plot <- function(tbl = hrrp_comparison) {
  plot_data <- tbl |>
    mutate(
      group = factor(group, levels = group),
      series = factor(series, levels = unique(series))
    )

  ggplot(plot_data, aes(x = group, y = penalty_rate, fill = series)) +
    geom_col(width = 0.55) +
    geom_text(
      aes(label = sprintf("%.1f%%", penalty_rate)),
      vjust = -0.35,
      color = NAVY,
      size = 3.8,
      fontface = "bold",
      family = FONT_FAMILY
    ) +
    scale_fill_manual(
      name = NULL,
      values = c(
        "California TEAM hospitals" = BLUE,
        "National IPPS average" = GRAY
      )
    ) +
    scale_y_continuous(
      limits = c(0, 72),
      expand = expansion(mult = c(0, 0.04))
    ) +
    coord_cartesian(clip = "off") +
    labs(
      x = NULL,
      y = "Share of hospitals with HRRP penalty (%)"
    ) +
    rain_theme_wp() +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(color = GRAY_LINE, linewidth = 0.5),
      axis.text.x = element_text(size = 9, lineheight = 0.95, family = FONT_FAMILY),
      plot.margin = margin(12, 12, 8, 8),
      legend.position = "bottom"
    ) +
    guides(fill = guide_legend(nrow = 1))
}

build_fig4 <- function() {
  save_wp_fig(fig4_hrrp_plot(), "fig4-hrrp.png", width = 5.0, height = 3.5)
}
