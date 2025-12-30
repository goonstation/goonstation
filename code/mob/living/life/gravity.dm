/datum/lifeprocess/gravity
/datum/lifeprocess/gravity/process(datum/gas_mixture/environment)
	. = ..()
	var/turf/T = get_turf(src.owner)
	if (!T)
		return

	if (src.owner.gforce != T.gforce_current)
		src.owner.set_gravity(T)
		src.do_toggles(src.owner.gforce, T.gforce_current)
		src.owner.gforce = T.gforce_current

	var/mult = get_multiplier()

	switch(src.owner.gforce)
		if (1) // most common
			;
		if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
			// lower the gravity, higher the probability, ~1 to ~10%
			if (human_owner && probmult(round((1 - src.owner.gforce) * 10)))
				switch(rand(1, 2)) // TODO: More effect variety
					if (1) // nausea, wearing a space suit makes you immune
						if (!istype(human_owner.wear_suit, /obj/item/clothing/suit/space))
							human_owner.nauseate(1)
					if (2) // stamina sap
						if (isalive(human_owner))
							boutput(human_owner, SPAN_NOTICE("You [pick("struggle", "exert")] to keep yourself [pick("oriented", "angled properly", "from spinning")] in low-gravity."))
							human_owner.remove_stamina(50)
		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			// ~19.2+% minimum
			if (probmult(src.owner.gforce * 8))
				if (human_owner)
					switch(rand(1, 3)) // TODO: More effect variety
						if(1) // drop item
							var/obj/item/I = human_owner.equipped()
							if (istype(I))
								boutput(human_owner, SPAN_NOTICE("The extreme gravity [pick("yanks", "tears", "pulls")] [I] from your grip!"))
								human_owner.drop_item(I)
							return
						if (2) // fall over
							if (!human_owner.lying)
								boutput(human_owner, SPAN_NOTICE("The extreme gravity [pick("forces", "pulls")] you to the ground!"))
								human_owner.changeStatus("knockdown", 1 SECOND)
								human_owner.force_laydown_standup()
								return
						if (3) // crinkle bones
							var/damage = randfloat(GRAVITY_MOB_EXTREME_THRESHOLD, src.owner.gforce)
							if (istype(human_owner.mutantrace, /datum/mutantrace/roach))
								boutput(human_owner, SPAN_ALERT("The extreme gravity feels [pick("weird", "odd", "disconcerting", "uncomfortable")] on your carapace!"))
								return
							else if (istype(human_owner.mutantrace, /datum/mutantrace/skeleton))
								damage *= 2 // oof ouch owie my bones x2
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] <b>all</b> your bones!"))
							else
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your skeleton!"))
							human_owner.TakeDamage("All", round(damage), damage_type=DAMAGE_CRUSH)
							human_owner.playsound_local(human_owner, 'sound/effects/bones_break.ogg', 40, TRUE)
							return
				else if (robot_owner)  // TODO: More effect variety
					switch (rand(1, 2))
						if(1) // strain frame
							boutput(robot_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your frame!"))
							robot_owner.playsound_local(robot_owner, "sound/effects/creaking_metal[rand(1,2)].ogg", 40, TRUE)
							robot_owner.TakeDamage("chest", rand(GRAVITY_MOB_EXTREME_THRESHOLD, src.owner.gforce), damage_type=DAMAGE_CRUSH)
						if(2)
							boutput(robot_owner, SPAN_ALERT("The extreme gravity resets your active tools!"))
							robot_owner.uneq_all()


/// Handle atom properties and whatnot that only need to change when gravity changes thresholds
/datum/lifeprocess/gravity/proc/do_toggles(old_gforce, new_gforce)
	// remove old fx
	switch(old_gforce)
		if (1)
			; // quick no-op for most common gravity
		if (-INFINITY to 0)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		if (GRAVITY_MOB_HIGH_THRESHOLD to INFINITY)
			REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")

	// add new effects
	switch(new_gforce)
		if (1)
			; // quick no-op for most common gravity
		if (-INFINITY to 0)
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		if (GRAVITY_MOB_HIGH_THRESHOLD to INFINITY)
			APPLY_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")

	src.human_owner?.hud?.update_gravity_indicator()
	src.robot_owner?.hud?.update_gravity_indicator()
	src.critter_owner?.hud?.update_gravity_indicator()

/datum/movement_modifier/gravity
	ask_proc = TRUE

// high gforce adds multiplicative slowdown
/datum/movement_modifier/gravity/modifiers(mob/user, turf/move_target, running)
	return list(0, user.gforce > 1 ? user.gforce : 1)
