#!/bin/sh
# tools/hooks/tgui-rebuild.sh
# Shared helper for post-merge style hooks to rebuild the tgui bundle.

set -eu

HOOK_NAME=${1:-hook}
shift || true

# Determine repository root; exit quietly if unavailable (e.g. bare repo).
if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  exit 0
fi

cd "$REPO_ROOT"

' "$UNRESOLVED" | grep -vE '^browserassets/src/tgui/.*\.(bundle|chunk)\.' || true)
# Skip if there are unresolved conflicts outside of tgui bundles.
UNRESOLVED=$(git diff --name-only --diff-filter=U || true)
if [ -n "$UNRESOLVED" ]; then
  NON_BUNDLE=$(printf '%s
' "$UNRESOLVED" | grep -vE '^browserassets/src/tgui/.*\.(bundle|chunk)\.' || true)
  if [ -n "$NON_BUNDLE" ]; then
    echo "tgui hook (${HOOK_NAME}): unresolved conflicts detected (non-bundle files); skipping rebuild" >&2
    exit 0
  fi
fi

# Decide which diff scope to look at based on the invoking hook.
CHANGED_PATHS=""
case "$HOOK_NAME" in
  pre-commit)
    if [ ! -f .git/MERGE_HEAD ]; then
      exit 0
    fi
    CHANGED_PATHS=$(git diff --cached --name-only -- tgui browserassets/src/tgui || true)
    ;;
  post-merge|post-rewrite)
    BASE_REF=""
    if BASE_CANDIDATE=$(git rev-parse --verify HEAD@{1} 2>/dev/null); then
      BASE_REF="$BASE_CANDIDATE"
    fi
    if [ -n "$BASE_REF" ]; then
      CHANGED_PATHS=$(git diff --name-only "$BASE_REF" HEAD -- tgui browserassets/src/tgui || true)
    else
      CHANGED_PATHS=$(git diff --name-only HEAD -- tgui browserassets/src/tgui || true)
    fi
    ;;
  *)
    CHANGED_PATHS=$(git diff --name-only HEAD -- tgui browserassets/src/tgui || true)
    ;;
esac

if [ -z "$CHANGED_PATHS" ]; then
  exit 0
fi

# Ensure the tgui runner exists.
if [ ! -x tgui/bin/tgui ]; then
  echo "tgui hook (${HOOK_NAME}): missing executable tgui/bin/tgui; skipping" >&2
  exit 0
fi

echo "tgui hook (${HOOK_NAME}): rebuilding tgui bundles"
if ! tgui/bin/tgui --build; then
  echo "tgui hook (${HOOK_NAME}): build failed; run tgui/bin/tgui --build manually" >&2
  exit 0
fi

git add browserassets/src/tgui

echo "tgui hook (${HOOK_NAME}): rebuild complete; bundle staged"
