#!/usr/bin/env bash
# Symlink shared repo assets into each standalone report folder (required for Typst PDF).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_STYLES="$ROOT/styles"

link_dir() {
  local report="$1"
  cd "$report"
  ln -sfn ../../assets assets
  ln -sfn ../../fonts fonts
  # Must be a real directory — an old `styles -> ../../styles` symlink would
  # make `rm styles/preamble.typ` delete files in the repo-wide styles/ folder.
  if [[ -L styles || -e styles ]]; then
    rm -rf styles
  fi
  mkdir -p styles
  cp "$REPO_STYLES/preamble.typ" styles/preamble.typ
  cp "$REPO_STYLES/typst-show.typ" styles/typst-show.typ
  if [[ -f "$REPO_STYLES/report.css" ]]; then
    cp "$REPO_STYLES/report.css" styles/report.css
  fi
}

for d in "$ROOT"/states/*/ "$ROOT"/regions/*/ "$ROOT"/newsletter/*/; do
  [[ -d "$d" ]] || continue
  link_dir "$d"
done

echo "Linked assets/, fonts/, and copied styles/*.typ into report folders."
