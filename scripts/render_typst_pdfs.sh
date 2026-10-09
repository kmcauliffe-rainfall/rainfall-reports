#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
bash scripts/stage_assets.sh

render_pdf() {
  local ver="$1" sub="$2" pages="$3"
  local out="versions/${ver}.pdf"
  local typ="_${ver}.typ"
  echo '#set page(paper: "us-letter", margin: 0pt, fill: white)' > "$typ"
  for i in $(seq 1 "$pages"); do
    ii=$(printf "%02d" "$i")
    echo "#image(\"assets/facsimile/${sub}/page-${ii}.png\", width: 100%)" >> "$typ"
    if [[ "$i" -lt "$pages" ]]; then
      echo "#pagebreak()" >> "$typ"
    fi
  done
  typst compile --root "$ROOT" "$typ" "$out"
  rm -f "$typ"
  echo "Wrote $out"
}

render_pdf "v1-jun25-draft" "v1-jun25" 12
render_pdf "v2-redline-prepub" "v1-jun25" 12
render_pdf "v3-published-jul27" "v3-published" 11
render_pdf "v4-redline-audit" "v3-published" 11

echo "Rendering v5 final (Quarto → Typst)…"
quarto render versions/v5-final.qmd --to typst
cp -f _site/versions/v5-final.pdf versions/v5-final.pdf
echo "Wrote versions/v5-final.pdf"
