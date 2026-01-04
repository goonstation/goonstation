#!/usr/bin/env python3
"""Shared Git hook entrypoint for tgui bundle rebuilds."""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

BUNDLE_PATTERN = re.compile(r"^browserassets/src/tgui/.*\.(?:bundle|chunk)\.")
HOOK_NAMES_WITH_BASE = {"post-merge", "post-rewrite"}


def main(argv: list[str]) -> int:
    hook_name = argv[1] if len(argv) > 1 else "hook"

    repo_root = _git_output(["rev-parse", "--show-toplevel"])
    if not repo_root:
        return 0

    os.chdir(repo_root)

    unresolved = _git_list(["diff", "--name-only", "--diff-filter=U"])
    non_bundle_conflicts = [path for path in unresolved if not BUNDLE_PATTERN.match(path)]
    if non_bundle_conflicts:
        print(
            f"tgui hook ({hook_name}): unresolved non-bundle conflicts; skipping rebuild",
            file=sys.stderr,
        )
        return 0

    changed = _determine_changes(hook_name)
    if not changed:
        return 0

    print(f"tgui hook ({hook_name}): rebuilding tgui bundles", flush=True)
    try:
        subprocess.run(["tgui/bin/tgui"] + ["--build"], check=True)
    except subprocess.CalledProcessError as exc:
        print(
            f"tgui hook ({hook_name}): build failed ({exc.returncode}); run tgui/bin/tgui --build manually",
            file=sys.stderr,
        )
        return exc.returncode or 1

    try:
        subprocess.run(["git", "add", "browserassets/src/tgui"], check=True)
    except subprocess.CalledProcessError as exc:
        print(
            f"tgui hook ({hook_name}): unable to stage bundle output ({exc.returncode})",
            file=sys.stderr,
        )
        return exc.returncode or 1

    print(
        f"tgui hook ({hook_name}): rebuild complete; browserassets/src/tgui staged",
        flush=True,
    )
    return 0


def _determine_changes(hook_name: str) -> list[str]:
    if hook_name == "pre-commit":
        if not Path(".git/MERGE_HEAD").exists():
            return []
        return _git_list([
            "diff",
            "--cached",
            "--name-only",
            "--",
            "tgui",
            "browserassets/src/tgui",
        ])

    diff_args: list[str]
    if hook_name in HOOK_NAMES_WITH_BASE:
        base_ref = _git_output(["rev-parse", "--verify", "HEAD@{1}"])
        if base_ref:
            diff_args = ["diff", "--name-only", base_ref, "HEAD", "--", "tgui", "browserassets/src/tgui"]
        else:
            diff_args = ["diff", "--name-only", "HEAD", "--", "tgui", "browserassets/src/tgui"]
    else:
        diff_args = ["diff", "--name-only", "HEAD", "--", "tgui", "browserassets/src/tgui"]

    return _git_list(diff_args)


def _git_output(args: list[str]) -> str | None:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def _git_list(args: list[str]) -> list[str]:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

if __name__ == "__main__":
    sys.exit(main(sys.argv))
