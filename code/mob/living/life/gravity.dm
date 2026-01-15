/datum/lifeprocess/gravity
/datum/lifeprocess/gravity/process(datum/gas_mixture/environment)
	. = ..()
	var/turf/T = get_turf(src.owner)

	if (src.owner.gforce != round(T.get_gforce_current(), 0.01))
		src.owner.set_gravity(T)

		src.do_toggles(src.owner.gforce, T.gforce_current)
		src.owner.set_gravity(T.gforce_current)
		src.owner.update_traction(T)

	if (HAS_ATOM_PROPERTY(src.owner, PROP_ATOM_GRAVITY_IMMUNE))
		return

	if (T != src.owner.loc)
		if (HAS_ATOM_PROPERTY(src.owner.loc, PROP_ATOM_GRAVITY_IMMUNE_INSIDE))
			return

	var/mult = get_multiplier()

	switch(src.owner.gforce)
		if (1) // quick no-op for most common gravity
			;
		if (0 to GRAVITY_MOB_REGULAR_THRESHOLD)
			// spacefaring, salvagers, and skeletons immune; lower the gravity, higher the probability, ~2 to ~20%
			if (human_owner && !human_owner.is_spacefaring() && !issalvager(human_owner) && !isskeleton(human_owner) && probmult(round((1 - src.owner.gforce) * 20)))
				switch(rand(1, 3))
					if (1) // nausea
						if (istype(human_owner.wear_suit, /obj/item/clothing/suit/space) || ischangeling(human_owner) || iszombie(human_owner))
							return // wearing a space suit or not caring about organs makes you immune
						boutput(human_owner, SPAN_ALERT("You feel your insides [pick("squirm", "shift", "wiggle", "float")] uncomfortably in low-gravity."))
						human_owner.nauseate(1)
					if (2) // stamina sap
						if (human_owner.traction == TRACTION_FULL)
							return // unless you're on solid footing
						boutput(human_owner, SPAN_ALERT("You [pick("struggle", "take effort", "manage")] to keep yourself [pick("oriented", "angled properly", "right-way-up")] in low-gravity."))
						human_owner.remove_stamina(human_owner.traction == TRACTION_PARTIAL ? 25 : 50)
					if (3) // blood rushes to your head
						if (istype(human_owner.head, /obj/item/clothing/head/helmet/space) || ischangeling(human_owner) || isvampire(human_owner) || iszombie(human_owner))
							return // unless you wear a helmet or "don't have" blood
						var/msg_output = "You feel the blood rush to your head, "
						if (prob(50))
							var/obj/item/organ/eye/leftie = human_owner.get_organ("left_eye")
							var/obj/item/organ/eye/rightie = human_owner.get_organ("right_eye")
							if ((isnull(leftie) || leftie.robotic || !leftie.provides_sight) && (isnull(rightie) || rightie.robotic || !rightie.provides_sight))
								return // both eyes are in the group of states: missing, robotic, or don't provide sight
							human_owner.change_eye_blurry(rand(3,6), 15)
							msg_output += "bulging your eyes slightly."
						else
							human_owner.change_misstep_chance(rand(5,10))
							msg_output += "disorienting you."
						boutput(human_owner, SPAN_ALERT(msg_output))

		if (GRAVITY_MOB_EXTREME_THRESHOLD to INFINITY)
			if (probmult(src.owner.gforce * 8)) // ~19.2+% minimum
				if (human_owner)
					switch(rand(1, 3))
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
								return // roach op
							else if (istype(human_owner.mutantrace, /datum/mutantrace/skeleton))
								damage *= 2 // oof ouch owie my bones x2
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] <b>all</b> your bones!"))
							else
								boutput(human_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your skeleton!"))
							human_owner.TakeDamage("All", round(damage), damage_type=DAMAGE_CRUSH)
							human_owner.playsound_local(human_owner, 'sound/effects/bones_break.ogg', 40, TRUE)
							return
				else if (robot_owner)
					switch (rand(1, 3))
						if(1) // strain frame
							boutput(robot_owner, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your frame!"))
							robot_owner.playsound_local(robot_owner, "sound/effects/creaking_metal[rand(1,2)].ogg", 40, TRUE)
							robot_owner.TakeDamage("chest", rand(GRAVITY_MOB_EXTREME_THRESHOLD, src.owner.gforce), damage_type=DAMAGE_CRUSH)
						if(2) // reset tools
							boutput(robot_owner, SPAN_ALERT("The extreme gravity trips your automatic tool reset!"))
							robot_owner.uneq_all()
						if(3) // damage arms
							var/list/choices = list()
							if (robot_owner.part_arm_l)
								choices += "l_hand"
							if (robot_owner.part_arm_r)
								choices += "r_hand"
							if (length(choices) == 0)
								return // unless you don't have any
							boutput(robot_owner, SPAN_ALERT("The extreme gravity [pick("tugs", "yanks", "pulls")] at your arms!"))
							robot_owner.TakeDamage(pick(choices), rand(GRAVITY_MOB_EXTREME_THRESHOLD, src.owner.gforce), damage_type=DAMAGE_CRUSH)

/// Handle atom properties and whatnot that only need to change when gravity changes thresholds
/datum/lifeprocess/gravity/proc/do_toggles(old_gforce, new_gforce)
	// remove old fx
	switch(old_gforce)
		if (1)
			;
		if (-INFINITY to 0)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		if (GRAVITY_MOB_HIGH_THRESHOLD to INFINITY)
			REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")

	// add new effects
	switch(new_gforce)
		if (1)
			;
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
