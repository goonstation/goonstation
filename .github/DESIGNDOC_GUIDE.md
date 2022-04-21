---
title: How to Write a Good Design Doc (originally by Mothblocks)
---
# How to Write a Good Design Doc [(originally by Mothblocks)](https://hackmd.io/@tgstation/BkzmU9EyK)

Design docs are crucially important for any large feature, and beneficial even for smaller ones. It's important to know not just what you're adding, but *why*. As developers, we'll better know how your ideas will improve the game, as well as being able to help iron out your design. This will also help future contributors not to add/remove content that doesn't align with the principles of your feature, as otherwise they'd just have to guess.

## Write your Design Docs First

Trying to write a design doc after already building the feature is like trying to make the blueprints for a house that's already built. It won't be *useless*, but if you write your design doc first, not only will it help us to clean up your design before you start making it, but it'll help *you* significantly. Writing out your ideas is a great first step to realizing their problems.

## General Writing

- Design docs should be extremely clear to read. Bullet points help a lot.
- Design docs should generally be written in present tense. Saying "wallets make it easier to store multiple IDs" is more preferable to "wallets *will* make it easier to store multiple IDs". This is because it *will* be the present if your PR is merged.
- Design docs *should not* include implementation details. Design docs are written for designers. Implementation details are not relevant to design (unless they are restrictive), and so should either not be included or be in their own doc.

## Important Sections

Note that while none of these are required, you should include them if you know how to fill them in. They make learning the "why" clearer for readers.

Throughout this section, suit sensors will be used as an example. You can see the example design doc [at this link](https://hackmd.io/@Mothblocks/HyKJZoN1Y).

## Abstract

An abstract is a short blurb, about a paragraph or two, succinctly describing your feature. This should mostly be "why", but can include "what".

### Example
Suit sensors are a feature that allow players to report their vitals and their location to anyone with a crew monitor console. They are attached to your jumpsuit, and thus all information will be lost when it is taken off. This means that players who die from game scenarios such as meteors, bad air, etc will have greater potential to be revived, while someone who is explicitly sought after by an antagonist will not. However, this information is publicly available, making the player more likely to be found by antagonists looking to kill them.

## Goals

This is a numbered list clearly detailing your goals for the feature. As per usual, this should be a mixture of both why and what.

### Example
1. Provide players who die in unconvential scenarios the possibility of revival.
2. Give medical a general overview of the health of the station.
3. Give paramedics a clear task to accomplish--saving and finding dead/unhealthy people.

## Non-goals

Just like goals, but the opposite! Every feature has boundaries it won't step over. These should be written as if they start with "We will not...".

### Example
1. Discentivize stealthy antagonist behavior (as a victim). Suit sensors are easy to turn off as an antagonist--by taking off the jumpsuit, chosen because you're probably going to do that anyway if you're a stealthy antagonist, but not so much as one just going on a murder spree. Crew monitor consoles also will not provide a "cache" or similar feature to show people who *used* to have sensors on, but now don't.
2. Discentivize antagonist behavior as the antagonist. It should not be suspicious if a player does not have suit sensors on. To do this, suit sensor information will be easily available, and roundstart suit sensor settings will be randomized, to provide plausible deniability behind settings used by antagonists.

## Content

Now's where you get into clear detail about everything your feature does. **You should still be explaining 'why' things are that way, *as* you describe what.** Be as detailed as possible.

This shouldn't be under a "Content" header, that's just for the sake of this document.

The example is provided in [this example design doc](https://hackmd.io/@Mothblocks/HyKJZoN1Y).

## Alternatives

Provide potential alternatives to your feature, either ones that align with your design values, or ones that don't that you suspect will be suggested. If you are including the latter, make sure to explain why you didn't choose that.

### Example

- Placing suit sensors on something other than the jumpsuit. The jumpsuit was chosen because it's something you're fairly unlikely to change. While lots of people might customize their character in other ways, jumpsuits are generally unchanged as doing so drops your belt, ID, etc.
- Requiring players to engage with medical directly in order to have suit sensors. This severely limits their usability, and would fail goal #2, to provide a general overview of the health of the station.

## Potential Changes

Most of the time you're not going to get the best design first try. It helps to try your best to predict what *could* go wrong, and suggest alternatives that can be taken, without sacrificing your design.

### Example

If it is found that medical is checking suit sensors live, throughout the round, then this poses the issue of defeating non-goal #1. Doctors/paramedics would be able to see antagonistic action as it is happening, and otherwise would be bored looking at vitals updates.

This can be adjusted by making more antagonistic acts defeat suit sensors, such as heavy damage temporarily disabling them, and after death giving them enough time to remove the jumpsuit completely.

Removing exact vitals can also help resolve this, as then the only factors known are the location and their status, which makes it harder to know *as* someone is dying. This has the problem of not helping people who are on the *cusp* of death, but not quite dead.

It could also help to have suit signals require some sort of signal, where they would not work in maintenance, but would work outside of it. This still aligns with goal #1, as most unconventional deaths happen outside of maintenance, while maintenance is meant to be an unsafe place where antagonists can thrive.

It is also possible that this will heavily nerf simpler antagonists, such as blob or spiders, who are unable to take off jumpsuits. If this is seen as a problem, then these simpler antagonists can be given the ability to disable suit sensors just through repeated attack.
