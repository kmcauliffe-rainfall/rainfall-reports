# CMS TEAM Impact Report (`impact`)

Standalone Quarto **website** — five timeline-ordered versions of Rainfall Health’s CMS TEAM Impact Report (Jun 25 draft → Jul 27 published → audit-corrected final), plus data, sources, validation, and portfolio UI.

## Prerequisites

- [Quarto](https://quarto.org/) ≥ 1.5  
- R ≥ 4.3  
- Python 3  
- Typst CLI (PDF facsimiles for v1–v4)  
- `poppler-utils` (`pdftotext`, `pdftoppm`)  
- Optional: `tesseract-ocr` (HCUP Figure 2 chart label)

## One-time setup

```bash
cd impact   # this repository
Rscript -e 'renv::restore(prompt = FALSE)'
python3 scripts/fetch_all_sources.py
python3 scripts/extract_hcup_figure2_shares.py
bash scripts/stage_assets.sh
```

## Local preview (exact commands)

```bash
cd impact
bash scripts/stage_assets.sh
bash scripts/render_typst_pdfs.sh    # v1–v4 letter-size PDF facsimiles
quarto render                        # site → _site/
quarto preview                       # browser + live reload
```

## Netlify (optional — not deployed by default)

```bash
quarto render
bash deploy-netlify.sh
# Upload netlify/ via Netlify Drop or CLI when you choose to publish.
```

`netlify.toml` follows the same **pre-rendered static** pattern as Rainfall’s California whitepaper in `rainfall-reports`.

## Layout & fonts

Published PDF facsimiles: **612×792 pt** US Letter PNGs (`sources/layout/`).  
Fonts (`pdffonts`): **DM Sans**, **Roboto Mono** (bundled under `fonts/`), Canva Sans → DM Sans.

## Key docs

| Path | Purpose |
| --- | --- |
| `DECISIONS.md` | Judgment calls (checkbox list; also rendered at `/decisions.html`) |
| `calculations.qmd` | How each computed number is derived |
| `sources/MANIFEST.md` | Every data/source file |
| `config/internal_analysis.json` | Refs 13–14 internal values (not shown as TODO in v5) |
