#!/usr/bin/env python3
"""Extract 'stays WITH OR procedures' age shares from HCUP SB281 Figure 2 (page 4).

65–74 share is available in PDF text; 75+ share appears only on the chart — we read
bar labels from a high-resolution crop via OCR when tesseract is available.
"""

from __future__ import annotations

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pymupdf

ROOT = Path(__file__).resolve().parents[1]
PDF = ROOT / "sources/hcup/sb281-operating-room-procedures-2018.pdf"
OUT = ROOT / "data/hcup_or_stay_age_shares.json"
CROP = ROOT / "sources/hcup/figure2-with-or-chart-crop.png"


def parse_6574_from_text(page_text: str) -> float:
    m = re.search(r"65.?74 years \((\d+\.\d+) vs", page_text)
    if not m:
        raise RuntimeError("Could not find 65–74 'with OR' share in PDF text")
    return float(m.group(1))


def ocr_75plus(crop_path: Path) -> float:
    if not shutil.which("tesseract"):
        raise RuntimeError("tesseract not installed for 75+ chart label OCR")
    txt = subprocess.check_output(
        ["tesseract", str(crop_path), "stdout", "-l", "eng", "--psm", "6"],
        text=True,
    )
    # Look for a standalone percentage typical of 75+ bar (~16.8)
    nums = [float(x) for x in re.findall(r"\b(\d+\.\d)\b", txt)]
    candidates = [n for n in nums if 10 <= n <= 25]
    if not candidates:
        raise RuntimeError(f"OCR did not yield 75+ share; got: {txt[:200]!r}")
    return max(candidates)


def main() -> int:
    doc = pymupdf.open(PDF)
    page = doc[3]  # page 4
    pct_6574 = parse_6574_from_text(page.get_text())

    # Figure 2 chart crop (US Letter page, empirically tuned to bar labels column)
    clip = pymupdf.Rect(300, 120, 560, 420)
    pix = page.get_pixmap(matrix=pymupdf.Matrix(3, 3), clip=clip)
    CROP.parent.mkdir(parents=True, exist_ok=True)
    pix.save(str(CROP))

    try:
        pct_75plus = ocr_75plus(CROP)
        if abs(pct_6574 + pct_75plus - 36.5) > 0.25:
            raise RuntimeError(f"OCR sum {pct_6574 + pct_75plus} != 36.5")
        ocr_note = "OCR from figure2-with-or-chart-crop.png (validated ≈36.5% total)"
    except Exception as e:
        pct_75plus = 16.8
        ocr_note = f"Chart label 16.8% (Figure 2, with-OR bar, age 75+); OCR rejected: {e}"

    payload = {
        "source_pdf": str(PDF.relative_to(ROOT)),
        "figure": "Figure 2 — Inpatient stays with OR procedures by age (2018)",
        "pct_65_74_with_or": pct_6574,
        "pct_75_plus_with_or": pct_75plus,
        "pct_65_plus_with_or": round(pct_6574 + pct_75plus, 1),
        "methods": {
            "65_74": "pdftotext / PDF text layer (prose paragraph)",
            "75_plus": ocr_note,
        },
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
