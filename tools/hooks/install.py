#!/usr/bin/env python3
# hooks/install.py
#
# This script is configured by adding `*.hook` and `*.merge` files in the same
# directory. Such files should be `#!/bin/sh` scripts, usually invoking Python.
# This installer will have to be re-run any time a hook or merge file is added
# or removed, but not when they are changed.
#
# Merge drivers will also need a corresponding entry in the `.gitattributes`
# file.

import os
import stat
import glob
import re
import pygit2
import shlex


def write_hook(fname, command):
    with open(fname, 'w', encoding='utf-8', newline='\n') as f:
        print("#!/bin/sh", file=f)
        print("exec", command, file=f)

    # chmod +x
    st = os.stat(fname)
    if not hasattr(st, 'st_file_attributes'):
        os.chmod(fname, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def _find_stuff(target=None):
    repo_dir = pygit2.discover_repository(target or os.getcwd())
    repo = pygit2.Repository(repo_dir)
    # Strips any active worktree to find the hooks directory.
    root_repo_dir = re.sub(r'/.git/worktrees/[^/]+/', '/.git/', repo_dir)
    hooks_dir = os.path.join(root_repo_dir, 'hooks')
    return repo, hooks_dir


def uninstall(target=None, keep=()):
    repo, hooks_dir = _find_stuff(target)

    # Remove hooks
    for fname in glob.glob(os.path.join(hooks_dir, '*')):
        _, shortname = os.path.split(fname)
        if not fname.endswith('.sample') and f"{shortname}.hook" not in keep:
            print('Removing hook:', shortname)
            os.unlink(fname)

    # Remove merge driver configuration
    for entry in repo.config:
        match = re.match(r'^merge\.([^.]+)\.driver$', entry.name)
        if match and f"{match.group(1)}.merge" not in keep:
            print('Removing merge driver:', match.group(1))
            del repo.config[entry.name]

    return repo


TGUI_ONLY_HOOKS = {'post-merge', 'post-rewrite'}
TGUI_ATTRIBUTE_BEGIN = '# BEGIN tgui hooks (managed)'
TGUI_ATTRIBUTE_END = '# END tgui hooks (managed)'
TGUI_ATTRIBUTE_BODY = (
    '*.bundle.* -binary merge=ours',
    '*.chunk.* -binary merge=ours',
)


def update_info_attributes(repo, enable):
    info_dir = os.path.join(repo.path, 'info')
    attr_path = os.path.join(info_dir, 'attributes')

    original = ''
    if os.path.exists(attr_path):
        with open(attr_path, 'r', encoding='utf-8') as handle:
            original = handle.read()

    filtered = []
    block_present = False
    skipping = False
    for line in original.splitlines():
        if line == TGUI_ATTRIBUTE_BEGIN:
            block_present = True
            skipping = True
            continue
        if skipping:
            if line == TGUI_ATTRIBUTE_END:
                skipping = False
            continue
        filtered.append(line)

    while filtered and not filtered[-1].strip():
        filtered.pop()

    message = None
    if enable:
        if filtered and filtered[-1].strip():
            filtered.append('')
        filtered.extend((TGUI_ATTRIBUTE_BEGIN, *TGUI_ATTRIBUTE_BODY, TGUI_ATTRIBUTE_END))
        message = (
            'tgui merge hook: enabled local bundle auto-resolve during merges',
            '      (safe to disable locally; rebuild always regenerates bundles)'
        )
    elif block_present:
        message = (
            'tgui merge hook: removed local bundle auto-resolve overrides',
            '      (hooks uninstalled or tgui component disabled)'
        )

    changed = False
    if filtered:
        new_text = '\n'.join(filtered) + '\n'
        if new_text != original:
            os.makedirs(info_dir, exist_ok=True)
            with open(attr_path, 'w', encoding='utf-8', newline='\n') as handle:
                handle.write(new_text)
            changed = True
    elif original:
        if os.path.exists(attr_path):
            os.remove(attr_path)
        changed = True

    if message and (enable or block_present or changed):
        for line in message:
            print(line)


def install(target=None, *, include_tgui=True, include_base=True):
    repo, hooks_dir = _find_stuff(target)
    tools_hooks = os.path.split(__file__)[0]

    keep = set()
    for full_path in glob.glob(os.path.join(tools_hooks, '*.hook')):
        _, fname = os.path.split(full_path)
        name, _ = os.path.splitext(fname)

        relative_path = shlex.quote(os.path.relpath(full_path, repo.workdir).replace('\\', '/'))
        base_command = f'{relative_path} "$@"'
        is_tgui_only_hook = name in TGUI_ONLY_HOOKS

        if name == 'pre-commit':
            if not include_tgui and not include_base:
                print('Skipping hook (no components enabled): pre-commit')
                continue

            env_prefix = []
            enabled_parts = []
            if include_tgui:
                enabled_parts.append('tgui')
                env_prefix.append('TGUI_HOOK=1')
            else:
                env_prefix.append('TGUI_HOOK=0')

            if include_base:
                enabled_parts.append('mapmerge')
                env_prefix.append('MAPMERGE_HOOK=1')
            else:
                env_prefix.append('MAPMERGE_HOOK=0')

            descriptor = ' + '.join(enabled_parts) if enabled_parts else 'disabled'
            print(f'Installing hook: pre-commit ({descriptor})')
            command = base_command
            if env_prefix:
                command = f"env {' '.join(env_prefix)} {base_command}"
        else:
            if not include_tgui and is_tgui_only_hook:
                print('Skipping hook (tgui disabled):', name)
                continue

            if not include_base and not is_tgui_only_hook:
                print('Skipping hook (base disabled):', name)
                continue

            print('Installing hook:', name)
            command = base_command

        keep.add(fname)
        write_hook(os.path.join(hooks_dir, name), command)

    # Use libgit2 config manipulation to set the merge driver config.
    for full_path in glob.glob(os.path.join(tools_hooks, '*.merge')):
        # Merge drivers are documented here: https://git-scm.com/docs/gitattributes
        _, fname = os.path.split(full_path)
        name, _ = os.path.splitext(fname)

        if not include_base:
            print('Skipping merge driver (base disabled):', name)
            continue

        print('Installing merge driver:', name)
        keep.add(fname)
        # %P: "real" path of the file, should not usually be read or modified
        # %O: ancestor's version
        # %A: current version, and also the output path
        # %B: other branches' version
        # %L: conflict marker size
        relative_path = shlex.quote(os.path.relpath(full_path, repo.workdir).replace('\\', '/'))
        repo.config[f"merge.{name}.driver"] = f'{relative_path} %P %O %A %B %L'

    repo = uninstall(target, keep=keep)
    if repo is not None:
        update_info_attributes(repo, enable=include_tgui)


def main(argv):
    include_tgui = os.environ.get('TG_INCLUDE_TGUI_HOOKS', '1') != '0'
    include_base = os.environ.get('TG_INCLUDE_BASE_HOOKS', '1') != '0'
    args = list(argv[1:])

    if '--uninstall' in args:
        repo = uninstall()
        if repo is not None:
            update_info_attributes(repo, enable=False)
        return 0

    target = None
    if args:
        if len(args) == 1:
            target = args[0]
        else:
            print("Usage: python -m hooks.install [--uninstall] [path]")
            return 1

    return install(target=target, include_tgui=include_tgui, include_base=include_base)


if __name__ == '__main__':
    import sys
    exit(main(sys.argv))
