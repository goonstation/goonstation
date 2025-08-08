#!/bin/bash
set -euo pipefail

source buildByond.conf

PRINT_ONLY=0
if [[ "${1:-}" == "--resolve-ref" ]]; then PRINT_ONLY=1; shift; fi

REF="${SPACEMAN_DMM_REF:?SPACEMAN_DMM_REF is required}"
REPO_URL="https://github.com/SpaceManiac/SpacemanDMM.git"

# --- resolve branch -> commit (else use REF as-is for SHAs) ---
BRANCH_SHA="$(git ls-remote "$REPO_URL" "refs/heads/${REF}" 2>/dev/null | cut -f1 || true)"
RESOLVED_REF="${BRANCH_SHA:-$REF}"

# resolve-only: output for cache key and exit
if [[ $PRINT_ONLY -eq 1 ]]; then
  echo "ref=$RESOLVED_REF" >> "$GITHUB_OUTPUT"
  exit 0
fi

# fast path check for cache hit
if [[ -d "$HOME/SpacemanDMM" ]]; then
  shopt -s nullglob
  existing=( "$HOME/SpacemanDMM"/* )
  [[ ${#existing[@]} -gt 0 ]] && exit 0
fi

# fetch source at ref
T="$(mktemp -d)"
if [[ -n "$BRANCH_SHA" ]]; then
  git clone --depth 1 --branch "$REF" "$REPO_URL" "$T"
else
  git init "$T"
  git -C "$T" remote add origin "$REPO_URL"
  git -C "$T" fetch --depth 1 origin "$RESOLVED_REF"
  git -C "$T" checkout --detach FETCH_HEAD
fi

# build suite
( cd "$T" && bash scripts/build-suite-release.sh )

# install suite
dest="$HOME/SpacemanDMM"
mkdir -p "$dest"
cp -f "$T/target/release/"* "$dest/"
chmod +x "$dest/"* || true
