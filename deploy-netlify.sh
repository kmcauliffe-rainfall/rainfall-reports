#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
quarto render
STAGE="$ROOT/netlify"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R _site/* "$STAGE/"
cp netlify.toml "$STAGE/"
cat > "$STAGE/robots.txt" <<'EOF'
User-agent: *
Disallow: /
EOF
echo "Staged $STAGE — drag to Netlify Drop or: netlify deploy --prod --dir=netlify"
