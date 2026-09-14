#!/usr/bin/env python3
"""Build draft Quarto reports from rainfall-corp-website TEAM MDX guides."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MDX_DIR = Path("/tmp/team-blogs")

STATES = [
    ("colorado", "CO", "cms-team-colorado-hospitals.mdx"),
    ("florida", "FL", "cms-team-florida-hospitals.mdx"),
    ("louisiana", "LA", "cms-team-louisiana-hospitals.mdx"),
    ("massachusetts", "MA", "cms-team-massachusetts-hospitals.mdx"),
    ("minnesota", "MN", "cms-team-minnesota-hospitals.mdx"),
    ("new-jersey", "NJ", "cms-team-new-jersey-hospitals.mdx"),
    ("new-york", "NY", "cms-team-new-york-hospitals.mdx"),
    ("pennsylvania", "PA", "cms-team-pennsylvania-hospitals.mdx"),
    ("tennessee", "TN", "cms-team-tennessee-hospitals.mdx"),
]

REGIONS = [
    ("norcal-pnw-rockies", "t1", "cms-team-region-norcal-pnw-rockies.mdx"),
    ("socal-southwest-gulf", "t2", "cms-team-region-socal-southwest-gulf.mdx"),
    ("northeast", "t3", "cms-team-region-northeast.mdx"),
    ("south-midwest", "t4", "cms-team-region-south-midwest.mdx"),
]


def parse_front_matter(text: str) -> tuple[dict[str, str], str]:
    if not text.startswith("---"):
        return {}, text
    parts = text.split("---", 2)
    fm_raw, body = parts[1], parts[2]
    meta: dict[str, str] = {}
    for line in fm_raw.splitlines():
        if ":" not in line:
            continue
        key, val = line.split(":", 1)
        meta[key.strip()] = val.strip().strip('"')
    return meta, body


def strip_mdx(body: str) -> str:
    body = re.sub(r"^import .+\n", "", body, flags=re.M)
    body = re.sub(
        r"<BlogTldr>\s*(.*?)\s*</BlogTldr>",
        lambda m: "### Takeaways\n\n" + m.group(1).strip() + "\n",
        body,
        flags=re.S,
    )

    def facts(m: str) -> str:
        items = re.findall(r'"([^"]+)"', m)
        bullets = "\n".join(f"- {i}" for i in items)
        return f"**Fast facts**\n\n{bullets}\n"

    body = re.sub(
        r"<BlogFastFacts\b[^>]*items=\{(\[.*?\])\}\s*/>",
        lambda m: facts(m.group(1)),
        body,
        flags=re.S,
    )
    body = re.sub(r"<BlogChartFigure\b[^>]*/>", "", body)
    body = re.sub(r"<BlogSectionImage\b[^>]*/>", "", body)
    body = re.sub(r"<BlogExpandableImage\b[^>]*/>", "", body)
    body = re.sub(r"<BlogCommentLetterLinks\b[^>]*/>", "", body)
    body = re.sub(r"<YouTube\b[^>]*/>", "", body)
    body = re.sub(r"<BlogLeadQuote[\s\S]*?</BlogLeadQuote>", "", body)
    body = re.sub(r"<BlogPullQuote[\s\S]*?</BlogPullQuote>", "", body)
    body = re.sub(r"<BlogCallout[\s\S]*?</BlogCallout>", "", body)
    body = re.sub(r"<BlogStatCard[\s\S]*?</BlogStatCard>", "", body)
    body = re.sub(r"<BlogQuestion[\s\S]*?</BlogQuestion>", "", body)
    body = re.sub(r"<div class=\"blog-table-scroll[^\"]*\">\s*", "", body)
    body = re.sub(r"</div>\s*", "", body)

    refs = re.search(r"<BlogReferences items=\{(\[.*?\])\}\s*/>", body, flags=re.S)
    ref_md = ""
    if refs:
        entries = re.findall(
            r'\{\s*"id"\s*:\s*(\d+)\s*,\s*"text"\s*:\s*"(.*?)"\s*,\s*"url"\s*:\s*"(.*?)"\s*\}',
            refs.group(1),
            flags=re.S,
        )
        lines = []
        for i, text, url in entries:
            text = text.replace('\\"', '"')
            lines.append(f"{i}. {text} {url}")
        ref_md = "\n".join(lines)
        body = body[: refs.start()] + body[refs.end() :]

    body = re.sub(r"</?[A-Z][A-Za-z0-9]*\b[^>]*>", "", body)
    body = re.sub(r"\n{3,}", "\n\n", body).strip()
    if ref_md:
        body += "\n\n# References\n\n" + ref_md + "\n"
    return body


HEADER = '''---
title: "{title}"
kicker: "{kicker}"
author: "Jennifer Tim-Diamond for Rainfall Health"
date: "September 2026"
draft: true
engine: knitr
format:
  html:
    title-block-banner: false
  typst:
    toc: false
    columns: 1
    papersize: us-letter
    margin:
      x: 0.7in
      y: 0.7in
    mainfont: "DM Sans"
    fontsize: 10.5pt
    font-paths:
      - ../../fonts
    include-in-header:
      - ../../styles/preamble.typ
    title-block-style: none
    keep-typ: false
execute:
  echo: false
  warning: false
  message: false
  fig-format: png
knitr:
  opts_chunk:
    dev: png
---

```{{r}}
#| label: setup
#| include: false
REPORT_KIND <- "{kind}"
REPORT_ID <- "{rid}"
.d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
for (.i in 1:6) {{
  if (file.exists(file.path(.d, "R", "source_report.R"))) {{
    source(file.path(.d, "R", "source_report.R"))
    break
  }}
  .p <- dirname(.d)
  if (identical(.p, .d)) {{
    stop("Could not find rainfall-reports repo root.")
  }}
  .d <- .p
}}
```

::: {{.draft-banner}}
Draft briefing ported from the Rainfall TEAM website guide and wired to the live CMS TEAM roster in this repo. Hospital counts and figures 1–2 recompute on render. Episode-dollar models are not invented here.
:::

::: {{.wp-cover}}
![](`r rel_asset("rainfall-logo.png")`){{.wp-logo}}

<p class="wp-kicker">{kicker_html}</p>

# {title}

<p class="wp-dek">`r SCOPE_N` mandated hospitals · `r SCOPE_CBSA_N` CBSAs · before PY2 (2027)</p>

<p class="wp-meta">Jennifer Tim-Diamond for Rainfall Health · September 2026<br/>{subtitle}</p>
:::

```{{=typst}}
#page(margin: (x: 0.7in, y: 0.75in), footer: none)[
  #set text(font: "DM Sans", fill: rgb("#1e293b"))
  #align(right)[
    #box(height: 22pt, image("../../assets/rainfall-logo.png"))
  ]
  #v(0.7in)
  #text(size: 11pt, weight: 500, fill: rgb("#2b62e7"))[{kicker}]
  #v(0.4em)
  #text(size: 22pt, weight: "bold", fill: rgb("#1e293b"))[
    {title_typst}
  ]
  #v(0.55em)
  #text(size: 12pt, fill: rgb("#475569"))[
    Draft TEAM briefing · live roster counts
  ]
  #v(1.0em)
  #text(size: 10.5pt)[Jennifer Tim-Diamond for Rainfall Health]
  #v(0.2em)
  #text(size: 10pt, fill: rgb("#64748b"))[September 2026]
  #align(bottom)[
    #rect(width: 100%, height: 1.5pt, fill: rgb("#2b62e7"), stroke: none)
    #v(0.35em)
    #text(size: 8pt, fill: rgb("#64748b"))[
      Figures are Rainfall Health analysis and estimates unless otherwise attributed. Not legal, financial, regulatory, or clinical advice.
    ]
  ]
]
```

# 01 · At a glance

Live hospital counts come from `data/territoryHospitals.json` (March 2026 CMS TEAM participant extract). Editorial context (Medicare population, HRRP, LEJR) is carried from the published Rainfall guide and is **not** recomputed from claims.

```{{r}}
#| label: tbl-glance
glance <- tibble::tibble(
  Signal = c("Mandated hospitals", "CBSAs", "Medicare beneficiaries", "HRRP", "Est. annual LEJR"),
  Value = c(
    as.character(SCOPE_N),
    as.character(SCOPE_CBSA_N),
    editorial$medicare,
    editorial$hrrp,
    editorial$lejr
  ),
  `Why it matters` = c(
    editorial$why_hospitals,
    paste("Largest CBSA:", top_cbsa, "(", top_cbsa_n, "hospitals)"),
    "Covered-lives scale",
    "Readmission pressure under episode accountability",
    "Volume concentration"
  )
)
knitr::kable(glance)
```

# 02 · Where the mandate sits

Largest market in this scope: **`r top_cbsa`** (`r top_cbsa_n` hospitals).

```{{r}}
#| label: fig-cbsa
#| fig-cap: "CMS TEAM-mandated hospitals in this scope."
#| out-width: "100%"
knitr::include_graphics("figures/fig1-cbsa.png")
```

```{{r}}
#| label: tbl-cbsa
if (identical(REPORT_KIND, "territory")) {{
  state_table |>
    transmute(State = state, Hospitals = hospitals, `Share (%)` = share_pct) |>
    knitr::kable(digits = 1)
}} else {{
  cbsa_table |>
    transmute(CBSA = cbsa_label, Hospitals = hospitals, `Share (%)` = share_pct) |>
    knitr::kable(digits = 1)
}}
```

```{{r}}
#| label: fig-region
#| fig-cap: "Concentration of TEAM-mandated hospitals."
#| out-width: "100%"
knitr::include_graphics("figures/fig2-region.png")
```

# 03 · Guide narrative (from the website TEAM report)

'''

FOOTER = '''

# Named hospitals (live roster)

```{r}
#| label: tbl-directory
hospitals |>
  dplyr::group_by(state, cbsa_label) |>
  dplyr::summarise(
    Hospitals = dplyr::n(),
    `Named hospitals` = paste(hospital, collapse = " · "),
    .groups = "drop"
  ) |>
  dplyr::arrange(state, dplyr::desc(Hospitals), cbsa_label) |>
  knitr::kable()
```

::: {.wp-disclaimer}
**Disclaimer.** Draft for internal briefing. Counts follow the vendored CMS participant file. Not legal, financial, regulatory, or clinical advice.
:::
'''


def typst_escape(s: str) -> str:
    return s.replace("\\", "\\\\").replace("[", "\\[").replace("]", "\\]")


def write_report(dest: Path, kind: str, rid: str, mdx_name: str, kicker: str) -> None:
    meta, body = parse_front_matter((MDX_DIR / mdx_name).read_text())
    title = meta.get("title", dest.parent.name)
    subtitle = meta.get("subtitle", "")
    narrative = strip_mdx(body)
    header = HEADER.format(
        title=title.replace('"', '\\"'),
        kicker=kicker,
        kicker_html=kicker.title() if kicker != "WHITE PAPER" else "White paper",
        kind=kind,
        rid=rid,
        subtitle=subtitle.replace('"', '\\"'),
        title_typst=typst_escape(title),
    )
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(header + "\n" + narrative + "\n" + FOOTER)
    print("wrote", dest)


def main() -> None:
    for slug, abbr, mdx in STATES:
        write_report(ROOT / "states" / slug / "index.qmd", "state", abbr, mdx, "WHITE PAPER")
    for slug, tid, mdx in REGIONS:
        write_report(ROOT / "regions" / slug / "index.qmd", "territory", tid, mdx, "REGION BRIEFING")


if __name__ == "__main__":
    main()
