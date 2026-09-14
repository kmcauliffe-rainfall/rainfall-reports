# Rainfall CMS TEAM reports

Quarto + R project for Rainfall Health TEAM whitepapers and draft state/region briefings.

## Layout

- `states/california` — full California whitepaper (also available as `california/` symlink at repo root for Finder/RStudio)
- `states/*` — draft whitepapers from the website TEAM state guides
- `regions/*` — draft Territory 1–4 briefings (NorCal/PNW/Rockies, SoCal/Southwest/Gulf, Northeast, South & Midwest)
- `R/` — parameterized roster loaders and figures
- `data/territoryHospitals.json` — vendored CMS TEAM participant extract (March 2026)

## Prerequisites

- Quarto ≥ 1.5 (Typst bundled)
- R ≥ 4.3

## Open in RStudio

1. Open **`rainfall-reports.Rproj`** at the repo root (not a subfolder).
2. California whitepaper source: **`states/california/index.qmd`** (shortcut: **`california/index.qmd`**).
3. Preview: **Render** or `quarto preview states/california/index.qmd`.

## Restore and render

```bash
Rscript -e 'install.packages("renv", repos = "https://cloud.r-project.org"); renv::restore(prompt = FALSE)'
# fallback:
Rscript R/install_deps.R --no-renv

quarto render              # HTML → _site/
Rscript R/render_all.R pdf # Typst PDF per report
```

Hospital counts always recompute from the JSON. California Figures 3–4 remain the locked illustrative exposure index and cited HRRP rates (55.2% vs 48.1%). Other drafts do not invent dollar or HRRP series.

## Rebuild draft copy from website MDX

If `/tmp/team-blogs` holds the source MDX files:

```bash
python3 tools/build_draft_reports.py
```
