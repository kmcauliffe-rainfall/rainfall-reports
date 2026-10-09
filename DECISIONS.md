# Judgment calls — CMS TEAM Impact Report rebuild

Kyle: check the option you prefer for each item (or add a note). Recommended picks are marked **→**.

---

## 1. Facsimile fidelity (v1–v4)

- [ ] **→ A.** Full-page PNG facsimiles from source PDFs (LibreOffice Jun 25; published Jul 27) for pixel-matched layout.
- [ ] **B.** Rebuilt HTML/Typst pages that mimic Canva spacing without raster pages.

**Picked A** because Canva design files are unavailable and Kyle asked for maximum PDF fidelity.

---

## 2. Version 5 layout vs published

- [ ] **→ A.** Semantic rebuild (DM Sans, Rainfall colors `#203050` / `#2b62e7`, R ggplot figures) — same *sections* as published, not raster pages.
- [ ] **B.** Published page PNGs with invisible text replacement layers.

**Picked A** so corrected copy and citations stay selectable/searchable and charts stay data-driven.

---

## 3. Figure 2 procedure age shares (HCUP)

- [ ] **→ A.** Show HCUP-verified LEJR/knee (~60%) and label hip/CABG/spinal/bowel as “HCUPnet follow-up” with published approximations in v5 only where audit flagged gaps.
- [ ] **B.** Omit Fig 2 until all five bars are sourced from HCUPnet queries.

**Picked A** to ship a complete narrative; bar chart footnote states which bars are approximate.

---

## 4. ACS/IAC Figure 3 values

- [ ] **→ A.** Parse dollar amounts from saved ACS/IAC HTML snapshot (`sources/acs-iac/`).
- [ ] **B.** Hardcode Table 1 constants in a CSV until ACS publishes machine-readable data.

**Picked A** with regex extraction; validated against audit-listed averages.

---

## 5. Internal economics (refs 13–14)

- [ ] **→ A.** Keep config values in `config/internal_analysis.yml`; render as “internal Rainfall analysis” (no TODO on page).
- [ ] **B.** Drop $2.4M / $14.5M / $85M figures until model files arrive.

**Picked A** per original brief; documented in PR “Needed from Kyle.”

---

## 6. HCUP 75+ share (16.8%)

- [ ] **→ A.** Use Figure 2 chart label 16.8% with crop asset + prose 19.7% from PDF text (sum 36.5%).
- [ ] **B.** Wait for AHRQ to confirm 75+ “with OR” share in machine-readable form.

**Picked A** — 16.8% appears only on the chart; manifest points to `figure2-with-or-chart-crop.png`.

---

## 7. Redline attribution (v2)

- [ ] **→ A.** Attribute only where ref-history / Slack / audit names a actor; else “source of change unconfirmed.”
- [ ] **B.** Attribute all Jun 29 citation edits to Christina even when author of original list is unknown.

**Picked A** per timing-framing guidance.

---

## 8. Citation style (v5)

- [ ] **→ A.** Vancouver superscript via Zotero CSL + single `references.bib`.
- [ ] **B.** Rainfall California whitepaper footnote hub (HTML cards only).

**Picked A** for numbered superscripts that cannot drift from the bibliography.

---

## 9. Compare view default pairs

- [ ] **→ A.** Default v3 vs v5 and v1 vs v3; user can pick any two versions.
- [ ] **B.** Only v3 vs v5.

**Picked A.**

---

## 10. Netlify

- [ ] **→ A.** Pre-render `_site/` locally; Netlify serves static files only (matches California pattern).
- [ ] **B.** Netlify build runs Quarto + R on deploy.

**Picked A** — no deploy executed; Kyle chooses when to publish.
