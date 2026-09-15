# Rainfall CMS TEAM reports

Quarto + R source for Rainfall Health **CMS TEAM** whitepapers and draft state/territory briefings. Hospital rosters and most charts rebuild from vendored CMS data on every render.

**Repository:** [github.com/kmcauliffe-rainfall/rainfall-reports](https://github.com/kmcauliffe-rainfall/rainfall-reports)

## What’s in here

| Area | Contents |
|------|----------|
| `states/california/` | Full California whitepaper; every figure rebuilds from vendored CMS data |
| `california/` | Symlink to `states/california/` for Finder / RStudio |
| `states/*` | Draft state briefings (CO, FL, LA, MA, MN, NJ, NY, PA, TN) |
| `regions/*` | Draft Territory 1–4 briefings |
| `R/` | Shared loaders, tables, and ggplot figures |
| `data/team_participant_list.csv` | CMS TEAM participant list, parsed from the CMS `.xlsx` (CCN-keyed) |
| `data/hrrp_condition_summary.csv` | Condition-level HRRP summary for California, derived from dataset `9n3s-kdb3` |
| `data/territoryHospitals.json` | Older name-and-CBSA roster extract, retained as a fallback |

No report presents modelled episode dollars: hospital-level TEAM target prices and
episode spending are not published by CMS, so the reports stop at what the public
files support.

## Refreshing CMS data

Both vendored datasets are refreshed deliberately rather than at render time, so
published figures change only through a reviewable diff. Both steps need network
access.

```r
source("R/00_setup.R"); source("R/06_cms_roster.R")
source("R/01_load_data.R"); source("R/05_cms_hrrp.R")

# 1. Participant list (quarterly CMS update)
refresh_team_roster(list_label = "TEAM Participant List - 2026Q3")

# 2. Condition-level HRRP summary for the California roster
refresh_hrrp_summary(load_team_hospitals("CA")$ccn)
```

The HRRP raw file is cached under `data/cache/` (git-ignored) to avoid re-downloading
it; deleting that directory only forces a fresh download on the next refresh.

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) ≥ 1.5 (Typst bundled)
- [R](https://cran.r-project.org/) ≥ 4.3 (developed on **R 4.6.x**)

```bash
quarto --version
R --version
```

## Setup (renv)

From the repo root:

```bash
Rscript -e 'renv::restore(prompt = FALSE)'
Rscript -e 'renv::status()'
```

You want `renv::status()` to report a **consistent** library. If restore fails, try:

```bash
Rscript R/install_deps.R --no-renv
```

## Open in RStudio

1. Open **`rainfall-reports.Rproj`** at the **repo root** (not a subfolder only).
2. Edit **`states/california/california.qmd`** or **`california/california.qmd`** (same file).
3. Preview: **Render** or `quarto preview california/california.qmd`.

## Render outputs

```bash
quarto render                 # HTML site → _site/
Rscript R/render_all.R pdf     # Typst PDF beside each report index.qmd
```

- **Site home:** `_site/index.html`
- **California HTML:** `_site/states/california/california.html`

## Regenerate draft copy from website MDX

If source MDX lives in `/tmp/team-blogs`:

```bash
python3 tools/build_draft_reports.py
```

## Branches

Default branch is **`main`**. There are no long-lived feature branches; work on `main` or short-lived branches as needed.
