# Rainfall CMS TEAM reports

Quarto + R source for Rainfall Health **CMS TEAM** whitepapers and draft state/territory briefings. Hospital rosters and most charts rebuild from vendored CMS data on every render.

**Repository:** [github.com/kmcauliffe-rainfall/rainfall-reports](https://github.com/kmcauliffe-rainfall/rainfall-reports)

## What’s in here

| Area | Contents |
|------|----------|
| `states/california/` | Full California whitepaper (Figures 3–4 use locked illustrative exposure / HRRP values) |
| `california/` | Symlink to `states/california/` for Finder / RStudio |
| `states/*` | Draft state briefings (CO, FL, LA, MA, MN, NJ, NY, PA, TN) |
| `regions/*` | Draft Territory 1–4 briefings |
| `R/` | Shared loaders, tables, and ggplot figures |
| `data/territoryHospitals.json` | CMS TEAM participant extract (March 2026) |

Draft reports do **not** invent episode-dollar or HRRP time series beyond what the California whitepaper locks in.

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
2. Edit **`states/california/index.qmd`** or **`california/index.qmd`** (same file).
3. Preview: **Render** or `quarto preview california/index.qmd`.

## Render outputs

```bash
quarto render                 # HTML site → _site/
Rscript R/render_all.R pdf     # Typst PDF beside each report index.qmd
```

- **Site home:** `_site/index.html`
- **California HTML:** `_site/states/california/index.html`

## Regenerate draft copy from website MDX

If source MDX lives in `/tmp/team-blogs`:

```bash
python3 tools/build_draft_reports.py
```

## Branches

Default branch is **`main`**. There are no long-lived feature branches; work on `main` or short-lived branches as needed.
