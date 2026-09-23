Project: TEAM / CJR-X research for Rainfall Health

What this is
This folder holds research built while investigating CMS's TEAM bundled-payment model and CJR-X (its 2028 mandatory successor) for Rainfall Health internal use. It started from two published essays on Kyle McAuliffe's Quarto site, californiarainfall.netlify.app ("Why LA Has Only One TEAM Hospital" and the California TEAM white paper), then expanded into: a data audit that found real gaps in that site's own hospital-ownership file, a set of drafted follow-up articles in the same voice, two rounds of verified fact-finding, and a running menu of unwritten story leads with difficulty ratings.

How to use this folder
- Read README.md first for a plain-language map of everything inside.
- sources/bibliography.md is the master citation list. Anything stated as fact elsewhere in this folder should trace back to something in that file. If it doesn't, treat it as unverified and check before using it externally.
- data/ownership-concentration-findings.md documents a real methodology gap in Rainfall's own ca-team-system-affiliations.csv — it undercounts hospital ownership concentration by at least 11 hospitals across four national for-profit chains (HCA, Prime Healthcare, UHS, KPC Health) that the file's name-matching approach missed. This is worth fixing at the source, not just writing about.
- articles/ contains full drafts, matching the tone and structure of Kyle's existing published essays: declarative, specific numbers, sourced, with an explicit "what's still unverified" section in each. New articles should keep that shape — plain statements, no marketing language, every claim traceable to a source, and an honest boundary between "documented" and "speculative."
- leads/story-leads-menu.md is the working backlog. Difficulty ratings reflect how much new data or research each lead needs beyond what's already in this folder.
- facts/ holds two rounds of short, verified facts, meant to be read as a list and expanded on request — each one is a jumping-off point for a deeper piece, not a finished thought.

Working style to preserve
Kyle wants direct answers without over-explanation, full menus of options rather than pre-filtered shortlists, and plain specific language over pitch-style framing. Any claim about a real person (e.g., Abe Sutton, Adam Boehler, Brad Smith) needs an explicit "what isn't established here" boundary — documented career history is fair game, financial-conflict implications are not, unless a primary source (like an OGE-278 disclosure) actually confirms it. When in doubt, say what's unverified rather than smoothing over the gap.

Open items worth picking up next
- Sutton's OGE Form-278 financial disclosure hasn't been located. Would confirm or rule out ongoing financial interest in Rubicon Founders / Honest Health / Evergreen Nephrology.
- CMS's promised safety-net hospital list for TEAM Track 2 — check whether it's been published since Performance Year 1 began.
- Academic medical centers' CA share (UC/Stanford/Loma Linda's 9-of-107) — needs California's total teaching/academic CCN count.
- Whether TEAM's 2022-2024 COVID-era baseline gave some markets easier target prices — needs a trade-press check.

Resolved (see data/national-roster-findings.md)
- National TEAM participant list beyond California — vendored at data/team_participant_list.csv (720 hospitals, 45 states + DC + PR).
- The other 9 voluntary joiners nationwide, Kaiser's CA share vs. its real CA hospital footprint, and the full 34-market CJR-to-TEAM overlap — all three pulled from primary CMS sources 2026-09-22. The 34-mandatory-MSA list is a reconstruction (CMS no longer publishes it as a single named table) built by re-applying CMS's own stated selection criterion to primary source data; it independently reproduces the three publicly known outcomes (LA stayed mandatory, SF and Modesto went voluntary) as a validity check, but flag it as reconstructed, not verbatim-sourced, in anything written from it.
