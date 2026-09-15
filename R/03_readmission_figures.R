# Figures 3-4: condition-level readmission performance, California TEAM
# hospitals vs. the national HRRP file. Both rebuild from CMS data at render
# time; neither uses an illustrative or modelled value.

#' Figure 3. Mean Excess Readmission Ratio by condition, scope vs national,
#' drawn as a paired-dot (dumbbell) chart against the 1.00 expectation line.
fig3_err_plot <- function(profile, scope_label = "California TEAM hospitals") {
  tbl <- profile$by_condition |>
    dplyr::filter(!is.na(scope_err)) |>
    dplyr::mutate(condition = forcats::fct_rev(condition))

  long <- dplyr::bind_rows(
    dplyr::transmute(tbl, condition, cohort, err = scope_err, series = scope_label),
    dplyr::transmute(tbl, condition, cohort, err = national_err, series = "National average")
  ) |>
    dplyr::mutate(series = factor(series, levels = c(scope_label, "National average")))

  ggplot(tbl, aes(y = condition)) +
    geom_vline(xintercept = 1, color = NAVY, linewidth = 0.5, linetype = "22") +
    geom_segment(
      aes(x = national_err, xend = scope_err, yend = condition),
      color = GRAY_LINE, linewidth = 1.6, lineend = "round"
    ) +
    geom_point(data = long, aes(x = err, color = series), size = 2.9) +
    geom_text(
      aes(
        x = scope_err,
        label = sprintf("%.3f", scope_err),
        hjust = ifelse(scope_err < national_err, 1.35, -0.35)
      ),
      color = NAVY, size = 2.9, family = FONT_FAMILY
    ) +
    scale_color_manual(name = NULL, values = stats::setNames(c(BLUE, GRAY), c(scope_label, "National average"))) +
    scale_x_continuous(
      # Headroom on both sides so the value labels never run into the axis
      # labels or the panel edge.
      limits = c(min(long$err) - 0.006, max(long$err) + 0.005),
      breaks = scales::pretty_breaks(n = 5),
      labels = function(x) sprintf("%.2f", x)
    ) +
    coord_cartesian(clip = "off") +
    labs(
      x = "Mean Excess Readmission Ratio (1.00 = risk-adjusted expectation)",
      y = NULL,
      caption = "Dashed line marks 1.00. Values below the line indicate fewer readmissions than expected for the hospital's case mix."
    ) +
    rain_theme_wp() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = GRAY_LINE, linewidth = 0.5),
      plot.margin = margin(10, 30, 8, 8)
    ) +
    guides(color = guide_legend(nrow = 1))
}

#' Figure 4. Share of hospitals above the 1.00 expectation, by condition.
fig4_prevalence_plot <- function(profile, scope_label = "California TEAM hospitals") {
  tbl <- profile$by_condition |>
    dplyr::filter(!is.na(scope_above)) |>
    dplyr::mutate(condition = forcats::fct_rev(condition))

  long <- dplyr::bind_rows(
    dplyr::transmute(tbl, condition, share = scope_above, series = scope_label),
    dplyr::transmute(tbl, condition, share = national_above, series = "All hospitals nationally")
  ) |>
    dplyr::mutate(
      series = factor(series, levels = c(scope_label, "All hospitals nationally"))
    )

  ggplot(long, aes(x = share, y = condition, fill = series)) +
    geom_col(width = 0.66, position = position_dodge(width = 0.72)) +
    geom_text(
      aes(label = sprintf("%.0f%%", share)),
      position = position_dodge(width = 0.72),
      hjust = -0.18, color = NAVY, size = 2.8, family = FONT_FAMILY
    ) +
    scale_fill_manual(
      name = NULL,
      values = stats::setNames(c(BLUE, GRAY), c(scope_label, "All hospitals nationally"))
    ) +
    scale_x_continuous(
      limits = c(0, max(long$share) + 14),
      expand = expansion(mult = c(0, 0.04)),
      breaks = scales::pretty_breaks(n = 5),
      labels = function(x) paste0(x, "%")
    ) +
    coord_cartesian(clip = "off") +
    labs(x = "Share of hospitals with an Excess Readmission Ratio above 1.00", y = NULL) +
    rain_theme_wp() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = GRAY_LINE, linewidth = 0.5),
      plot.margin = margin(10, 34, 8, 8)
    ) +
    guides(fill = guide_legend(nrow = 1))
}

build_readmission_figs <- function(profile) {
  if (identical(profile$status, "unavailable")) return(invisible(NULL))
  save_wp_fig(fig3_err_plot(profile), "fig3-err.png", width = 7.2, height = 3.9)
  save_wp_fig(fig4_prevalence_plot(profile), "fig4-err-prevalence.png", width = 7.2, height = 3.9)
  invisible(NULL)
}
