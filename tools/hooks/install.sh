#!/bin/sh
set -e

SCRIPT_DIR="$(dirname "$0")"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -z "${HOOKS_INCLUDE_TGUI+x}" ]; then
	printf "Do you want to install TGUI hooks (requires Node.js)? [Y/N]: "
	read -r choice
	case "$choice" in
		y|Y) HOOKS_INCLUDE_TGUI=1 ;;
		*)   HOOKS_INCLUDE_TGUI=0 ;;
	esac
fi
export HOOKS_INCLUDE_TGUI

if [ -z "${HOOKS_INCLUDE_BASE+x}" ]; then
	printf "Do you want to install map merge and icon merge hooks? [Y/N]: "
	read -r base_choice
	case "$base_choice" in
		y|Y) HOOKS_INCLUDE_BASE=1 ;;
		*)   HOOKS_INCLUDE_BASE=0 ;;
	esac
fi
export HOOKS_INCLUDE_BASE

"$SCRIPT_DIR/../bootstrap/python" -m hooks.install "$@"
