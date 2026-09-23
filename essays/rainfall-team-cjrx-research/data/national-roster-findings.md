Findings: three "medium effort" leads, resolved with real data pulls

This closes out three items from leads/story-leads-menu.md that needed a data pull
beyond this folder's existing files. All source files are vendored in this data/
folder alongside this memo; see "How this was verified" at the bottom for exact
provenance.

1. The other 9 voluntary joiners nationwide
----------------------------------------------
Cedars-Sinai is indeed 1 of exactly 10 hospitals nationally that used the
January 2025 voluntary-election window (all effective 01/01/2026, per the vendored
national roster). The other 9:

- Morton Plant Hospital — Tampa-St. Petersburg-Clearwater, FL (CCN 100127)
- Keralty Hospital — Miami-Fort Lauderdale-West Palm Beach, FL (CCN 100284)
- St. Tammany Parish Hospital — Slidell-Mandeville-Covington, LA (CCN 190045)
- UMass Memorial Medical Center — Worcester, MA (CCN 220163)
- Bozeman Health Deaconess Regional Medical Center — Bozeman, MT (CCN 270057)
- Uniontown Hospital — Pittsburgh, PA (CCN 390041)
- Self Regional Healthcare — Greenwood, SC (CCN 420071)
- Providence Holy Family Hospital — Spokane-Spokane Valley, WA (CCN 500077)
- ThedaCare Regional Medical Center-Appleton — Appleton, WI (CCN 520160)

Full list with dates: national-team-voluntary-joiners.csv. Cedars-Sinai is the only
one of the 10 in a top-10-by-population metro area — the other 9 are all
mid-size or small metros. Worth a look for the "who else opted in and why" angle:
several (St. Tammany, Bozeman, Uniontown, Self Regional, ThedaCare) are the kind
of independent or regional systems that would plausibly want the 2% stop-loss
cap TEAM's voluntary track offers without mandatory downside risk exposure — but
that's speculation, not yet confirmed against each hospital's own public statements.

2. Kaiser's 16% vs. Kaiser's real CA footprint
----------------------------------------------
Kaiser holds 17 of California's 107 TEAM slots (15.9%) — matches the number
already established in ownership-concentration-findings.md.

Real denominator, pulled from CMS's national Hospital General Information
registry (all Medicare-enrolled hospitals, not just TEAM participants):
- California has 377 Medicare-registered hospitals of every type; 276 of them
  are Acute Care Hospitals (the rest are psychiatric, critical access,
  children's, and VA/DoD facilities — categorically not eligible for a
  surgical bundled-payment model).
- Kaiser operates 33 Medicare-registered facilities in California under the
  "KAISER FOUNDATION HOSPITAL..." name; 32 are Acute Care Hospitals, 1 is a
  standalone psychiatric facility (Kaiser Permanente Psychiatric Health
  Facility, Santa Clara — CCN 054150) and is excluded from the denominator
  below as a different care setting entirely.

So: Kaiser is 32 of 276 (11.6%) of California's acute-care hospital base, but
17 of 107 (15.9%) of its TEAM roster — overrepresented on TEAM by about
1.4x relative to its actual acute-care hospital footprint, not the roughly-2x
a naive read of "16%" might suggest without a real denominator.

A second, sharper way to state it: 15 of Kaiser's 32 CA acute-care hospitals
(47%) are NOT on the TEAM roster at all, because TEAM only reaches hospitals
inside its randomly-selected CBSAs — Kaiser's footprint outside those CBSAs
(e.g., rural/non-selected metros) simply isn't exposed to the model, mandatory
or voluntary, regardless of ownership. Full hospital-by-hospital list, with a
column marking TEAM-roster membership: kaiser-ca-hospital-footprint.csv.

Caveat: this counts by facility-name pattern match ("KAISER" in the CMS-registered
name), the same method the existing ownership-concentration audit uses and the
same one that audit warns can miss chains branded under a different name. Kaiser
does not appear to run CA hospitals under other brand names (unlike HCA/Prime/
UHS/KPC), but this wasn't independently confirmed against a CMS ownership-linkage
file — flag as a residual limitation, not a settled fact.

3. Did the 34 original mandatory CJR markets carry a different TEAM-selection rate?
-------------------------------------------------------------------------------------
Short answer: yes, and it cuts against a simple story of "same nine markets, same
bad luck twice." Former CJR markets as a whole did worse than the national
average at landing on TEAM's roster — but the formerly-*mandatory* CJR markets
did meaningfully better than the formerly-*voluntary* ones, not the same or worse.

The methodology and its limits, first: CMS's original CJR final rule (80 FR 73299)
randomly selected 67 MSAs into the model in 2016. A 2018 rule cut mandatory
participation down to 34 of those 67 MSAs, selecting "the MSAs with the highest
average historical wage-adjusted episode payments" (per CMS's own November 2017
fact sheet language, echoed in this folder's bibliography). CMS's current CJR
webpage no longer publishes a single named table of which 34 that was — the
live hospital list (July 2024) mixes mandatory and voluntary-continuing hospitals
with no status column, and CMS directs inquiries to CJR@cms.hhs.gov. So this
34-MSA list is **reconstructed**, not copied verbatim from a CMS-published table:
it re-applies CMS's own stated criterion (highest wage-adjusted historical episode
payment) to the original-67 list (pulled from CMS's own "hospital list prior to
February 2018" file) using CMS's own 2015-rule payment data file. The
reconstruction independently reproduces three known, published facts as a check:
Los Angeles-Long Beach-Anaheim stayed mandatory (ranked #25 of 67 by payment),
while San Francisco-Oakland-Hayward (#62) and Modesto (#56) became voluntary —
exactly what CMS's public fact sheets say happened. Full ranked list, with
reconstructed status: cjr-67-msas-reconstructed-mandatory-status.csv.

The overlap, against TEAM's 189 selected CBSAs nationally (out of 387 metro
CBSAs under the current OMB 2023 delineation — a 48.8% baseline selection rate
if TEAM's lottery were blind to CJR history):

| Group                                   | Selected into TEAM | Rate  |
|------------------------------------------|--------------------|-------|
| All 67 original CJR MSAs                 | 19 of 67           | 28.4% |
| 34 former-mandatory CJR MSAs               | 12 of 34           | 35.3% |
| 33 former-voluntary-tier CJR MSAs          | 7 of 33            | 21.2% |
| National baseline (189 of 387 metro CBSAs) | —                  | 48.8% |

Reading: any market that had gone through CJR — mandatory or voluntary tier —
had roughly half the national-average odds of landing on TEAM's list (28.4% vs.
48.8%). Within that group, the former-mandatory markets actually fared better
than the former-voluntary ones (35.3% vs. 21.2%), not worse. LA, at #25 of 67
by historical payment, was one of the higher-ranked former-mandatory markets and
did get selected — the "only one hospital, and it's there voluntarily" story is
about Cedars' unusual status within LA, not about LA itself being under-selected.
Full per-MSA overlap table: cjr-team-overlap.csv.

What this doesn't establish: TEAM's selection is a stratified random sample
(same mechanism as CJR's original lottery, per the folder's first article), so a
28.4%-vs-48.8% gap could be a real pattern or could be within the noise of a
189-of-387 draw — nobody has run a significance test on this, and one hasn't been
attempted here. Treat "former CJR markets did worse" as a documented pattern in
this one draw, not a proven causal or statistical claim.

How this was verified
----------------------
- National TEAM participant list: this repo's vendored data/team_participant_list.csv
  (source: cms.gov/team-model-participant-list, "TEAM Participant List - 2026Q2",
  retrieved 2026-09-21, 720 hospitals across 45 states + DC + PR).
- CMS Hospital General Information (national hospital registry, all Medicare-
  enrolled hospitals): data.cms.gov, dataset xubh-q36u, downloaded 2026-09-22
  directly from CMS's published CSV distribution URL.
- CJR hospital list prior to February 2018 (the original 67-MSA roster):
  cms.gov/files/document/cjr-hospitallist-pre0218xlsx.xlsx, CMS's own archived
  materials page, downloaded 2026-09-22.
- CJR MSA selection criteria (2015 rule payment/population data):
  cms.gov/files/document/cjr-msa-selection-criteria-2015rule.xlsx, downloaded
  2026-09-22.
- Metro CBSA universe count (387): OMB Bulletin No. 23-01 (July 2023 delineations),
  as reported via Census Bureau's metro/micro area program.
- All raw pulls and derived CSVs are vendored in this data/ folder for
  reproducibility; none of this analysis depends on a source that isn't saved
  locally.
