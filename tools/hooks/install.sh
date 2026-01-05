#!/bin/sh
set -e

SCRIPT_DIR="$(dirname "$0")"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

printf "Do you want to install TGUI hooks (requires Node.js)? [Y/N]: "
read -r choice

case "$choice" in
	y|Y) export TG_INCLUDE_TGUI_HOOKS=1 ;;
	*)   export TG_INCLUDE_TGUI_HOOKS=0 ;;
esac

printf "Do you want to install map merge and icon merge hooks? [Y/N]: "
read -r base_choice

case "$base_choice" in
	n|N) export TG_INCLUDE_BASE_HOOKS=0 ;;
	*)   export TG_INCLUDE_BASE_HOOKS=1 ;;
esac

"$SCRIPT_DIR/../bootstrap/python" -m hooks.install "$@"
