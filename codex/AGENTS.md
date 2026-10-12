# codex/ — California CMS TEAM white paper

This folder supports fact-checking and agent work on the California TEAM state white paper (`states/california/california.qmd`).

## Scope

- **Primary deliverable:** California white paper (Quarto + R, vendored CMS data under `data/`).
- **Out of scope for public copy:** internal coworker names except approved GTM contacts already in the paper.

## Workflow

1. Read vendored sources in `codex/sources/` and repo `data/`.
2. Log every material text change in `codex/fact-check-log.csv` (old text, new text, reason, source).
3. Re-render from `states/california/`: `quarto render california.qmd`.
4. Run `Rscript -e 'source("R/00_setup.R"); ... validate_ca_report(...)'` when changing data paths.

## Compliance

- Keep the Rainfall disclaimer in the white paper unchanged unless counsel approves edits (`codex/COMPLIANCE.md`).
- Do not publish or deploy from agent branches; draft PRs only.

## Key invariants

- Roster counts come from `data/team_participant_list.csv` at render time (`SCOPE_N`, `NATIONAL_TOTAL`).
- HRRP figures come from `data/hrrp_condition_summary.csv` (derived from CMS dataset 9n3s-kdb3).
