/datum/lifeprocess/gravity
	var/last_gravity = 1

/datum/lifeprocess/gravity/process(datum/gas_mixture/environment)
	. = ..()
	src.owner.reset_gravity()
	if (src.last_gravity != src.owner.gforce)
		src.do_toggles()

	var/mult = get_multiplier()

	switch(src.owner.gforce)
		if (GRAVITY_MOB_REGULAR_THRESHOLD to 1)
			;
		if (-INFINITY to 0)
			;
		if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
			// lower the gravity, higher the probability, ~1 to ~10%
			if (probmult(round((1 - src.owner.gforce) * 10)))
				if (human_owner)
					switch(rand(1, 3))
						if (1)
							if (!human_owner.traitHolder?.hasTrait("training_miner"))
								human_owner.nauseate(1)
						if (2)
							if (isalive(human_owner))
								boutput(human_owner, SPAN_NOTICE("You [pick("struggle", "exert")] to keep yourself [pick("oriented", "angled properly", "from spinning")] in low-gravity."))
								human_owner.remove_stamina(5)
						if (3)
							boutput(human_owner, SPAN_REGULAR("The low gravity feels a little [pick("disorienting", "odd", "offsetting")]."), "grav_notice")
				else if (robot_owner)
					boutput(human_owner, SPAN_REGULAR("Low gravity  [pick("disorienting", "odd", "offsetting")]."), "grav_notice")
				else if (critter_owner)
					boutput(human_owner, SPAN_REGULAR("The low gravity feels a little [pick("disorienting", "odd", "offsetting")]."), "grav_notice")
		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			// ~19.2+% minimum
			if (probmult(src.owner.gforce * 8))
				if (human_owner)
					switch(rand(1, 4))
						if(1)
							var/obj/item/I = human_owner.equipped()
							if (istype(I))
								boutput(human_owner, SPAN_NOTICE("The extreme gravity [pick("yanks", "tears", "pulls")] [I] from your grip!"))
								human_owner.drop_item(I)
							return
						if (2)
							boutput(human_owner, SPAN_NOTICE("The extreme gravity [pick("forces", "pulls")] you to the ground!"))
							human_owner.changeStatus("knockdown", 1 SECOND)
							human_owner.force_laydown_standup()
							return
						if (3)
							var/damage = rand(3, 5)
							if (istype(human_owner.mutantrace, /datum/mutantrace/skeleton))
								damage *= 2
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] <b>all</b> your bones!"), "grav_notice")
							else
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your skeleton!"), "grav_notice")
							human_owner.TakeDamage("All", damage, damage_type=DAMAGE_CRUSH)
							human_owner.playsound_local(human_owner, 'sound/effects/bones_break.ogg', 40, TRUE)
							return
						if (4)
							boutput(src.owner, SPAN_REGULAR("Extreme gravity severely impedes your movement!"), "grav_notice")
				else if (robot_owner)
					boutput(robot_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your frame!"))
					robot_owner.playsound_local(robot_owner, "sound/effects/creaking_metal[rand(1,2)].ogg", 40, TRUE)
					robot_owner.TakeDamage("chest", rand(2,5), damage_type=DAMAGE_CRUSH)
				else if (critter_owner)
					boutput(src.owner, SPAN_REGULAR("Extreme gravity severely impedes your movement!"), "grav_notice")

		// if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
		// 	;
		// if (1 to GRAVITY_MOB_HIGH_THRESHOLD)
		// 	;

/// Handle atom properties and whatnot that only need to change when gravity changes thresholds
///
/// order of operations matters for consistent thresholds, change with caution
/datum/lifeprocess/gravity/proc/do_toggles()
	// remove old fx
	switch(src.last_gravity)
		if (GRAVITY_MOB_REGULAR_THRESHOLD to 1)
			; // quick no-op for most common gravity
		if (-INFINITY to 0)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_ATOM_FLOATING, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
			animate(src.owner, transform = matrix(), time = 1)
			SPAWN (11) // HACK: 1 longer than animate_drift SPAWN timer :/
				animate(src.owner, transform = matrix(), time = 1)
		if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
			;
		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
		if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
			REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
		// if (1 to GRAVITY_MOB_HIGH_THRESHOLD)
		// 	;

	// add new effects
	switch(src.owner.gforce)
		if (GRAVITY_MOB_REGULAR_THRESHOLD to 1)
			; // quick no-op for most common gravity
		if (-INFINITY to 0)
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			APPLY_ATOM_PROPERTY(src.owner, PROP_ATOM_FLOATING, "gravity")
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
			animate_drift(src.owner, -1, 10, 1)
		// if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
		// 	;
		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			APPLY_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
		if (GRAVITY_MOB_HIGH_THRESHOLD to GRAVITY_MOB_EXTREME_THRESHOLD)
			APPLY_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
		// if (1 to GRAVITY_MOB_HIGH_THRESHOLD)
		// 	;

	src.last_gravity = src.owner.gforce
	src.human_owner?.hud?.update_gravity_indicator()
	src.robot_owner?.hud?.update_gravity_indicator()
	src.critter_owner?.hud?.update_gravity_indicator()

/datum/movement_modifier/gravity
	ask_proc = TRUE

// high gforce adds multiplicative slowdown
/datum/movement_modifier/gravity/modifiers(mob/user, turf/move_target, running)
	return list(0, user.gforce > 1 ? user.gforce : 1)
