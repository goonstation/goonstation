
# Status System

The status system is a robust system Goonstation has to manage any kind of effect on an atom.

Examples of effects:
* Burning
* Cloaked
* Drunk
* Inside someome's pocket
* Gang Member
* Mutiny buff

Most status effects are intended to be applied on mobs, but they can be applied to any atom.

Status effects do not need to have their behaivor defined within them, they can also be checked externally with [hasStatus][/atom/proc/hasStatus] or similar procs.

Example of a basic status effect:

```js
/datum/statusEffect/bababooey
	id = "bababooey"
	name = "Bababooyed"
	desc = "You've been bababooyed!"
	icon_state = "baba"
	unique = 1
	maxDuration = 5 SECONDS

	getTooltip()
		return "Your brain feels like it's melting!"
```

This can then be applied like:
```js
var/mob/living/carbon/human/H = new
H.changeStatus("bababooey", 2 SECONDS)
```

### Additional notes

Non-unique status effects (effects that can be applied several times to the same atom) can not be changed by normal means after they are added. Keep a reference if you need to change them.

Status effect procs have comments in their base definition below. Check there if you want to know more about what they do.

Status effects with a duration of [INFINITE_STATUS] (null) last indefinitely. (Shows as a duration of * in the UI) ((Keep in mind that null is distinct from 0))

## Food Status Effects

Food status effects are a special subclass of status effects.
They are intended to apply special effects to mobs based on the eaten food. Duration of the effects are determined by the quality of the food and reagent contents.

There exists a special wrapper to handle these, [/mob/living/proc/add_food_bonus].

You can only have 4 food status effects active at once, determined by [exclusiveGroup = "Food"][/datum/statusEffect/exclusiveGroup] and [statusGroupLimits][/var/statusGroupLimits].
