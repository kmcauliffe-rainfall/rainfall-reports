Findings: Rainfall's ca-team-system-affiliations.csv undercounts real hospital ownership concentration

Summary
The file tags 48 of California's 107 TEAM hospitals as "Independent / other." At least 11 of those 48 aren't independent at all — they belong to four multi-state, investor-owned hospital chains the file's name-matching approach didn't catch, because none of these chains' names appear inside the hospital's own name.

The gap, hospital by hospital

HCA Healthcare (the largest hospital company in the US) — 1 hospital
Riverside Community Hospital (CCN 050022, Riverside-San Bernardino-Ontario CBSA), currently tagged independent.

Prime Healthcare / Prime Healthcare Foundation — 4 hospitals
Chino Valley Medical Center (050586)
Desert Valley Hospital (050709)
Montclair Hospital Medical Center (050758)
Paradise Valley Hospital (050024)
All four currently tagged independent. Montclair and Paradise Valley operate under Prime Healthcare Foundation, the nonprofit conversion arm — same controlling organization, different tax status.

Universal Health Services (UHS) — 3 hospitals
Corona Regional Medical Center (050329)
Southwest Healthcare Rancho Springs Hospital (050701)
Temecula Valley Hospital (050775)
All three currently tagged independent, all part of UHS's Inland Empire "Southwest Healthcare" brand.

KPC Health — 3 hospitals
Hemet Global Medical Center (050390)
Menifee Global Medical Center (050684)
Victor Valley Global Medical Center (050517)
All three currently tagged independent. Note: "Global Medical Center" branding is KPC-specific in this cluster — do not assume every "Global Medical Center" name nationally is KPC without checking.

What this changes
The report's headline stat — "58 of 107 hospitals belong to 11 multi-hospital systems, about 54%" — becomes at least 69 of 107 (about 64%) once these four chains are added as systems in their own right. More importantly, the current file has no ownership-type axis at all: nonprofit/academic (Kaiser, Sutter, UC, Stanford, etc.) versus investor-owned chain (HCA, Prime, UHS, KPC) isn't distinguished anywhere in the existing methodology.

Smaller findings from the same pass
- Two hospitals share the exact name "Good Samaritan Hospital" — one in Bakersfield-Delano (CCN 050257, legal name "Good Samaritan Hospital, LP"), one in San Jose-Sunnyvale-Santa Clara (CCN 050380). Different owners, no relation as far as this research established — a naming coincidence, not a finding, but worth ruling out before anyone assumes a connection.
- Corporate-suffix scan flagged "Doctors Hospital of Riverside, LLC" (050102) and "Good Samaritan Hospital, LP" (050257) as carrying investor-style legal wrappers in their CMS-registered name itself.
- Several "single hospital" entries in the roster are actually one owner running multiple CCNs under different campus names: Sutter runs California Pacific Medical Center as 3 separate CCNs (Davies 050008, Van Ness 050047, Mission Bernal 050055) plus Alta Bates Summit as 2 (050043, 050305). UCSF runs 3 (Saint Francis 050152, UCSF Medical Center 050454, St. Mary's 050457). Kaiser runs 17. This means the "107 hospitals" figure represents fewer independent decision-makers than it appears — several of what look like separate hospitals are the same executive team's call.

How this was verified
Each ownership claim above was checked against at least one independent public source (news coverage or the parent company's own materials) beyond the hospital's own name — see sources/bibliography.md, "Hospital ownership verification" section, for the specific source per hospital.

Recommended fix
Add an ownership_type column (nonprofit / academic / public-safety-net / investor-owned-chain) and expand the systems this file catches beyond name-recognizable California brands to include known multi-state operators. Cross-reference against CMS's Hospital Compare ownership field or a commercial hospital-ownership database if one is available, rather than relying on name-matching alone.
