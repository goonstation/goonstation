#!/usr/bin/env python3
"""Shared Git hook entrypoint for tgui bundle rebuilds."""

from __future__ import annotations

import os
import subprocess
import sys

import pygit2

INTERESTING_PREFIXES = ("tgui/", "browserassets/src/tgui/")
BUNDLE_ROOT = "browserassets/src/tgui/"
INDEX_MASK = pygit2.GIT_STATUS_INDEX_NEW | pygit2.GIT_STATUS_INDEX_MODIFIED | pygit2.GIT_STATUS_INDEX_DELETED
WORKDIR_MASK = pygit2.GIT_STATUS_WT_NEW | pygit2.GIT_STATUS_WT_MODIFIED | pygit2.GIT_STATUS_WT_DELETED | pygit2.GIT_STATUS_WT_RENAMED


def main(argv: list[str]) -> int:
    hook = argv[1] if len(argv) > 1 else "hook"

    repo = _open_repo()
    if not repo:
        return 0

    os.chdir(repo.workdir)

    if _has_blocking_conflicts(repo):
        print(f"tgui hook ({hook}): unresolved non-bundle conflicts; skipping", file=sys.stderr)
        return 0

    auto_resolved = _resolve_bundle_conflicts(repo)
    if auto_resolved:
        print(f"tgui hook ({hook}): reset bundle conflicts to ours", flush=True)

    changed = _changed_paths(repo, hook)
    if not changed:
        return 0

    runner = ["tgui\\bin\\tgui.bat"] if os.name == "nt" else ["tgui/bin/tgui"]
    print(f"tgui hook ({hook}): rebuilding tgui bundles", flush=True)

    try:
        subprocess.run(runner + ["--build"], check=True)
    except subprocess.CalledProcessError as exc:
        print(f"tgui hook ({hook}): build failed ({exc.returncode})", file=sys.stderr)
        return exc.returncode or 1

    subprocess.run(["git", "add", "browserassets/src/tgui"], check=True)
    print(f"tgui hook ({hook}): rebuild complete; bundle staged", flush=True)
    return 0


def _open_repo() -> pygit2.Repository | None:
    try:
        repo_path = pygit2.discover_repository(os.getcwd())
    except KeyError:
        return None
    return pygit2.Repository(repo_path)


def _has_blocking_conflicts(repo: pygit2.Repository) -> bool:
    conflicts = repo.index.conflicts
    if not conflicts:
        return False
    for base, ours, theirs in conflicts:
        for entry in (base, ours, theirs):
            if entry and not entry.path.startswith("browserassets/src/tgui/"):
                return True
    return False


def _resolve_bundle_conflicts(repo: pygit2.Repository) -> bool:
    conflicts = repo.index.conflicts
    if not conflicts:
        return False

    targets: set[str] = set()
    for base, ours, theirs in conflicts:
        for entry in (ours, theirs, base):
            if entry and entry.path and entry.path.startswith(BUNDLE_ROOT):
                targets.add(entry.path)
                break

    if not targets:
        return False

    success = True
    for path in sorted(targets):
        result = subprocess.run(["git", "checkout", "--ours", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode != 0:
            print(f"tgui hook: failed to reset {path} to ours (exit {result.returncode})", file=sys.stderr)
            success = False

    repo.index.read()
    return success


def _changed_paths(repo: pygit2.Repository, hook: str) -> set[str]:
    if hook == "pre-commit":
        if not _has_merge_head(repo):
            return set()
        return _status_paths(repo, include_workdir=False)

    if hook == "post-merge":
        return _merge_commit_paths(repo)

    if hook == "post-rewrite":
        return _status_paths(repo, include_workdir=True)

    return _status_paths(repo, include_workdir=True)


def _status_paths(repo: pygit2.Repository, *, include_workdir: bool) -> set[str]:
    mask = INDEX_MASK | (WORKDIR_MASK if include_workdir else 0)
    return {path for path, status in repo.status().items() if status & mask and _interesting(path)}


def _merge_commit_paths(repo: pygit2.Repository) -> set[str]:
    try:
        commit = repo.head.peel(pygit2.Commit)
    except (KeyError, ValueError):
        return set()

    changed: set[str] = set()
    for parent in commit.parents or ():
        for patch in repo.diff(parent, commit):
            changed.update(filter(_interesting, (patch.delta.old_file.path, patch.delta.new_file.path)))
    return changed


def _interesting(path: str | None) -> bool:
    return bool(path and path.startswith(INTERESTING_PREFIXES))


def _has_merge_head(repo: pygit2.Repository) -> bool:
    try:
        repo.lookup_reference("MERGE_HEAD")
        return True
    except KeyError:
        return False


if __name__ == "__main__":
    sys.exit(main(sys.argv))
