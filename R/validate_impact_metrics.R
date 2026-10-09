# Audit-verified anchors (full-audit.md). Render fails if raw files disagree.

validate_impact_metrics <- function(m) {
  stopifnot(
    "TEAM hospitals (Aug 2026 list)" = m$n_team == 721L,
    "CA TEAM hospitals" = m$n_ca == 107L,
    "CA CBSAs" = m$n_ca_cbsa == 11L,
    "CJR-X hospitals" = m$n_cjrx == 2217L,
    "DRG 331 min target price" = round(m$tp_min_331, 2) == 16525.04,
    "DRG 426 max target price" = round(m$tp_max_426, 2) == 134138.71,
    "Track 3 cap" = m$track3_cap_pct == 20L,
    "HCUP 65+ share of OR stays (~37%)" = abs(m$pct_surgical_stays_65plus - 36.5) < 0.6
  )
  invisible(m)
}
