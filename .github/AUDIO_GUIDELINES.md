# 🔈 Goonstation Audio Guidelines 🔊

[ToC]

## Creating sound effects for Goonstation

Have a gun that needs to go bang? A pen that needs a satisfying clicking sound? You're in the right place! This document is not a strict ruleset, but meant to show you the *general* guidelines you should adhere to when adding audio to the game.

## Your audio workstation

Whether you're using sounds already made or you'd like to create your own effects, the first thing you'll need is an editing program! No, you don't need to go buy a professional-level digital audio workstation, there are many open-source programs like [Dark Audacity](https://github.com/JamesCrook/audacity/tree/darkaudacity) and [Ardour](https://github.com/Ardour/ardour) that you can use. As long as the the software can do the things you want (recording, editing, producing) and export your project as an .ogg file with different quality settings, you should be fine. Get to know your program of choice, learn the hotkeys and layout so you know what it's capable of.

## Where do I get sound files?

If you're not making or recording an effect from scratch, then you'll probably be utilizing a website like [Freesound](https://freesound.org/). This website is a massive repository of free audio that anyone can have access to after creating a free account. This also means it's one of the most easily accessible places to get sounds, so even just a general search for a sound means you might hear something you recognize! This isn't necessarily a bad thing, but if you want your audio to sound unique then you'll likely want to do some mixing after you've found some effects that you like. It's always preferable to have sound effects that you won't immediately recognize in other games!

Another thing to remember when sourcing sound effects is licensing. Websites like Freesound helpfully require every sound uploaded to have its license attached, but other websites aren't so strict. The onus is on *you* to make sure the sound you want to add to the codebase isn't restricted due to licensing. If the license requires attribution in order to be used, do it properly or find a different sound licensed under [public domain](https://creativecommons.org/publicdomain/zero/1.0/). You can see an example of proper attribution for [CC BY-NC](https://creativecommons.org/licenses/by-nc/3.0/) in this [pull request](https://github.com/goonstation/goonstation/pull/2246). Of course, this doesn't apply to any sounds you make yourself, since you're recording them specifically for Goonstation!

## I have a sound file already, I don't need to edit it!

You still need to edit it. Because the game is a multiplayer environment and players need to download assets, we put an emphasis on *very* small file sizes. The .ogg file type allows for files to be as small as a few kilobytes! Generally, if your sound effect doesn't require a high range to sound good (especially once it's been run through the ingame post-processing reverb) then you should compress the file as much as possible, including making it mono instead of stereo. Exceptions to this would be stuff like gunshots that rely on being "weighty" to sound satisfying, compare similar sounds that are already in the [codebase](https://github.com/goonstation/goonstation/tree/master/sound) to get an idea of how large your file should be. This also applies to the volume of your sound effect, though this isn't as critical since volume can be tweaked by code.

## The soundcache and you

When you've implemented your sound and are ready to PR it, make sure you run `buildSoundList.ps1` in `tools/` directory of the codebase. This is a powershell script that automatically sorts and adds audio files to the sound cache, which is what the game uses to determine which audio files go into the RSC (the thing that clients download when they connect to our servers). If the script is successful, you should see your file added to `soundCache.dm` alongside any other changes you've made for your PR.

When using sound files in the code, we generally prefer the `'foo.ogg'` syntax for including files over the `"foo.ogg"` syntax due to some safety benefits. However, if you need to build a string (e.g. `"foo_[rand(2)].ogg"`) then you will need to use the latter.

## Things to keep in mind

* We're trying to *improve* the soundscape of our game, remember this when you're selecting sounds for the things that you want to add. Audio that's meant to jumpscare through excessive volume, or effects that are deliberately poor for meme/reference reasons won't be accepted.
* Since this is a multiplayer game, sound effects should be tied to player actions or signify some kind of event. Ambient audio can add atmosphere to the soundscape, but it should never be in the forefront. The more sounds that exist due to player agency means the less "filler" audio that's needed in the station's environment.
* In most cases, the shorter the sound length, the better. A long sound file is more likely to cause issues when played in an environment with many other sounds. Avoid unnecessary "empty" space in your file, if you need a long period of time between effects, consider making two files instead of one.
* Think outside the box when trying to record your own effects. A large part of sound design is finding everyday objects and smacking them around to create a sound you're looking for, referred to as [Foley](https://en.wikipedia.org/wiki/Foley_(filmmaking)). Taking multiple sounds and mixing them with waveform-altering effects is a great way to create something unique as well!
* If you have sound-related questions of any sort, there's a dedicated channel in the [Goonstation discord](https://discord.gg/zd8t6pY) for sound design discussion. Check the pins and ask away!
