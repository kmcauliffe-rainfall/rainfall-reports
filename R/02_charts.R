# CBSA / region / state rollup tables and Figures 1–2.

CA_REGION_MAP <- tibble::tribble(
  ~cbsa, ~region,
  "San Francisco-Oakland-Fremont, CA", "Bay Area",
  "San Jose-Sunnyvale-Santa Clara, CA", "Bay Area",
  "Riverside-San Bernardino-Ontario, CA", "Inland Empire",
  "San Diego-Chula Vista-Carlsbad, CA", "San Diego",
  "Santa Rosa-Petaluma, CA", "North / Central Coast",
  "San Luis Obispo-Paso Robles, CA", "North / Central Coast",
  "Eureka-Arcata, CA", "North / Central Coast",
  "Crescent City, CA", "North / Central Coast",
  "Bakersfield-Delano, CA", "Central Valley",
  "Hanford-Corcoran, CA", "Central Valley",
  "Los Angeles-Long Beach-Anaheim, CA", "Greater Los Angeles*"
)

CA_REGION_LEVELS <- c(
  "Bay Area",
  "Inland Empire",
  "San Diego",
  "North / Central Coast",
  "Central Valley",
  "Greater Los Angeles*",
  "Other / unmapped"
)

CA_ANCHORS <- list(
  ca_total = 107L,
  sf_oakland = 37L,
  riverside = 30L,
  bay_inland_share = 68L
)

build_cbsa_table <- function(hospitals) {
  hospitals |>
    count(cbsa, cbsa_label, name = "hospitals", sort = TRUE) |>
    mutate(
      share_pct = round(100 * hospitals / sum(hospitals), 1),
      cbsa_rank = row_number()
    )
}

build_state_table <- function(hospitals) {
  hospitals |>
    count(state, name = "hospitals", sort = TRUE) |>
    mutate(
      share_pct = round(100 * hospitals / sum(hospitals), 1),
      state_rank = row_number()
    )
}

build_ca_region_table <- function(hospitals) {
  hospitals |>
    left_join(CA_REGION_MAP, by = "cbsa") |>
    mutate(region = if_else(is.na(region), "Other / unmapped", region)) |>
    count(region, name = "hospitals", sort = TRUE) |>
    mutate(
      share_pct = round(100 * hospitals / sum(hospitals), 1),
      region = factor(region, levels = CA_REGION_LEVELS)
    ) |>
    arrange(desc(hospitals), region)
}

fig1_cbsa_plot <- function(tbl) {
  plot_data <- tbl |>
    mutate(
      cbsa_label = fct_reorder(cbsa_label, hospitals),
      size_band = case_when(
        hospitals >= 15 ~ "15+ sites",
        hospitals >= 5 ~ "5–14 sites",
        TRUE ~ "1–4 sites"
      ),
      size_band = factor(size_band, levels = c("15+ sites", "5–14 sites", "1–4 sites"))
    )

  ggplot(plot_data, aes(x = hospitals, y = cbsa_label, fill = size_band)) +
    geom_col(width = 0.72) +
    geom_text(
      aes(label = hospitals),
      hjust = -0.15,
      color = NAVY,
      size = 3,
      family = FONT_FAMILY
    ) +
    scale_fill_manual(
      name = "CBSA size band",
      values = c(
        "15+ sites" = BLUE,
        "5–14 sites" = BLUE_LIGHT,
        "1–4 sites" = BLUE_PALE
      )
    ) +
    scale_x_continuous(
      limits = c(0, max(plot_data$hospitals) + 6),
      expand = expansion(mult = c(0, 0.1)),
      breaks = pretty_breaks(n = 5)
    ) +
    coord_cartesian(clip = "off") +
    labs(x = "Number of TEAM-mandated sites", y = NULL) +
    rain_theme_wp() +
    theme(
      legend.position = "bottom",
      legend.direction = "horizontal",
      plot.margin = margin(8, 36, 10, 8)
    ) +
    guides(fill = guide_legend(title.position = "top", nrow = 1))
}

fig2_grouped_plot <- function(tbl, y_col, x_lab, fill_name, focus_levels, focus_colors) {
  plot_data <- tbl |>
    mutate(
      y_raw = as.character(.data[[y_col]]),
      y = fct_reorder(y_raw, hospitals),
      label = sprintf("%d  (%.0f%%)", hospitals, share_pct)
    )

  ggplot(plot_data, aes(x = hospitals, y = y, fill = focus)) +
    geom_col(width = 0.62) +
    geom_text(
      aes(label = label),
      hjust = -0.08,
      color = NAVY,
      size = 3,
      family = FONT_FAMILY
    ) +
    scale_fill_manual(name = fill_name, values = focus_colors, breaks = focus_levels) +
    scale_x_continuous(
      limits = c(0, max(plot_data$hospitals) + 14),
      expand = expansion(mult = c(0, 0.08)),
      breaks = pretty_breaks(n = 5)
    ) +
    coord_cartesian(clip = "off") +
    labs(x = x_lab, y = NULL) +
    rain_theme_wp() +
    theme(
      legend.position = "bottom",
      plot.margin = margin(8, 40, 10, 8)
    ) +
    guides(fill = guide_legend(title.position = "top", nrow = 1))
}

prepare_report_tables <- function(hospitals, kind, ca_mode = FALSE) {
  n <- nrow(hospitals)
  cbsa_table <- build_cbsa_table(hospitals)
  list(
    hospitals = hospitals,
    n = n,
    cbsa_n = dplyr::n_distinct(hospitals$cbsa),
    state_n = dplyr::n_distinct(hospitals$state),
    cbsa_table = cbsa_table,
    state_table = build_state_table(hospitals),
    region_table = if (ca_mode) build_ca_region_table(hospitals) else NULL,
    top_cbsa = cbsa_table$cbsa_label[[1]],
    top_cbsa_n = cbsa_table$hospitals[[1]]
  )
}

ca_reconciliation <- function(meta) {
  sf_n <- meta$cbsa_table |>
    filter(cbsa == "San Francisco-Oakland-Fremont, CA") |>
    pull(hospitals)
  riverside_n <- meta$cbsa_table |>
    filter(cbsa == "Riverside-San Bernardino-Ontario, CA") |>
    pull(hospitals)
  bay_inland_n <- meta$region_table |>
    filter(as.character(region) %in% c("Bay Area", "Inland Empire")) |>
    summarise(n = sum(hospitals), .groups = "drop") |>
    pull(n)
  bay_inland_share <- as.integer(round(100 * bay_inland_n / meta$n))
  note <- paste0(
    "Repo roster extract (`data/territoryHospitals.json`, March 2026 CMS participant file) ",
    "yields CA total ", meta$n, "; San Francisco–Oakland–Fremont ",
    paste(sf_n, collapse = "/"), "; Riverside–San Bernardino–Ontario ",
    paste(riverside_n, collapse = "/"), "; Bay Area + Inland Empire ",
    bay_inland_n, " (", bay_inland_share, "%). ",
    "These match the locked June 2026 whitepaper anchors (",
    CA_ANCHORS$ca_total, " / ", CA_ANCHORS$sf_oakland, " / ", CA_ANCHORS$riverside, " / ",
    CA_ANCHORS$bay_inland_share, "%). ",
    "If a later CMS quarterly update diverges, re-render and document the delta in the FAQ."
  )
  list(
    sf_n = sf_n,
    riverside_n = riverside_n,
    bay_inland_n = bay_inland_n,
    bay_inland_share = bay_inland_share,
    note = note
  )
}

build_fig1_fig2 <- function(meta, kind) {
  if (kind == "territory") {
    st <- meta$state_table |>
      mutate(
        focus = if_else(
          state_rank <= 3,
          "Largest states in territory",
          "Other territory states"
        )
      )
    save_wp_fig(
      fig2_grouped_plot(
        st,
        y_col = "state",
        x_lab = "Number of TEAM-mandated sites per state",
        fill_name = "State concentration",
        focus_levels = c("Largest states in territory", "Other territory states"),
        focus_colors = c(
          "Largest states in territory" = BLUE,
          "Other territory states" = BLUE_LIGHT
        )
      ),
      "fig1-cbsa.png",
      width = 7.2,
      height = max(3.4, 0.28 * nrow(st) + 1.6)
    )
    top <- meta$cbsa_table |>
      slice_head(n = 12) |>
      mutate(
        focus = if_else(
          cbsa_rank <= 3,
          "Largest CBSAs",
          "Other large CBSAs"
        )
      )
    save_wp_fig(
      fig2_grouped_plot(
        top,
        y_col = "cbsa_label",
        x_lab = "Number of TEAM-mandated sites per CBSA",
        fill_name = "CBSA concentration",
        focus_levels = c("Largest CBSAs", "Other large CBSAs"),
        focus_colors = c("Largest CBSAs" = BLUE, "Other large CBSAs" = BLUE_LIGHT)
      ),
      "fig2-region.png",
      width = 7.2,
      height = 4.6
    )
    return(invisible(NULL))
  }

  save_wp_fig(fig1_cbsa_plot(meta$cbsa_table), "fig1-cbsa.png", width = 7.2, height = 4.8)

  if (isTRUE(identical(unique(meta$hospitals$state), "CA")) && !is.null(meta$region_table)) {
    rec <- ca_reconciliation(meta)
    plot_data <- meta$region_table |>
      filter(as.character(region) != "Other / unmapped") |>
      mutate(
        focus = if_else(
          as.character(region) %in% c("Bay Area", "Inland Empire"),
          sprintf("Bay Area + Inland Empire (%d%%)", rec$bay_inland_share),
          "Other California TEAM regions"
        )
      )
    focus_levels <- c(
      sprintf("Bay Area + Inland Empire (%d%%)", rec$bay_inland_share),
      "Other California TEAM regions"
    )
    save_wp_fig(
      fig2_grouped_plot(
        plot_data,
        y_col = "region",
        x_lab = "Number of TEAM-mandated sites per region",
        fill_name = "Regional concentration",
        focus_levels = focus_levels,
        focus_colors = setNames(c(BLUE, BLUE_LIGHT), focus_levels)
      ),
      "fig2-region.png",
      width = 7.2,
      height = 3.7
    )
  } else {
    rest <- meta$cbsa_table |>
      mutate(
        focus = if_else(cbsa_rank == 1, "Largest CBSA", "Other CBSAs in scope")
      )
    save_wp_fig(
      fig2_grouped_plot(
        rest,
        y_col = "cbsa_label",
        x_lab = "Number of TEAM-mandated sites per region",
        fill_name = "Market concentration",
        focus_levels = c("Largest CBSA", "Other CBSAs in scope"),
        focus_colors = c("Largest CBSA" = BLUE, "Other CBSAs in scope" = BLUE_LIGHT)
      ),
      "fig2-region.png",
      width = 7.2,
      height = 4.4
    )
  }
  invisible(NULL)
}
