# Goonstation Contributor Guidelines

[ToC]


## Codebase Expectations

The question this section aims to answer is: "What can I reasonably expect about this codebase, my contributions, and the maintainers?"

Essentially, this is more of a FAQ section.

### Maintainers / Developers

The Goonstation codebase maintainers/developers are a part of the general admin team for the Goonstation servers. They are The People Who Decide What Goes In The Game. You can identify these people on the Discord by their red/amaranth name.
On GitHub, they'll also show up as a member of the Goonstation organization: ![](https://i.imgur.com/xcWNk5p.png).

Please do not unnecessarily ping us directly unless someone explicitly says it's ok. If you have a question for developers, you can generally reach us (or perhaps a fellow contributor can answer your question) in the #imXYZ discord channels, like #imcoder.

### PRs

As for pull requests, there are some limitations on what we accept, detailed more throughly in [Unwanted Contributions](#Unwanted-Contributions) below. Also, we occasionally hold *Feature Freezes*, where PRs adding new features are not accepted, and will be automatically closed unless you seek approval from a developer before submitting it.

Additionally PRs should be as **atomic** as possible, this means each pull request should ideally do **one** thing. Do not mix bugfixes with features, or refactoring with behaviour changes. This may sound pedantic, but properly atomized PRs are a million times easier to review and so are much more likely to be merged faster.

Examples of PR titles that require atomization:
- "Fixes a bug with c-sabers disappearing and increases their damage by 12"
- "Changes singularity.dm to use absolute pathing and fixes some bugs in it"

If you are "re-pathing" (changing the type-paths of existing types) then please include a list of the paths changed, or ideally an [UpdatePaths](https://github.com/goonstation/goonstation/tree/master/tools/UpdatePaths) script for larger scale changes.

As far as a timeline on getting your PR merged, there is none. This is a volunteer-ran project, people have lives outside of the game. It'll get merged when it gets merged. There is also no need to keep your PR up to date with the master branch. Generally, you only should need to touch your PR if there is a merge conflict or a dev asks you to change something.

*Note: Specifically for TGUI PRs, you don't really need to worry about merge conflicts due to their nature*.

### Large scale PRs
Large scale feature or rework PRs should be discussed **before** being written, so that feedback can be given at an early stage and to avoid wasted effort and frustration if the proposed content wouldn't pass review at a later stage.
Examples of these kinds of PR include, but are not limited to:
- Adding a new antagonist/gamemode or majorly reworking an old one
- Adding a major department feature, like a new engine type
- Fundamentally rewriting a major system (atmos, chemistry etc.)
- New maps
- New mutantraces
- New traitor equipment
- New roundstart jobs

The discord [`#Player-Projects`](https://discord.com/channels/182249960895545344/1023681825060700180) forum exists specifically for contributors working on large projects to discuss their plans with other players and developers and to collaborate on group projects, and you are highly encouraged to make a post there to help develop your idea.

Successful examples of such projects include:
- Reworking the Flockmind antagonist (4 collaborators)
- Rewriting the boardgame UI (2 collaborators)
- Adding the nuclear fission engine (single person with sprites from multiple devs)

Writing and submitting a large scale PR without seeking feedback first may result in potentially months of wasted effort, so you do so at your own peril!
### Issues

As this is a purely volunteer open-source game, you may notice we have hundreds of unresolved issues. This is just how it is. Feel free to fix as many bugs as your heart desires - ideally [linking them as closed](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue) with `Fixes #1234` in your fix PR. If you are a member of the triage team (which is very easy to join, [it's a *tiny* form](#Triage-Team)) you can feel free to close duplicate or not-actually-a-bug issues.
More information about issues can be found [here](#Reviewing-Issues)

### Unwanted Contributions

Not all contributions are welcome, as is the nature of things. Obviously, anything that would break our general community or game rules (for example, our anti-bigotry ones) will get immediately closed.

Sometimes, not all PRs work out. Sometimes, they just need a few changes. Other times, they need more work - this could be that it doesn't jive with our design philosophy, we have other concrete reasons we don't want to see it in the game, or perhaps we just don't like it. Depending on the PR and the contributor, we'll generally try and work with the contributor to get the PR to a state amendable to all.

However, if we don't see the PR ever being merged, at the end of the day the project is under the development team's supervision and we have the final word on inclusions. That's just how it goes sometimes - the main repository is open source, and anyone is free to fork the code.

## Personal Information
Git history is (more-or-less) immutable. For your own safety, make sure that you don't have any personal information in your git username or email (check with `git config user.name` and `git config user.email`) and think very hard before using an account you also use for professional work/etc. Github offers a `noreply` email that you can [enable](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address) and use for your git email.

## Triage Team
Have you contributed to the game and want to get more involved? Join our triage team!

These people can close and label issues/PRs but do not have merge rights or any special authority within the community.

Here's the general criteria for people to apply:
* Have actively engaged with Goonstation development (Example: making or reviewing a PR).
* Have demonstrated themselves to be polite and welcoming representatives of the project.
* Are comfortable with following the [Triage Team Guidelines](https://bit.ly/goontriageguidelines).

If you think these apply to (likely so if you're reading this), feel free to fill out the [Triage Team Form](https://bit.ly/goontriageform).
It's __very very basic__, and we accept basically anyone who asks, so don't hesitate if you are interested!

Note: If you don't use Discord, contact a dev about being added, as the form requires a Discord account.

## Making PRs (read before making a PR)
Aside from the actual changes to the repo that you make, opening a PR has some required sections in the initial PR comment. Here are the general guidelines for filling out each section.

### About the PR (Required)
- Here you can describe your PR in as much detail as you like, as opposed to the changelog entry which has to be concise. You're welcome to include pictures, gifs, and videos in this section that can further illustrate what this PR does.

### Why's this needed? (Required)
- Give your reasoning or opinion why you think your change is needed or would improve things.

### Changelog (Optional)
* Use the markdown and text `## Changelog` to denote this section. Be sure to use the code block with `‍```changelog`.
* This section is **not required** for small changes such as: code cleanup, small sprite updates, small code changes that don't result in balance issues, small map changes.
* Use the **minor tag**, `(+)` for things like multiple sprite changes or updates, adding a small feature, making a small change to an existing object/process.
* Use the **major tag**, `(*)` for things that are large changes. Things that affect game balance in any modest way, adding a new feature, updating a whole large suite of sprites, making a large change to a current map such as changing a department layout or moving critical systems or door access.
* The most important thing to remember when making changelog entries is that you keep text **descriptive and concise**. Keep related changelog entries to one line when possible. Unless your PR is touches lots of different systems and is very large or makes lots of balance changes, you'll likely never need more than 3 lines or sentences. Think of what information will be relevant to a player.
* Your suggested changelog can be changed by devs prior to being merged if the merging developer is dissatisfied with it. This will be done by editing the initial comment on the PR made by the contributor so our bot can parse that text and add it to the viewable in-game changelog.
* If you use sprites from another user, do your best to credit them in a changelog bullet entry.

## Reviewing PRs and Issues
As you might be able to tell, there are a lot of pull requests pending at any given moment in time. In order for a pull request to get merged, developers have to review and approve of it, but contributors can also review pull requests, as well as [add labels where appropriate](#Triage-Team).

### Labels
There are many labels that people can use to attach to their PR or to issue reports. These are handy for organisation, as sometimes a developer will go through all the PRs that have a certain label (`Size-XXS`, or `A-Chemistry` for instance) and use that to pick what to review. It's therefore good practise to put labels on your pull requests, and there's a couple ways to add labels:

- The KeywordLabeler bot assigns labels to pull requests based on certain key words in the pull request's description. For instance, putting \[BUG\] or \[FIX\] in the top line of a PR's ddescription will add the `C-bug` label to it. The full list of what key word matches what label can be found in the `.github/keylabeler.yml` file. These are handy for adding labels which start with the prefix `A-`.
- Contributors with [triage permissions](#Triage-Team) can simply add and remove labels from their own PRs, as well as issue reports and other people's PRs.

Some labels are automatically assigned as well, and do certain things:

- Size labels are automatically assigned based on the amount of lines changed.
- Labels like `C-Sprites`, `C-Sound`, and `C-Documentation` are automatically added based on changes to `.dmi` files, `.ogg` files, and `.md` files respectively.
- The `S-Merge-Conflict` label gets applied when your branch is no longer able to be merged with the master branch. Note that this doesn't update instantly, so the better way to check is to see the line of text at the bottom of the PR that reads "This branch has conflicts that must be resolved", listing the conflicting files. You must resolve merge conflicts, otherwise it can't be merged. For TGUI PRs, conflicts with the `.bundle.js` are less urgent to resolve.
- The `S-Stale` label gets added when there has been no activity on a PR for 2 weeks. To get rid of it, simply update the branch with a new commit or post a comment on the PR. The dev-only label `E-Certified-Organic` prevents a PR from going stale.
- The `E-Input-Wanted` label automatically opens a forum thread in the [ideas forum](https://forum.ss13.co/forumdisplay.php?fid=8), so that people can discuss the change.
- The `S-Ready-For-Final-Review` is assigned when two people approve a pull request, indicating to a developer that this is almost ready for merge. It can also be put on manually when a change with `E-Input-Wanted` gains a lot of community support.
- The `S-Needs-Reproducing` label is one put onto an issue report when the person trying to fix that particular bug can't recreate it, or wants to double check that this bug is actually in game and not a oneoff. Issues with this label for more than two weeks get automatically closed. The opposite of this label is `E-Verified`.

The prefixes on the labels are used to group labels together by category, for easier scrolling. They are:
- `A-`, generally for the **a**rea of the game, such as `A-Clothing` or `A-Chemistry`.
- `C-`, for the **c**ategory of the change itself, like `C-Bug`, `C-QoL`, `C-Revert`, `C-Sprites`.
- `E-`, **e**xtra information about the bug/PR itself, such as `E-FUCK`, `E-Complex`, `E-Certified-Organic`.
- `P-`, labelling of the **p**riority of a bug (like `P-Minor`).
- `S-`, to convey **s**tatus information, like `S-Merge-Conflict`, and `S-Stale`.
- `size/`, to indicate the number of lines changed.

### Reviewing Issues
When going through the undoubtedly huge list of issues that exist on the [github issue tracker](https://github.com/goonstation/goonstation/issues), there's a couple things you should know about them. Note that this section assumes you have [triage permissions](#Triage-Team), as you can't really do much to issues without them.

Generally when reviewing an issue, you follow the following steps:
- Add appropriate labels. Sometimes they get overlooked and it makes searching by label more difficult.
- Look for duplicates. Bugs get re-reported several times, especially longer lived ones. If it is indeed a duplicate, you can add the `S-Duplicate` label and then close the issue as not planned.
- Check whether this is actually a bug! Sometimes fully intended features get reported as bugs, and sometimes bugs get fixed without the issue report getting closed.
- Try to reproduce the issue in a local version or on the live server. If you can, you can put the `E-Verified` label on it; if not, you can apply the `S-Needs-Reproducing` label.
- If you plan to try and fix it yourself, you can assign the issue to yourself and then start work on a PR that fixes it.
- If the issue is vague or unclear, you can of course just close it. A verifiable issue would of course just come back and be re-reported later. Alternatively, you can apply the `S-Question` label, and/or start a discussion in the issue report itself by commenting.

There's two ways to close an issue, which are "completed" and "not planned". An issue closed as "completed" means that the issue has been fixed or resolved, usually by a commit or a PR (you can also link a PR to an issue to automatically close it as completed when it is merged). An issue closed as "not planned" means that this issue will not be fixed, as it is either a non-issue, duplicate issue, or unreproducable.

### Reviewing Pull Requests
Anyone can review PRs! When you're browsing through the Files Changed section of the PR (or possibly map/sprite changes in the Checks section), if you spot something that seems a little off, you can start a review by commenting on specific lines. You can also provide a suggested change by clicking the add a suggestion button (or pressing Ctrl + G) while on that line, and provide a change that can be directly committed to the branch of the PR by the author in just one click. Very handy.

To finish off a review, you leave some final overall comments by pressing the green button in the top right, "Review changes", and then you mark your overall tone. You can be neutral, approving, or request changes in your review. Once your review goes through, the author of the PR will also have the opportunity to re-request a review, which normally happens after they implement your requested changes.

If two people leave reviews that approve the requested changes, then the PR automatically gains the `S-Ready-For-Final-Review` label, which is a signal for devs to review it themselves and possibly merge it.

Here's a very basic checklist you can run through when reviewing pull requests (obviously you don't have to do them all in order, and some only apply to certain PRs):
- Is changelog in the PR description written correctly? Are the correct labels applied? Does the PR description in general follow the standard format?
- Are all the checks passing?
- Do sprites look good? `Icondiffbot`` in the checks section can help you see the sprite changes easily.
- Do any added sounds sound good?
- Are licenses on everything as they have to be? Especially important for ported features.
- Think about balance and about whether it fits thematically and mechanically with the game. Is it something we want in the game in the first place? Possibly apply an `Input-Wanted` or a `controversial` tag if it's not clear.
- Read the code to see if there aren't direct bugs.
- Read the code to see if there aren't weird non-obvious buggy interactions with other stuff.
- Read the code to see if there aren't missed checks, edge cases, input verification security checks etc.
- Is the code formatting and cleanliness good enough? Does it adhere to the Goonstation code guidelines (e.g. not using magic numbers, not using `.len`, etc.)?
- Does it actually work? If you can be bothered, you can checkout the code locally and test it to see if it works as it should.
- Other misc stuff (e.g. Is the sound cache rebuilt if new sounds were added? Are there no accidental other changes like removed sprites? Did all the merge conflicts resolutions work properly and not revert things?)
- Could something be done better? Is there anything new that we could teach the PR submitter on an example of their own code? A more optimal way to do things?

While it all comes to a developer's opinion at the end of the day, reviewing code is still extremely helpful for streamlining the final review process.

## License

### What if I change my mind about my contributions being published?

The license Goonstation is licensed under, [CC-BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/3.0/), is irrevocable. The specific legalese is:

> Once something has been published under a CC license, licensees may continue using it according to the license terms for the duration of applicable copyright and similar rights. As a licensor, you may stop distributing under the CC license at any time, but anyone who has access to a copy of the material may continue to redistribute it under the CC license terms.

To simplify it a bit, this means: If your code/sprites/maps/assets are released (e.g. publish it on GitHub in a repo or make a PR) that version of the code is **forever licensed** if someone obtains a copy of it. <u>You cannot ask us nor anyone else to stop using your contributions.</u> This should be considered before publishing your work on GitHub if you're concerned about your legal rights.

### What if I don't like the way someone uses my published contributions?

As long as others abide by the license, you cannot control how the assets are used. However, our license does provide several mechanisms that allow you to choose not to be associated with their version or to uses of their version with which you disagree.

1. First, it is prohibited to use the attribution requirement to suggest that you [endorse or support a particular use](https://creativecommons.org/faq/#do-i-need-to-be-aware-of-anything-else-when-providing-attribution) of your assets.

1. Second, you may waive the attribution requirement, choosing not to be identified as the creator if you wish.

1. Third, if you don't like how your assets were modified or used, it is required that the other person [remove the attribution information upon request](https://wiki.creativecommons.org/wiki/License_Versions#Licensors_may_request_removal_of_attribution).

1. Finally, anyone modifying your assets must [indicate that the original has been modified](https://wiki.creativecommons.org/wiki/License_Versions#Modifications_and_adaptations_must_be_indicated). This ensures that changes made to the original assets–whether or not you approve of them–are not attributed back to you.
