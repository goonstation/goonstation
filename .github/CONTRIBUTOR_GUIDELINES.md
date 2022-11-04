# Goonstation Contributor Guidelines

[ToC]

{%hackmd @ZeWaka/dark-theme %}

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
