#!/bin/bash
set -euo pipefail

source buildByond.conf

REF="${SPACEMAN_DMM_REF:?SPACEMAN_DMM_REF is required}"
REPO_URL="https://github.com/SpaceManiac/SpacemanDMM.git"

# Fetch the exact tag or commit
T="$(mktemp -d)"
git init "$T"
git -C "$T" remote add origin "$REPO_URL"

if [[ "$REF" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
  # SHA
  git -C "$T" fetch --depth 1 origin "$REF"
  git -C "$T" checkout "$REF"
else
  # Tag
  git -C "$T" fetch --depth 1 origin "refs/tags/$REF:refs/tags/$REF"
  git -C "$T" checkout "refs/tags/$REF"
fi


# Build selected crates for linux-musl
( cd "$T" && cargo build --release --target x86_64-unknown-linux-musl $(printf -- '-p %s ' "$@") )

# Install suite
dest="$HOME/SpacemanDMM"
mkdir -p "$dest"

for tool in "$@"; do
  cp -f "$T/target/x86_64-unknown-linux-musl/release/$tool" "$dest/"
  chmod +x "$dest/$tool"
done
