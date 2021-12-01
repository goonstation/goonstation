# Git Integration Hooks

*Original source: https://github.com/tgstation/tgstation/tree/master/tools/hooks*

This folder contains installable scripts for Git [hooks] and [merge drivers].
Use of these hooks and drivers is optional and they must be installed
explicitly before they take effect.

To install the current set of hooks, or update if new hooks are added, run
`Install.bat` (Windows) or `tools/hooks/install.sh` (Unix-like) as appropriate.

If your Git GUI does not support a given hook, there is usually a `.bat` file
or other script you can run instead - see the links below for details.

## Hooks

* **Pre-commit**: Runs [mapmerge2] to reduce the diff on any changed maps.
* **DMI merger**: Attempts to [fix icon conflicts] when performing a Git merge.
* **DMM merger**: Attempts to [fix map conflicts] when performing a Git merge.

## Adding New Hooks

New Git [hooks] may be added by creating a file named `<hook-name>.hook` in
this directory. Git determines what hooks are available and what their names
are. The install script copies the `.hook` file into `.git/hooks`, so editing
the `.hook` file will require a reinstall.

New [merge drivers] may be added by adding a shell script named `<ext>.merge`
and updating `.gitattributes` in the root of the repository to include the line
`*.<ext> merge=<ext>`.

`tools/hooks/python.sh` may be used as a trampoline to ensure that the correct
version of Python is found.

[hooks]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
[merge drivers]: https://git-scm.com/docs/gitattributes#_performing_a_three_way_merge
[mapmerge2]: ../mapmerge2/README.md
[fix icon conflicts]: https://tgstation13.org/wiki/Resolving_icon_conflicts
[fix map conflicts]: https://tgstation13.org/wiki/Map_Merger
