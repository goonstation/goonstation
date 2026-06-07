# Using Command Line git

Sometimes it might be useful to type in git commands directly. To do that press <kbd>Ctrl + \`</kbd> to open PowerShell in VS Code. (Or <kbd>Ctrl + Shift + \`</kbd> to make a new PowerShell window.) Though this might depend on your operating system and default shell configuration.

Cloning your repository: `git clone https://github.com/YOURNAME/goonstation`

Creating a branch: `git checkout -b my-feature-branch`

Staging a file: `git add file.dm`

Staging all changes: `git add -A`

Commiting staged files: `git commit -m "Your commit message."`

Pushing a *new* branch to origin: `git push -u origin my-feature-branch`

Pushing changes from your current branch to origin: `git push`

Pulling changes from the corresponding origin branch to your current branch: `git pull`

Pulling changes from upstream: `git pull upstream master` (make sure you did `git checkout master` first).

The full process of updating your current branch to the current upstream master:
```
git checkout master
git pull upstream master
git checkout my-feature-branch
git rebase master
```

*[repo]: Repository - contains all Goonstation code and etc.
*[fork]: Your personal copy of the repo.
*[remote]: A repo that is not your local one.
*[commit]: A change to the repo that is submitted by someone.
*[diff]: Difference before and after a commit is made.
*[PR]: Pull Request - The changes you request to the upstream.
*[origin]: Your fork of the Goonstation repo
*[upstream]: The master Goonstation repo at https://github.com/goonstation/goonstation
