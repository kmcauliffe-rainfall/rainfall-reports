#!/usr/bin/env bash
#
# Render a standalone Quarto project and stage static files for Netlify.
# Usage: tools/deploy-netlify.sh [report-directory]
# Default report-directory is the current working directory.
#
set -euo pipefail

REPORT_DIR="${1:-$(pwd)}"
REPORT_DIR="$(cd "$REPORT_DIR" && pwd)"
cd "$REPORT_DIR"

STAGE="netlify"

if [[ -f "california.qmd" ]]; then
  QMD="california.qmd"
  BASE="california"
elif [[ -f "index.qmd" ]]; then
  QMD="index.qmd"
  BASE="index"
else
  QMD="$(find . -maxdepth 1 -name '*.qmd' | head -1)"
  QMD="${QMD#./}"
  if [[ -z "$QMD" ]]; then
    echo "ERROR: no .qmd found in $REPORT_DIR" >&2
    exit 1
  fi
  BASE="${QMD%.qmd}"
fi

if ! command -v quarto >/dev/null 2>&1; then
  echo "ERROR: quarto not found on PATH." >&2
  exit 1
fi

echo "==> Rendering $QMD in $REPORT_DIR"
quarto render

HTML_SRC="$REPORT_DIR/${BASE}.html"
PDF_SRC="$REPORT_DIR/${BASE}.pdf"
FILES_SRC="$REPORT_DIR/${BASE}_files"
DATA_SRC="$REPORT_DIR/data-companion"

echo "==> Staging into $STAGE/"
rm -rf "$STAGE"
mkdir -p "$STAGE"

if [[ -f "$HTML_SRC" ]]; then
  cp "$HTML_SRC" "$STAGE/index.html"
else
  echo "ERROR: ${BASE}.html not found after render." >&2
  exit 1
fi

if [[ -d "$FILES_SRC" ]]; then
  cp -R "$FILES_SRC" "$STAGE/"
else
  echo "WARNING: ${BASE}_files/ not found — chart images may be missing." >&2
fi

if [[ -d "$DATA_SRC" ]]; then
  cp -R "$DATA_SRC" "$STAGE/"
fi

if [[ -f "$PDF_SRC" ]]; then
  cp "$PDF_SRC" "$STAGE/${BASE}.pdf"
fi

if [[ -d "$REPORT_DIR/assets" ]]; then
  cp -RL "$REPORT_DIR/assets" "$STAGE/assets"
elif [[ -d "$REPORT_DIR/../../assets" ]]; then
  cp -R "$REPORT_DIR/../../assets" "$STAGE/assets"
fi

if [[ -f "$REPORT_DIR/styles/report.css" ]]; then
  mkdir -p "$STAGE/styles"
  cp "$REPORT_DIR/styles/report.css" "$STAGE/styles/report.css"
fi

if [[ -d "$REPORT_DIR/fonts" ]]; then
  cp -RL "$REPORT_DIR/fonts" "$STAGE/"
fi

if [[ -d "$REPORT_DIR/audio" ]]; then
  cp -R "$REPORT_DIR/audio" "$STAGE/"
fi

if [[ -d "$REPORT_DIR/scripts" ]]; then
  mkdir -p "$STAGE/scripts"
  for js in listen-along.js references-ui.js; do
    if [[ -f "$REPORT_DIR/scripts/$js" ]]; then
      cp "$REPORT_DIR/scripts/$js" "$STAGE/scripts/"
    fi
  done
fi

if [[ -f "$REPORT_DIR/${BASE}-narration.txt" ]]; then
  cp "$REPORT_DIR/${BASE}-narration.txt" "$STAGE/"
fi

if [[ -f netlify.toml ]]; then
  cp netlify.toml "$STAGE/"
fi

cat > "$STAGE/robots.txt" <<'EOF'
User-agent: *
Disallow: /
EOF

echo ""
echo "==> Done. Deploy: drag $STAGE/ to Netlify Drop, or:"
echo "    netlify deploy --prod --dir=$STAGE"
