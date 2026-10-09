#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/assets/facsimile"/{v1-jun25,v3-published}
cp -f "$ROOT/sources/layout/jun25-pages/"page-*.png "$ROOT/assets/facsimile/v1-jun25/"
cp -f "$ROOT/sources/layout/published-pages/"page-*.png "$ROOT/assets/facsimile/v3-published/"
mkdir -p "$ROOT/assets/facsimile/v5-final"
# v5 uses regenerated chart PNGs copied at render time; seed with published for static pages until render fills in.
cp -f "$ROOT/sources/layout/published-pages/"page-*.png "$ROOT/assets/facsimile/v5-final/" 2>/dev/null || true
echo "Staged facsimile PNGs under assets/facsimile/"
