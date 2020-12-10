/var/movement_modifier_instances = movement_modifiers()

/proc/movement_modifiers()
	. = list()
	for(var/type in (typesof(/datum/movement_modifier)-/datum/movement_modifier))
		.[type] = new type

/datum/movement_modifier // These could be just /list(2) or whatever but i like to keep my options open, IIRC kevinz's system on tg has more toggles
	var/additive_slowdown = 0 // additive slowdown, applied first
	var/multiplicative_slowdown = 1 // multiplicative slowdown, applied just before running. Stacks multiplicatively with other multiplicative modifiers
	var/health_deficiency_adjustment = 0 // additive adjustment to health deficiency, mostly used by reagents which reduce the effect of damage on movement
	var/maximum_slowdown = 100 // maximum slowdown, applied before pulling (and before multiplier)
	var/pushpull_multiplier = 1 // multiplier for pushing/pulling speed
	var/space_movement = 0
	var/aquatic_movement = 0
	var/mob_pull_multiplier = 1
	var/ask_proc = 0

/datum/movement_modifier/proc/modifiers(mob/user, turf/move_target, running)
	return list(0,0) // list(additive_slowdown, multiplicative_slowdown)

// equipment

/datum/movement_modifier/equipment // per-mob instanced thing proxying an equip/unequip updated tally from equipment

/datum/movement_modifier/mech_boots
	multiplicative_slowdown = 0.50

/datum/movement_modifier/hulkstrong
	pushpull_multiplier = 0

/datum/movement_modifier/status_slowed // these are instantiated by the status effect and the slowdown adjusted there
	additive_slowdown = 10

/datum/movement_modifier/staggered_or_blocking
	additive_slowdown = 0.4

/datum/movement_modifier/disoriented
	additive_slowdown = 8

/datum/movement_modifier/hastened
	additive_slowdown = -0.8

/datum/movement_modifier/janktank
	health_deficiency_adjustment = -50

/datum/movement_modifier/reagent/juggernaut
	health_deficiency_adjustment = -65

/datum/movement_modifier/reagent/morphine
	health_deficiency_adjustment = -60

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
	additive_slowdown = -0.20

/datum/movement_modifier/robotleg_left
	additive_slowdown = -0.20

/datum/movement_modifier/robottread_right
	additive_slowdown = -0.25

/datum/movement_modifier/robottread_left
	additive_slowdown = -0.25

// robot modifiers
/datum/movement_modifier/robot_base
	health_deficiency_adjustment = -INFINITY
	mob_pull_multiplier = 0.2 //make borgs pull mobs slightly slower than full speed (roundstart light borg will pull a corpse at ~1.3 delay, as opposed to ~1 when unencumbered)

/datum/movement_modifier/robot_oil
	additive_slowdown = -0.5


/datum/movement_modifier/robot_speed_upgrade
	ask_proc = 1
/datum/movement_modifier/robot_speed_upgrade/modifiers(mob/living/silicon/robot/user, move_target, running)
	. = 1
	if(user.part_leg_l)
		. *= 0.75
	if(user.part_leg_r)
		. *= 0.75
	return list(0, .)

/datum/movement_modifier/robot_part/head
	additive_slowdown = -0.2

/datum/movement_modifier/robot_part/arm_left
	additive_slowdown = -0.2

/datum/movement_modifier/robot_part/arm_right
	additive_slowdown = -0.2

/datum/movement_modifier/robot_part/tread_left
	additive_slowdown = -0.25

/datum/movement_modifier/robot_part/tread_right
	additive_slowdown = -0.25

/datum/movement_modifier/robot_part/thruster_left
	additive_slowdown = -0.3

/datum/movement_modifier/robot_part/thruster_right
	additive_slowdown = -0.3

// bioeffects

/datum/movement_modifier/spaceham
	additive_slowdown = 1.5

// mutantraces
/datum/movement_modifier/flubber
	additive_slowdown = -2

/datum/movement_modifier/abomination
	additive_slowdown = 0.6

/datum/movement_modifier/amphibian
	additive_slowdown = 1.2

/datum/movement_modifier/kudzu
	additive_slowdown = 4

/datum/movement_modifier/zombie
	additive_slowdown = 3

/datum/movement_modifier/revenant
	maximum_slowdown = 2

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
				.[1] = 0.7
			if (101 to 151)
				.[1] = 1.6
			if (51 to 101)
				.[1] = 2.8

/datum/movement_modifier/wheelchair
	ask_proc = 1

/datum/movement_modifier/wheelchair/modifiers(mob/living/carbon/human/user, move_target, running)
	var/missing_arms = 0
	var/missing_legs = 0
	if (user.limbs)
		if (!user.limbs.l_leg)
			missing_legs++
		if (!user.limbs.r_leg)
			missing_legs++
		if (!user.limbs.l_arm)
			missing_arms++
		if (!user.limbs.r_arm)
			missing_arms++

	if (user.lying)
		missing_legs = 2
	else if (user.shoes && user.shoes.chained)
		missing_legs = 2

	if (missing_arms == 2)
		return list(100,0) // this was snowflaked in as 300 in previous movement delay code
	else
		var/applied_modifier = 0
		if (missing_legs == 2)
			applied_modifier = 14 - ((2-missing_arms) * 2) // each missing leg adds 7 of movement delay. Each functional arm reduces this by 2.
		else
			applied_modifier = 7*missing_legs

		// apply a negative modifier to balance out what movement_delay would set, times half times the number of arms
		// (2 arms get full negation, 1 negates half, 0 would get nothing except hardcoded to be 100 earlier)
		return list(0-(applied_modifier*((2-missing_arms)*0.5)),1)

// pathogen stuff

/datum/movement_modifier/patho_oxygen
	multiplicative_slowdown = 0.75

// shivering

/datum/movement_modifier/shiver
	additive_slowdown = 2
