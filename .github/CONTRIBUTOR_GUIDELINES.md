# Goonstation Contributor Guidelines

[ToC]

{%hackmd @ZeWaka/dark-theme %}

## Codebase Expectations

The question this section aims to answer is: "What can I reasonably expect about this codebase, my contributions, and the maintainers?"

Essentially, this is more of a FAQ section.

### Maintainers / Developers

The Goonstation codebase maintainers/developers are a part of the general admin team for the Goonstation servers. They are The People Who Decide What Goes In The Game. You can identify these people on the Discord by their red/amaranth name.
On GitHub, they'll also show up as a member of the Goonstation organization: ![](https://i.imgur.com/xcWNk5p.png).

Please do not unnecessarily ping us directly unless someone explicitly says it's ok. If you have a question for developers, you can generally reach us (or perhaps a fellow contributor can answer your question) in the #imXYZ discord channels, like #imcoder.

### PRs

As for pull requests, there are some limitations on what we accept, detailed more throughly in [Unwanted Contributions](#Unwanted-Contributions) below. Also, we occasionally hold *Feature Freezes*, where PRs adding new features are not accepted, and will be automatically closed unless you seek approval from a developer before submitting it.

As far as a timeline on getting your PR merged, there is none. This is a volunteer-ran project, people have lives outside of the game. It'll get merged when it gets merged. There is also no need to keep your PR up to date with the master branch. Generally, you only should need to touch your PR if there is a merge conflict or a dev asks you to change something.

*Note: Specifically for TGUI PRs, you don't really need to worry about merge conflicts due to their nature*.

### Issues

As this is a purely volunteer open-source game, you may notice we have hundreds of unresolved issues. This is just how it is. Feel free to fix as many bugs as your heart desires - ideally [linking them as closed](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue) with `Fixes #1234` in your fix PR. If you are a member of the triage team (which is very easy to join, [it's a *tiny* form](#Triage-Team)) you can feel free to close duplicate or not-actually-a-bug issues.

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
