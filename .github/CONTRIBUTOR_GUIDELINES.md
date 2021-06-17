# Goonstation Contributor Guidelines

[ToC]

{%hackmd @ZeWaka/dark-theme %}

## Making PRs (read before making a PR)
Aside from the actual changes to the repo that you make, opening a PR has some required sections in the initial PR comment. Here are the general guidelines for filling out each section.

### About the PR (Required)
- Here you can describe your PR in as much detail as you like, as opposed to the changelog entry which has to be concise. You're welcome to include pictures, gifs, and videos in this section that can further illustrate what this PR does.

### Why's this needed? (Required)
- Give your reasoning or opinion why you think your change is needed or would improve things.

### Changelog (Optional)
* Use the markdown and text`## Changelog` to denote this section. Be sure to use the code block with `‍```changelog`.
* This section is **not required** for small changes such as: code cleanup, small sprite updates, small code changes that don't result in balance issues, small map changes.
* Use the **minor tag**, `(+)` for things like multiple sprite changes or updates, adding a small feature, making a small change to an existing object/process.
* Use the **major tag**, `(*)` for things that are large changes. Things that affect game balance in any modest way, adding a new feature, updating a whole large suite of sprites, making a large change to a current map such as changing a department layout or moving critical systems or door access.
* The most important thing to remember when making changelog entries is that you keep text **descriptive and concise**. Keep related changelog entries to one line when possible. Unless your PR is touches lots of different systems and is very large or makes lots of balance changes, you'll likely never need more than 3 lines or sentences. Think of what information will be relevant to a player.
* Your suggested changelog can be changed by devs prior to being merged if the merging developer is dissatisfied with it. This will be done by editing the initial comment on the PR made by the contributor so our bot can parse that text and add it to the viewable in-game changelog.
* If you use sprites from another user, do your best to credit them in a changelog bullet entry.
