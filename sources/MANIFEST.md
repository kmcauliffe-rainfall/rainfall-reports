# Source and data manifest — CMS TEAM Impact Report rebuild

Retrieval run date: **2026-10-09** (UTC). Re-run `python3 scripts/fetch_all_sources.py` to refresh.

Paths are relative to the repository root (`impact/`).

## Manual mirrors (automated download blocked)

| File | Backs | Original URL | Notes |
| --- | --- | --- | --- |
| `sources/aamc/physician-workforce-projections-2024-aans-mirror.pdf` | Ref 7 | https://www.aamc.org/data-reports/workforce/report/physician-workforce-projections | AAMC site JS challenge; AANS-hosted copy |
| `sources/hcup/sb281-operating-room-procedures-2018.pdf` | Refs 2, 11; **16.8%** on Figure 2 chart | https://hcup-us.ahrq.gov/reports/statbriefs/sb281-Operating-Room-Procedures-During-Hospitalization-2018.pdf | 75+ “with OR” share read from chart crop (`sources/hcup/figure2-with-or-chart-crop.png`) |
| `sources/advisory-board/hospitals-need-to-know-team-2026.html` | Ref 12 | https://www.advisory.com/topics/policy-and-payment/hospitals-need-to-know-team | Manual save |
| `sources/acs-iac/team-financial-analysis.html` | Fig 3 / ACS-IAC | https://www.facs.org/advocacy/transforming-episode-accountability-model/ | Manual save |
| `sources/medcity/rainfall-health-funding-feb-2026.html` | Ref 15 | https://medcitynews.com/2026/02/rainfall-health-funding/ | Manual save (403 to bot) |
| `sources/pubmed/burnett-2023-medicare-tka-outpatient-manual.html` | Ref 8 | https://pubmed.ncbi.nlm.nih.gov/36535441/ | PubMed cookie wall; manual abstract save |
| `sources/audit/Impact-Report-Full-Audit.pptx` | Audit deck | — | Kyle upload |
| `sources/audit/Impact-Report-Full-Audit-Summary.pdf` | Audit summary | — | Kyle upload |

| File | Backs (claim / figure / ref) | URL | Retrieved | Status | License / notes |
| --- | --- | --- | --- | --- | --- |
| `data/team_participant_list.xlsx` | TEAM hospital counts (national, CA, CBSAs); refs 9, 13; cover stat boxes; Fig scope | https://www.cms.gov/team-model-participant-list | 2026-10-09 | ok (61,430 bytes) | U.S. government work (CMS) |
| `data/cjrx_participant_list.xlsx` | CJR-X hospital count (~2,217); ref 10; background stat box | https://www.cms.gov/priorities/innovation/files/cjrx-participant-list.xlsx | 2026-10-09 | ok (96,199 bytes) | U.S. government work (CMS) |
| `data/team_py1_prelim_target_prices.xlsx` | TEAM PY1 target prices; episode economics context (v5) | https://www.cms.gov/priorities/innovation/files/team-py1-prlim-target-prices.xlsx | 2026-10-09 | ok (49,635 bytes) | U.S. government work (CMS) |
| `data/census_np2023_t2.xlsx` | Fig 1 population projections; ref 1; 71M / 82M by 2030/2050 | https://www2.census.gov/programs-surveys/popproj/tables/2023/2023-summary-tables/np2023-t2.xlsx | 2026-10-09 | ok (41,139 bytes) | U.S. government work (Census Bureau) |
| `sources/cms/CMS-1808-F-TEAM-final-rule.pdf` | Ref 9 (corrected); 20% cap; 188 CBSAs; $481M savings; 30-day episode; CJR mandatory context | https://www.govinfo.gov/content/pkg/FR-2024-08-28/pdf/2024-17021.pdf | 2026-10-09 | ok (49,612,911 bytes) | U.S. government work (Federal Register) |
| `sources/cms/CMS-1849-F-CJR-X-final-rule.pdf` | Ref 10 (corrected); CJR-X start Jan 1, 2028 | https://www.govinfo.gov/content/pkg/FR-2026-08-04/pdf/2026-15833.pdf | 2026-10-09 | ok (35,326,930 bytes) | U.S. government work (Federal Register) |
| `sources/cms/team-model-overview.html` | TEAM overview; Track 1/3 context; participant count on CMS page | https://www.cms.gov/priorities/innovation/innovation-models/team-model | 2026-10-09 | ok (208,075 bytes) | U.S. government work (CMS) |
| `sources/aamc/physician-workforce-projections-2024.pdf` | Ref 7 (corrected text: 86k / 19.9k surgeons by 2036) | https://www.aans.org/wp-content/uploads/2024/05/aamc-2023-workforce-projections-report.pdf | 2026-10-09 | ok (1,457,394 bytes) | AAMC report (third-party host copy); verify against aamc.org for redistribution |
| `sources/hcup/sb281-operating-room-procedures-2018.pdf` | Refs 2, 11; ~37% surgical stays 65+; Fig 2 procedure age shares | https://hcup-us.ahrq.gov/reports/statbriefs/sb281-Operating-Room-Procedures-During-Hospitalization-2018.pdf | 2026-10-09 | ok (545,570 bytes) | AHRQ HCUP Statistical Brief (public domain U.S. gov) |
| `sources/ajrr/AJRR-2024-Annual-Report.pdf` | Ref 8 (corrected); THA/TKA LOS 3.0→1.1 days | https://connect.registryapps.net/hubfs/AJRR/AJRR%202024%20Annual%20Report.pdf | 2026-10-09 | ok (10,818,222 bytes) | AJRR / AAOS registry report; check AAOS terms for reuse |
| `sources/pmc/hewitt-2016-multimorbidity.pdf` | Ref 3 (corrected); 74% multimorbidity; 83.7% over 85 (UK cohort) | https://pmc.ncbi.nlm.nih.gov/articles/PMC4823401/pdf/ | 2026-10-09 | ok (1,817 bytes) | PMC open access (BMJ Open); CC BY |
| `sources/pmc/ho-2022-multimorbidity.html` | Published ref 3 (wrong source for 74% claim); v1–v3 faithful citation | https://pmc.ncbi.nlm.nih.gov/articles/PMC9047756/ | 2026-10-09 | ok (179,370 bytes) | PMC open access |
| `sources/pmc/etzioni-2003-older-adults-discharges.pdf` | Published ref 2 (misapplied 40% claim); v1–v3 faithful citation | https://pmc.ncbi.nlm.nih.gov/articles/PMC1422682/pdf/ | 2026-10-09 | ok (1,817 bytes) | PMC open access |
| `sources/pmc/gill-2022-frailty-surgery.html` | Ref 4–6; frailty / dementia surgical mortality | https://pmc.ncbi.nlm.nih.gov/articles/PMC9582971/ | 2026-10-09 | ok (183,554 bytes) | PMC open access (JAMA Surg) |
| `sources/pmc/tang-2020-dementia-surgery.html` | Ref 4–6; dementia and surgery | https://pmc.ncbi.nlm.nih.gov/articles/PMC7066523/ | 2026-10-09 | ok (178,140 bytes) | PMC open access |
| `sources/pmc/bicket-2024-surgery-prevalence.pdf` | New ref (Bicket); 19.4% surgery prevalence 65+ | https://pmc.ncbi.nlm.nih.gov/articles/PMC11191855/pdf/ | 2026-10-09 | ok (1,817 bytes) | PMC open access (Ann Surg Open) |
| `sources/pubmed/burnett-2023-medicare-tka-outpatient.html` | Ref 8 (corrected); 57.2% Medicare TKA outpatient billing | https://pubmed.ncbi.nlm.nih.gov/36535441/ | 2026-10-09 | ok (5,591 bytes) | PubMed abstract (Elsevier full text may be paywalled) |
| `sources/advisory-board/hospitals-need-to-know-team-2026.html` | Ref 12 (corrected); 56% lose money; $1.2M average | https://www.advisory.com/topics/policy-and-payment/hospitals-need-to-know-team | 2026-10-09 | ok (141,433 bytes) | Advisory Board web content; saved snapshot for citation verification |
| `sources/acs-iac/team-financial-analysis.html` | Ref 12 / Fig 3; ACS-IAC Table 1 averages; 204,014 cases | https://www.facs.org/advocacy/transforming-episode-accountability-model/ | 2026-10-09 | ok (142,873 bytes) | ACS web content; saved snapshot |
| `sources/medcity/rainfall-health-funding-feb-2026.html` | Ref 15; company facts; $85M CEO quote (v5 labeled projection) | https://medcitynews.com/2026/02/rainfall-health-funding/ | 2026-10-09 | manual mirror (bot gets HTTP 403) | See manual mirrors table |
| `sources/census/c2020br-07-65plus-growth.pdf` | Demographic wave; 40.3M→55.8M 2010–2020; boomers 65+ by 2030 | https://www2.census.gov/library/publications/decennial/2020/census-briefs/c2020br-07.pdf | 2026-10-09 | ok (1,763,183 bytes) | U.S. government work (Census Bureau) |

## Not publicly downloadable (recorded here intentionally)

| Item | Backs | Why missing | What would unlock |
| --- | --- | --- | --- |
| Rainfall California TEAM-Mandated Hospitals Brief (Apr 2026) | Published ref 13; CA region table in v1–v3 | Internal; not found in Drive/Slack per audit | Exact Apr 2026 region splits; provenance for 110 vs 107 |
| Rainfall 17-system California episode economics model | Published ref 14; p.9 economics chart | Internal model file not found | $2.4M median / $14.5M peak / quartile labels |
| Christina Keny May 5, 2026 v4 Canva draft | Earliest CMS-5540-F Sources line | Not in repository uploads | Authorship trail for ref list |
| ACS NSQIP “procedure-mix 2023–2024” dataset (published ref 11) | Fig 2 age shares | No public dataset located at cited title | Would support published Fig 2 if it exists |
| CMS “MedPAR LOS study” (published ref 8) | LOS 3.0→1.1 | Citation appears fabricated; no CMS pub at that title | N/A — replaced by AJRR + Burnett in v5 |
| Advisory Board “TEAM Financial Impact Model” (published ref 12 title) | $14M / Optum −$6M labels | Title not found; article exists under different name | v5 uses Nation et al. Advisory Board article + Rainfall internal for $14M |
| Deiner 2014 (ref 4) | Frailty background | Paywall / not fetched as PDF in this run | Full-text PDF optional; citation is bibliographic only in v5 |

