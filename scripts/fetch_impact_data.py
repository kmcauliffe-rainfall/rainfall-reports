#!/usr/bin/env python3
"""Download primary CMS TEAM impact report datasets with provenance."""

from __future__ import annotations

import json
import sys
from datetime import date
from pathlib import Path
from urllib.request import urlretrieve

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
MANIFEST = DATA / "sources.json"

SOURCES = {
    "team_participant_list.xlsx": {
        "url": "https://www.cms.gov/team-model-participant-list",
        "description": "CMS TEAM participant list (authoritative roster)",
    },
    "cjrx_participant_list.xlsx": {
        "url": "https://www.cms.gov/priorities/innovation/files/cjrx-participant-list.xlsx",
        "description": "CJR-X participant list",
    },
    "team_py1_prelim_target_prices.xlsx": {
        "url": "https://www.cms.gov/priorities/innovation/files/team-py1-prlim-target-prices.xlsx",
        "description": "CMS TEAM PY1 preliminary target prices",
    },
    "census_np2023_t2.xlsx": {
        "url": "https://www2.census.gov/programs-surveys/popproj/tables/2023/2023-summary-tables/np2023-t2.xlsx",
        "description": "U.S. Census Bureau 2023 National Population Projections, Table 2",
    },
}


def main() -> int:
    DATA.mkdir(parents=True, exist_ok=True)
    retrieved = date.today().isoformat()
    manifest: dict = {"retrieved": retrieved, "files": {}}

    for name, meta in SOURCES.items():
        dest = DATA / name
        print(f"Fetching {name} …")
        urlretrieve(meta["url"], dest)
        manifest["files"][name] = {**meta, "path": str(dest.relative_to(ROOT))}

    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {MANIFEST}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
