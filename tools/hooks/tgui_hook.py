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
SKIP_AMEND_ENV = "TGUI_SKIP_MERGE_AMEND"


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

    amend_status = _maybe_amend_merge(repo, hook)
    if amend_status:
        return amend_status

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


def _maybe_amend_merge(repo: pygit2.Repository, hook: str) -> int:
    if hook != "post-merge":
        return 0

    if _env_truthy(SKIP_AMEND_ENV):
        return 0

    commit = _current_commit(repo)
    if not commit or len(commit.parents) <= 1:
        return 0

    if _staged_diff_is_empty():
        return 0

    print("tgui hook (post-merge): amending merge commit to include rebuilt bundles", flush=True)
    result = _rewrite_merge_commit(repo, commit)
    if result != 0:
        print("tgui hook (post-merge): failed to amend merge commit", file=sys.stderr)
    return result


def _env_truthy(var: str) -> bool:
    value = os.environ.get(var)
    if value is None:
        return False
    return value.strip().lower() not in {"", "0", "false", "no"}


def _current_commit(repo: pygit2.Repository) -> pygit2.Commit | None:
    try:
        return repo.head.peel(pygit2.Commit)
    except (KeyError, ValueError):
        return None


def _staged_diff_is_empty() -> bool:
    result = subprocess.run(["git", "diff", "--cached", "--quiet"], check=False)
    return result.returncode == 0


def _rewrite_merge_commit(repo: pygit2.Repository, commit: pygit2.Commit) -> int:
    ref_name = _head_reference_name(repo)
    if not ref_name:
        return 1

    index = repo.index
    try:
        tree_id = index.write_tree()
    except (OSError, pygit2.GitError) as exc:
        print(f"tgui hook (post-merge): write_tree failed ({exc})", file=sys.stderr)
        return 1

    committer = _default_committer(repo, commit)
    parents = [parent.oid for parent in commit.parents]

    try:
        new_oid = repo.create_commit(None, commit.author, committer, commit.message, tree_id, parents)
    except (ValueError, pygit2.GitError) as exc:
        print(f"tgui hook (post-merge): create_commit failed ({exc})", file=sys.stderr)
        return 1

    try:
        if ref_name == "HEAD":
            repo.set_head_detached(new_oid)
        else:
            reference = repo.references[ref_name]
            reference.set_target(new_oid)
    except (KeyError, pygit2.GitError) as exc:
        print(f"tgui hook (post-merge): update reference failed ({exc})", file=sys.stderr)
        return 1

    try:
        repo.reset(repo[new_oid], pygit2.GIT_RESET_MIXED)
    except pygit2.GitError as exc:
        print(f"tgui hook (post-merge): reset failed ({exc})", file=sys.stderr)
        return 1

    try:
        repo.state_cleanup()
    except pygit2.GitError:
        pass

    repo.index.read()
    return 0


def _head_reference_name(repo: pygit2.Repository) -> str | None:
    if repo.head_is_detached:
        return "HEAD"
    try:
        return repo.head.name
    except (AttributeError, ValueError):
        return None


def _default_committer(repo: pygit2.Repository, commit: pygit2.Commit) -> pygit2.Signature:
    try:
        return repo.default_signature
    except (KeyError, ValueError):
        return commit.committer


if __name__ == "__main__":
    sys.exit(main(sys.argv))
