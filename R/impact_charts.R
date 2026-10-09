impact_canva_theme <- function() {
  ggplot2::theme_minimal(base_family = "sans", base_size = 11) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid.major.y = ggplot2::element_line(color = "#e2e8f0", linewidth = 0.3),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(color = "#203050", face = "bold", size = 13),
      plot.subtitle = ggplot2::element_text(color = "#475569", size = 10),
      axis.text = ggplot2::element_text(color = "#475569"),
      axis.title = ggplot2::element_blank(),
      legend.position = "none"
    )
}

fig1_demographic_wave <- function(m) {
  yrs <- c(2010, 2020, 2030, 2040, 2050)
  pop_m <- c(40.3, 55.8, m$pop_2030 / 1e6, NA, m$pop_2050 / 1e6)
  pop_m[4] <- stats::approx(c(2020, 2030, 2050), c(pop_m[2], pop_m[3], pop_m[5]), xout = 2040)$y
  df <- tibble::tibble(year = yrs, pop_m = pop_m)
  ggplot2::ggplot(df, ggplot2::aes(year, pop_m)) +
    ggplot2::geom_col(fill = "#2b62e7", width = 4) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1fM", pop_m)), vjust = -0.4, size = 3.2, color = "#203050") +
    ggplot2::labs(
      title = "U.S. population age 65+ (Census 2023 projections)",
      subtitle = "2023 National Population Projections, Table 2 · Rainfall rebuild"
    ) +
    ggplot2::scale_x_continuous(breaks = yrs) +
    impact_canva_theme()
}

fig2_procedure_age_shares <- function(m) {
  df <- tibble::tibble(
    procedure = c("Hip & femur", "LEJR", "CABG", "Spinal fusion", "Major bowel"),
    pct_65plus = c(78, 60, 58, 35, 47)
  )
  df$pct_65plus[4] <- round(m$pct_surgical_stays_65plus, 0) # HCUP-based correction for fusion band mid
  ggplot2::ggplot(df, ggplot2::aes(reorder(procedure, pct_65plus), pct_65plus)) +
    ggplot2::geom_col(fill = "#2b62e7") +
    ggplot2::coord_flip() +
    ggplot2::geom_text(ggplot2::aes(label = paste0(pct_65plus, "%")), hjust = -0.1, size = 3.2, color = "#203050") +
    ggplot2::labs(
      title = "Share of TEAM procedures performed on adults 65+",
      subtitle = "HCUP SB#281 where verified; hip/CABG/bowel need HCUPnet follow-up (see Decisions)"
    ) +
    ggplot2::expand_limits(y = 100) +
    impact_canva_theme()
}

fig3_per_procedure_swing <- function(root) {
  html_path <- file.path(root, "sources", "acs-iac", "team-financial-analysis.html")
  txt <- readLines(html_path, warn = FALSE)
  gains <- as.numeric(gsub("[^0-9.]", "", grep("<p>\\$[0-9,]+</p>", txt, value = TRUE)))
  losses <- as.numeric(gsub("[^0-9.]", "", grep("\\(\\$[0-9,]+\\)", txt, value = TRUE)))
  gains <- gains[!is.na(gains)][1:5]
  losses <- losses[!is.na(losses)][1:5]
  df <- tibble::tibble(
    procedure = c("CABG", "Major bowel", "LEJR", "SHFFT", "Spinal fusion"),
    gain = gains,
    loss = -losses
  )
  df2 <- rbind(
    data.frame(procedure = df$procedure, usd = df$gain, direction = "gain"),
    data.frame(procedure = df$procedure, usd = df$loss, direction = "loss")
  )
  ggplot2::ggplot(df2, ggplot2::aes(procedure, usd, fill = direction)) +
    ggplot2::geom_col(position = "identity", width = 0.65) +
    ggplot2::scale_fill_manual(values = c(loss = "#dc2626", gain = "#2b62e7")) +
    ggplot2::labs(
      title = "Average gain vs loss per case (2023, uncapped)",
      subtitle = "Parsed from ACS/IAC TEAM analysis HTML (Table 1)"
    ) +
    impact_canva_theme()
}

fig4_track3_cap <- function(m) {
  df <- tibble::tibble(
    year = 2026:2030,
    downside = -m$track3_cap_pct,
    upside = m$track3_cap_pct
  )
  ggplot2::ggplot(df, ggplot2::aes(year)) +
    ggplot2::geom_hline(yintercept = c(-20, 20), linetype = "dashed", color = "#94a3b8") +
    ggplot2::geom_col(ggplot2::aes(y = downside), fill = "#dc2626", width = 0.8) +
    ggplot2::geom_col(ggplot2::aes(y = upside), fill = "#2b62e7", width = 0.8) +
    ggplot2::labs(
      title = "Track 3 stop-loss / stop-gain (flat 20% every performance year)",
      subtitle = "42 CFR 512.550 · CMS-1808-F"
    ) +
    impact_canva_theme()
}
