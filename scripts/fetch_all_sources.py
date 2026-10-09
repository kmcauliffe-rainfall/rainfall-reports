#!/usr/bin/env python3
"""Fetch public datasets and cited documents for the CMS TEAM Impact Report rebuild."""

from __future__ import annotations

import json
import re
import ssl
import sys
from datetime import date
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
SOURCES = ROOT / "sources"
RETRIEVED = date.today().isoformat()

# Each entry: path (relative to ROOT), url, backs, license, kind (data|source)
ENTRIES = [
    {
        "path": "data/team_participant_list.xlsx",
        "url": "https://www.cms.gov/team-model-participant-list",
        "backs": "TEAM hospital counts (national, CA, CBSAs); refs 9, 13; cover stat boxes; Fig scope",
        "license": "U.S. government work (CMS)",
        "kind": "data",
    },
    {
        "path": "data/cjrx_participant_list.xlsx",
        "url": "https://www.cms.gov/priorities/innovation/files/cjrx-participant-list.xlsx",
        "backs": "CJR-X hospital count (~2,217); ref 10; background stat box",
        "license": "U.S. government work (CMS)",
        "kind": "data",
    },
    {
        "path": "data/team_py1_prelim_target_prices.xlsx",
        "url": "https://www.cms.gov/priorities/innovation/files/team-py1-prlim-target-prices.xlsx",
        "backs": "TEAM PY1 target prices; episode economics context (v5)",
        "license": "U.S. government work (CMS)",
        "kind": "data",
    },
    {
        "path": "data/census_np2023_t2.xlsx",
        "url": "https://www2.census.gov/programs-surveys/popproj/tables/2023/2023-summary-tables/np2023-t2.xlsx",
        "backs": "Fig 1 population projections; ref 1; 71M / 82M by 2030/2050",
        "license": "U.S. government work (Census Bureau)",
        "kind": "data",
    },
    {
        "path": "sources/cms/CMS-1808-F-TEAM-final-rule.pdf",
        "url": "https://www.govinfo.gov/content/pkg/FR-2024-08-28/pdf/2024-17021.pdf",
        "backs": "Ref 9 (corrected); 20% cap; 188 CBSAs; $481M savings; 30-day episode; CJR mandatory context",
        "license": "U.S. government work (Federal Register)",
        "kind": "source",
    },
    {
        "path": "sources/cms/CMS-1849-F-CJR-X-final-rule.pdf",
        "url": "https://www.govinfo.gov/content/pkg/FR-2026-08-04/pdf/2026-15833.pdf",
        "backs": "Ref 10 (corrected); CJR-X start Jan 1, 2028",
        "license": "U.S. government work (Federal Register)",
        "kind": "source",
    },
    {
        "path": "sources/cms/team-model-overview.html",
        "url": "https://www.cms.gov/priorities/innovation/innovation-models/team-model",
        "backs": "TEAM overview; Track 1/3 context; participant count on CMS page",
        "license": "U.S. government work (CMS)",
        "kind": "source",
    },
    {
        "path": "sources/aamc/physician-workforce-projections-2024.pdf",
        "url": "https://www.aans.org/wp-content/uploads/2024/05/aamc-2023-workforce-projections-report.pdf",
        "backs": "Ref 7 (corrected text: 86k / 19.9k surgeons by 2036)",
        "license": "AAMC report (third-party host copy); verify against aamc.org for redistribution",
        "kind": "source",
    },
    {
        "path": "sources/hcup/sb281-operating-room-procedures-2018.pdf",
        "url": "https://hcup-us.ahrq.gov/reports/statbriefs/sb281-Operating-Room-Procedures-During-Hospitalization-2018.pdf",
        "backs": "Refs 2, 11; ~37% surgical stays 65+; Fig 2 procedure age shares",
        "license": "AHRQ HCUP Statistical Brief (public domain U.S. gov)",
        "kind": "source",
    },
    {
        "path": "sources/ajrr/AJRR-2024-Annual-Report.pdf",
        "url": "https://connect.registryapps.net/hubfs/AJRR/AJRR%202024%20Annual%20Report.pdf",
        "backs": "Ref 8 (corrected); THA/TKA LOS 3.0→1.1 days",
        "license": "AJRR / AAOS registry report; check AAOS terms for reuse",
        "kind": "source",
    },
    {
        "path": "sources/pmc/hewitt-2016-multimorbidity.pdf",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC4823401/pdf/",
        "backs": "Ref 3 (corrected); 74% multimorbidity; 83.7% over 85 (UK cohort)",
        "license": "PMC open access (BMJ Open); CC BY",
        "kind": "source",
    },
    {
        "path": "sources/pmc/ho-2022-multimorbidity.html",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC9047756/",
        "backs": "Published ref 3 (wrong source for 74% claim); v1–v3 faithful citation",
        "license": "PMC open access",
        "kind": "source",
    },
    {
        "path": "sources/pmc/etzioni-2003-older-adults-discharges.pdf",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC1422682/pdf/",
        "backs": "Published ref 2 (misapplied 40% claim); v1–v3 faithful citation",
        "license": "PMC open access",
        "kind": "source",
    },
    {
        "path": "sources/pmc/gill-2022-frailty-surgery.html",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC9582971/",
        "backs": "Ref 4–6; frailty / dementia surgical mortality",
        "license": "PMC open access (JAMA Surg)",
        "kind": "source",
    },
    {
        "path": "sources/pmc/tang-2020-dementia-surgery.html",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC7066523/",
        "backs": "Ref 4–6; dementia and surgery",
        "license": "PMC open access",
        "kind": "source",
    },
    {
        "path": "sources/pmc/bicket-2024-surgery-prevalence.pdf",
        "url": "https://pmc.ncbi.nlm.nih.gov/articles/PMC11191855/pdf/",
        "backs": "New ref (Bicket); 19.4% surgery prevalence 65+",
        "license": "PMC open access (Ann Surg Open)",
        "kind": "source",
    },
    {
        "path": "sources/pubmed/burnett-2023-medicare-tka-outpatient.html",
        "url": "https://pubmed.ncbi.nlm.nih.gov/36535441/",
        "backs": "Ref 8 (corrected); 57.2% Medicare TKA outpatient billing",
        "license": "PubMed abstract (Elsevier full text may be paywalled)",
        "kind": "source",
    },
    {
        "path": "sources/advisory-board/hospitals-need-to-know-team-2026.html",
        "url": "https://www.advisory.com/topics/policy-and-payment/hospitals-need-to-know-team",
        "backs": "Ref 12 (corrected); 56% lose money; $1.2M average",
        "license": "Advisory Board web content; saved snapshot for citation verification",
        "kind": "source",
    },
    {
        "path": "sources/acs-iac/team-financial-analysis.html",
        "url": "https://www.facs.org/advocacy/transforming-episode-accountability-model/",
        "backs": "Ref 12 / Fig 3; ACS-IAC Table 1 averages; 204,014 cases",
        "license": "ACS web content; saved snapshot",
        "kind": "source",
    },
    {
        "path": "sources/medcity/rainfall-health-funding-feb-2026.html",
        "url": "https://medcitynews.com/2026/02/rainfall-health-funding/",
        "backs": "Ref 15; company facts; $85M CEO quote (v5 labeled projection)",
        "license": "MedCity News article snapshot",
        "kind": "source",
    },
    {
        "path": "sources/census/c2020br-07-65plus-growth.pdf",
        "url": "https://www2.census.gov/library/publications/decennial/2020/census-briefs/c2020br-07.pdf",
        "backs": "Demographic wave; 40.3M→55.8M 2010–2020; boomers 65+ by 2030",
        "license": "U.S. government work (Census Bureau)",
        "kind": "source",
    },
]


def fetch(url: str, dest: Path) -> tuple[str, int | None]:
    dest.parent.mkdir(parents=True, exist_ok=True)
    ctx = ssl.create_default_context()
    req = Request(
        url,
        headers={
            "User-Agent": "RainfallHealth-ImpactReportRebuild/1.0 (research; contact rainfallhealth.com)"
        },
    )
    try:
        with urlopen(req, context=ctx, timeout=120) as resp:
            data = resp.read()
            dest.write_bytes(data)
            return "ok", len(data)
    except HTTPError as e:
        return f"HTTP {e.code}: {e.reason}", None
    except URLError as e:
        return f"URL error: {e.reason}", None
    except Exception as e:
        return f"error: {e}", None


def write_manifest(results: list[dict]) -> None:
    lines = [
        "# Source and data manifest — CMS TEAM Impact Report rebuild",
        "",
        f"Retrieval run date: **{RETRIEVED}** (UTC). Re-run `python3 scripts/fetch_all_sources.py` to refresh.",
        "",
        "Paths are relative to `reports/cms-team-impact/`.",
        "",
        "| File | Backs (claim / figure / ref) | URL | Retrieved | Status | License / notes |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for r in results:
        url = r["url"]
        if len(url) > 60:
            url = url[:57] + "…"
        status = r["status"]
        if r.get("bytes"):
            status = f"{status} ({r['bytes']:,} bytes)"
        lines.append(
            f"| `{r['path']}` | {r['backs']} | {r['url']} | {r['retrieved']} | {status} | {r['license']} |"
        )

    lines.extend(
        [
            "",
            "## Not publicly downloadable (recorded here intentionally)",
            "",
            "| Item | Backs | Why missing | What would unlock |",
            "| --- | --- | --- | --- |",
            "| Rainfall California TEAM-Mandated Hospitals Brief (Apr 2026) | Published ref 13; CA region table in v1–v3 | Internal; not found in Drive/Slack per audit | Exact Apr 2026 region splits; provenance for 110 vs 107 |",
            "| Rainfall 17-system California episode economics model | Published ref 14; p.9 economics chart | Internal model file not found | $2.4M median / $14.5M peak / quartile labels |",
            "| Christina Keny May 5, 2026 v4 Canva draft | Earliest CMS-5540-F Sources line | Not in repository uploads | Authorship trail for ref list |",
            "| ACS NSQIP “procedure-mix 2023–2024” dataset (published ref 11) | Fig 2 age shares | No public dataset located at cited title | Would support published Fig 2 if it exists |",
            "| CMS “MedPAR LOS study” (published ref 8) | LOS 3.0→1.1 | Citation appears fabricated; no CMS pub at that title | N/A — replaced by AJRR + Burnett in v5 |",
            "| Advisory Board “TEAM Financial Impact Model” (published ref 12 title) | $14M / Optum −$6M labels | Title not found; article exists under different name | v5 uses Nation et al. Advisory Board article + Rainfall internal for $14M |",
            "| Deiner 2014 (ref 4) | Frailty background | Paywall / not fetched as PDF in this run | Full-text PDF optional; citation is bibliographic only in v5 |",
            "",
        ]
    )
    (SOURCES / "MANIFEST.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    DATA.mkdir(parents=True, exist_ok=True)
    SOURCES.mkdir(parents=True, exist_ok=True)
    results: list[dict] = []
    for entry in ENTRIES:
        dest = ROOT / entry["path"]
        print(f"→ {entry['path']}")
        status, nbytes = fetch(entry["url"], dest)
        print(f"  {status}")
        results.append(
            {
                **entry,
                "retrieved": RETRIEVED,
                "status": status,
                "bytes": nbytes,
            }
        )

    meta = ROOT / "data" / "fetch_results.json"
    meta.write_text(json.dumps(results, indent=2) + "\n", encoding="utf-8")
    write_manifest(results)
    failed = sum(1 for r in results if r["status"] != "ok")
    print(f"\nDone. {len(results) - failed}/{len(results)} OK. MANIFEST: sources/MANIFEST.md")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
