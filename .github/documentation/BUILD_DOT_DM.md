# Using __build.dm

The `__build.dm` file contains a lot of helpful `#define` lines for testing your changes locally. By removing the double-slash `//` at the start of the line, you un-comment the define and the next build will include the change. You can enable multiple of them at once, although some of them might clash. There is usually a comment next to the define that explains its effect, so just reading through the file can tell you a lot. The `__build.dm` file isn't used in the actual goonstation servers, but changes to it should not be committed to your branch. Below are some notes and suggetsions on specific defines to make local builds run fast and help de-bugging code issues.

Under the "OPTIONS TO GO FAST" header, you have two options that drastically speed up  loading of the game by disabling certain features. `IM_REALLY_IN_A_FUCKING_HURRY_HERE` is the go to. It skips the atmospherics system setup, skips loading in and generating the mining level, skips the pregame lobby (readying you up instantly and loading you into the game as soon as is possible) and doesn't show any of the normal pop up windows that you normally see when starting the game (rules, changelog, etc).
`GOTTA_GO_FAST_BUT_ZLEVELS_TOO_SLOW` skips loading in the adventure zones in Z2, the debris field in Z3, and the generation of the Z5 mining level. Speeds up the loading slightly. Normally, if you just press <kbd>F5</kbd> by itself, it will load Cogmap 2, but activating this setting will load Atlas instead (which loads faster as it is less detailed). Using map overrides will still work.

Under "convenience options for testing etc" you have different settings which can help you debug and bugtest certain features. You can give all players captain IDs by default, disable all /datum/targetable cooldowns, have each vendor start out with lots of credits so that you can vend things straight away, and test medals. There is also the `STOP_DISTRACTING_ME` define which enables all of the options down until `QUICK_MOB_DELETION`.

`Z_LOG_ENABLE` logs additional data in world.log.

If you are using the [tracy](https://hackmd.io/@goonstation/docs/%2F%40goonstation%2Fcode#Even-Better-Profiler) profiling tool to collect data, you will need to define `TRACY_PROFILER_HOOK` so that it works correctly. There are additional profiling defines below it.

The debugging toggles section contains the `DELETE_QUEUE_DEBUG`, `UPDATE_QUEUE_DEBUG`, `IMAGE_DEL_DEBUG`, `MACHINE_PROCESSING_DEBUG`, `QUEUE_STAT_DEBUG`, `ABSTRACT_VIOLATION` settings, hard ref delete queue logging, reference tracking and garbage collection logging. Most, if not all of these are very expensive to run and will probably cause some slowness. It also contains the `USE_PERSPECTIVE_EDITOR_WALLS` which swaps out the icons used in mapping tools such as strongdmm to use perspective walls, which can be useful to see where wall mounted items will appear on the sprite.

The map overrides section allows you to pick what map to test on. They're sorted in order of special event maps, regular rotation maps, and finally discontinued/gimmick maps (some of which will not work properly without extra work).

There are some unit test defines which are used by the github checks system to make sure that various prefabs and maps work correctly.

Below that is a section with defines that you enable certain modes, such as RP mode and various holiday seasons.

:::info
There are some lines of code down the bottom of `__build.dm` which are required for some defines above it to work properly. As a rule of thumb, if you're not sure what a define does, don't touch it.
:::

Finally, at the bottom, there are testmerge and `BUILD_TIME` defines. Editing the `BUILD_TIME` settings can be useful if testing certain things that use real life time, such as Oshan/Nadir's day night cycling.
