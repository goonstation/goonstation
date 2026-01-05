#!/bin/sh
set -e

SCRIPT_DIR="$(dirname "$0")"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -z "${TG_INCLUDE_TGUI_HOOKS+x}" ]; then
	printf "Do you want to install TGUI hooks (requires Node.js)? [Y/N]: "
	read -r choice
	case "$choice" in
		y|Y) TG_INCLUDE_TGUI_HOOKS=1 ;;
		*)   TG_INCLUDE_TGUI_HOOKS=0 ;;
	esac
fi
export TG_INCLUDE_TGUI_HOOKS

if [ -z "${TG_INCLUDE_BASE_HOOKS+x}" ]; then
	printf "Do you want to install map merge and icon merge hooks? [Y/N]: "
	read -r base_choice
	case "$base_choice" in
		y|Y) TG_INCLUDE_BASE_HOOKS=1 ;;
		*)   TG_INCLUDE_BASE_HOOKS=0 ;;
	esac
fi
export TG_INCLUDE_BASE_HOOKS

"$SCRIPT_DIR/../bootstrap/python" -m hooks.install "$@"
