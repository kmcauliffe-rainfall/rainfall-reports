# Rainfall CMS TEAM reports

Quarto + R source for Rainfall Health **CMS TEAM** whitepapers and draft state/territory briefings. Open **`states/<name>/`** or **`regions/<name>/`** — each folder is its own Quarto project with local render output and a **`netlify/`** staging folder for deploy (gitignored).

**Repository:** [github.com/kmcauliffe-rainfall/rainfall-reports](https://github.com/kmcauliffe-rainfall/rainfall-reports)

## Report folders

| Folder | Main file | Status |
|--------|-----------|--------|
| [`states/california/`](states/california/) | `california.qmd` | Whitepaper (Netlify-ready) |
| [`states/colorado/`](states/colorado/) … [`states/tennessee/`](states/tennessee/) | `index.qmd` | Drafts |
| [`regions/norcal-pnw-rockies/`](regions/norcal-pnw-rockies/) … [`regions/south-midwest/`](regions/south-midwest/) | `index.qmd` | Drafts |

Shared code and CMS data: [`R/`](R/), [`data/`](data/), [`styles/`](styles/), [`assets/`](assets/). Each report folder also has `assets/`, `fonts/`, and `styles/` (from `tools/link_report_assets.sh`).

Every report folder includes:

- `_quarto.yml`, `{name}.Rproj`, `.Rprofile` (uses repo-root renv)
- `deploy-netlify.sh` → renders and stages **`netlify/`** for upload
- `netlify.toml` (California has full headers; drafts use minimal config)

Deployed sites use **`robots.txt` (Disallow: /)**, **`noindex`** meta, and **`X-Robots-Tag`** — unlisted, not search-engine friendly. Anyone with the URL can still view the page.

## One-time setup

From the **repo root**:

```bash
Rscript -e 'renv::restore(prompt = FALSE)'
./tools/link_report_assets.sh
```

## Work on California

```bash
cd states/california
quarto render                    # california.html + california.pdf in this folder
open california.html             # local preview
./deploy-netlify.sh              # builds netlify/ for upload
```

**Listen along:** The web player uses [`audio/california-narration.mp3`](states/california/audio/california-narration.mp3). The **script** is [`california-narration.txt`](states/california/california-narration.txt), rebuilt on every `quarto render` from `R/write_ca_narration.R` (sections 01–06, aligned with the article). The **MP3 does not update automatically** — after render, paste the new `.txt` into ElevenLabs, export audio to `states/california/audio/california-narration.mp3`, then `./deploy-netlify.sh`.

Drag **`states/california/netlify/`** to [app.netlify.com/drop](https://app.netlify.com/drop), or use the Netlify CLI (no global install required):

```bash
cd states/california
npx netlify-cli login          # once, opens browser
npx netlify-cli deploy --prod --dir=netlify
```

Optional: `brew install netlify-cli` or `npm install -g netlify-cli`, then `netlify deploy --prod --dir=netlify`.

Draft states/regions: same pattern inside their folder (`quarto render`, `./deploy-netlify.sh`).

## Render all projects

```bash
Rscript R/render_all.R
Rscript R/render_all.R pdf
```

## Refreshing CMS data

From repo root with renv active:

```r
source("R/00_setup.R"); source("R/06_cms_roster.R")
source("R/01_load_data.R"); source("R/05_cms_hrrp.R")
refresh_team_roster(list_label = "TEAM Participant List - 2026Q3")
refresh_hrrp_summary(load_team_hospitals("CA")$ccn)
```

## Prerequisites

- [Quarto](https://quarto.org/docs/get-started/) ≥ 1.5
- [R](https://cran.r-project.org/) ≥ 4.3

## Regenerate draft copy from website MDX

```bash
python3 tools/build_draft_reports.py
```
