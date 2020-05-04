/var/movement_modifier_instances = movement_modifiers()

/proc/movement_modifiers()
	. = list()
	for(var/type in (typesof(/datum/movement_modifier)-/datum/movement_modifier))
		.[type] = new type

/datum/movement_modifier // These could be just /list(2) or whatever but i like to keep my options open, IIRC kevinz's system on tg has more toggles
	var/additive_slowdown = 0 // additive slowdown, applied first
	var/multiplicative_slowdown = 0 // multiplicative slowdown, applied just before running. Stacks multiplicatively with other multiplicative modifiers, ie.
	var/health_deficiency_adjustment = 0 // additive adjustment to health deficiency, mostly used by reagents which reduce the effect of damage on movement
	var/maximum_slowdown = 100 // maximum slowdown, applied before pulling (and before multiplier)
	var/ask_proc = 0

/datum/movement_modifier/proc/modifiers(mob/user, turf/move_target, running)
	return list(0,0) // list(additive_slowdown, multiplicative_slowdown)

/datum/movement_modifier/status_slowed // these are instantiated by the status effect and the slowdown adjusted there
	additive_slowdown = 10

/datum/movement_modifier/staggered_or_blocking
	additive_slowdown = 0.5

/datum/movement_modifier/disoriented
	additive_slowdown = 9

/datum/movement_modifier/hastened
	additive_slowdown = -0.8

/datum/movement_modifier/janktank
	health_deficiency_adjustment = -50

/datum/movement_modifier/reagent/juggernaut
	health_deficiency_adjustment = -65

/datum/movement_modifier/reagent/morphine
	health_deficiency_adjustment = -50

/datum/movement_modifier/reagent/salicylic_acid
	health_deficiency_adjustment = -25

/datum/movement_modifier/reagent/cocktail_triple
	multiplicative_slowdown = 0.333

/datum/movement_modifier/reagent/energydrink // also meth
	ask_proc = 1

/datum/movement_modifier/reagent/energydrink/modifiers(mob/user, move_target, running)
	if (user.movement_modifiers[/datum/movement_modifier/disoriented])
		return list(0,0.85)
	return list(0,0.5)

// robot legs
/datum/movement_modifier/robotleg_right
	additive_slowdown = -0.25

/datum/movement_modifier/robotleg_left
	additive_slowdown = -0.25

// bioeffects

/datum/movement_modifier/spaceham
	additive_slowdown = 1.5

// mutantraces
/datum/movement_modifier/flubber
	additive_slowdown = -2

/datum/movement_modifier/abomination
	additive_slowdown = 1

/datum/movement_modifier/amphibian
	additive_slowdown = 1.5

/datum/movement_modifier/kudzu
	additive_slowdown = 5

/datum/movement_modifier/zombie
	additive_slowdown = 4

/datum/movement_modifier/revenant
	maximum_slowdown = 3

/datum/movement_modifier/vamp_zombie
	ask_proc = 1

/datum/movement_modifier/vamp_zombie/modifiers(mob/user, move_target, running)
	. = list(4,0)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/mutantrace/vamp_zombie/vamp_zombie = H.mutantrace
		if (!istype(vamp_zombie))
			return
		switch (vamp_zombie.blood_points)
			if (151 to INFINITY)
				.[1] = 1
			if (101 to 151)
				.[1] = 2
			if (51 to 101)
				.[1] = 3
