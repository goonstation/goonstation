/datum/element/lifeprocess/gravity/process(mob/living/target, mult, datum/gas_mixture/environment)
	var/turf/T = get_turf(target)
	if (!istype(T))
		return

	if (target.gforce != T.get_gforce_current())
		target.set_gravity(T)
		target.update_traction(T)

	// Immunity from gravity, so clean up any gravity debuffs.
	if (HAS_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_IMMUNE) || target.nodamage)
		REMOVE_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER, "gravity")
		REMOVE_ATOM_PROPERTY(target, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(target, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		REMOVE_MOVEMENT_MODIFIER(target, /datum/movement_modifier/gravity, "gravity")

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			H.removeOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)
			H.removeOverlayComposition(/datum/overlayComposition/greyout)

		return

	// Inside something whose contents are immune to gravity, so clean up any gravity debuffs.
	if ((target.loc != T) && HAS_ATOM_PROPERTY(target.loc, PROP_ATOM_GRAVITY_IMMUNE_INSIDE))
		REMOVE_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER, "gravity")
		REMOVE_ATOM_PROPERTY(target, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(target, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		REMOVE_MOVEMENT_MODIFIER(target, /datum/movement_modifier/gravity, "gravity")

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			H.removeOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)
			H.removeOverlayComposition(/datum/overlayComposition/greyout)

		return

	// Don't take any on-tick effects while submerged in water.
	if (istype(T, /turf/space/fluid) || (T.active_liquid?.amt >= global.depth_levels[length(global.depth_levels)]))
		return

	var/gforce = target.gforce
	if ((gforce > GFORCE_EARTH_GRAVITY) && target.bioHolder?.HasOneOfTheseEffects("dwarf", "hulk"))
		gforce = max(GFORCE_EARTH_GRAVITY, gforce - GFORCE_EARTH_GRAVITY)

	if ((gforce < GFORCE_MOB_EXTREME_THRESHOLD) && HAS_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER))
		var/gib_counter = GET_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER) - randfloat(0.4, 2.0)
		if (gib_counter > 0)
			APPLY_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER, "gravity", gib_counter)
		else
			REMOVE_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER, "gravity")

	switch (gforce)
		if (GFORCE_GRAVITY_MINIMUM to GFORCE_MOB_REGULAR_THRESHOLD)
			src.handle_low_gravity(target, mult, gforce)

		if (GFORCE_MOB_EXTREME_THRESHOLD to INFINITY)
			src.handle_high_gravity(target, mult, gforce)

/// Handle the effects of low gravity on a (human) target.
/datum/element/lifeprocess/gravity/proc/handle_low_gravity(mob/living/carbon/human/target, mult, gforce)
	if (!istype(target) || target.lying || target.is_spacefaring())
		return

	if (issalvager(target) || isskeleton(target) || ischangeling(target))
		return

	// 0-10% chance of continuing, increasing as gforce decreases.
	var/continue_chance = round((GFORCE_EARTH_GRAVITY - gforce) / 10)
	if ((gforce > GFORCE_GRAVITY_MINIMUM) && !probmult(continue_chance))
		return

	if (probmult(25))
		return

	switch(rand(1, 3))
		// Nausea.
		if (1)
			if (iszombie(target))
				return

			var/obj/item/clothing/suit/suit = target.wear_suit
			if (istype(suit) && HAS_FLAG(suit.c_flags, SPACEWEAR))
				return

			var/obj/item/clothing/under/uniform = target.w_uniform
			if (istype(uniform) && HAS_FLAG(uniform.c_flags, SPACEWEAR))
				return

			boutput(target, SPAN_ALERT("You feel your insides [pick("squirm", "shift", "wiggle", "float")] uncomfortably in low-gravity."), "grav-life")
			target.nauseate(1)

		// Stamina drain.
		if (2)
			// Return if the target is on solid footing or buckled in.
			if ((target.traction == TRACTION_FULL) || target.buckled)
				return

			// Return if the target is wearing an active jetpack.
			if (astype(target.back, /obj/item/tank/jetpack)?.allow_thrust(0.01, target))
				return

			boutput(target, SPAN_ALERT("You [pick("struggle", "take effort", "manage")] to keep yourself [pick("oriented", "angled properly", "right-way-up")] in low-gravity."), "grav-life")
			target.remove_stamina((target.traction == TRACTION_PARTIAL) ? 15 : 30)

		// Blood rushes to the target's head.
		if (3)
			if (isvampire(target) || iszombie(target))
				return

			var/obj/item/clothing/head/head = target.head
			if (istype(head) && HAS_FLAG(head.c_flags, SPACEWEAR))
				return

			var/obj/item/clothing/mask/mask = target.wear_mask
			if (istype(mask) && HAS_FLAG(mask.c_flags, SPACEWEAR))
				return

			var/amount = 3 * (GFORCE_EARTH_GRAVITY - gforce) / GFORCE_EARTH_GRAVITY
			if (prob(50))
				var/obj/item/organ/eye/l_eye = target.get_organ("left_eye")
				var/obj/item/organ/eye/r_eye = target.get_organ("right_eye")

				// Return if both eyes are either missing, robotic, or don't provide sight.
				if ((!l_eye?.provides_sight || l_eye.robotic) && (!r_eye?.provides_sight || r_eye.robotic))
					return

				target.change_eye_blurry(amount, 15)
				boutput(target, SPAN_ALERT("You feel the blood rush to your head, bulging your eyes slightly."), "grav-life")

			else
				target.change_misstep_chance(amount)
				boutput(target, SPAN_ALERT("You feel the blood rush to your head, disorienting you."), "grav-life")

/// Handle the effects of high gravity on a target.
/datum/element/lifeprocess/gravity/proc/handle_high_gravity(mob/living/target, mult, gforce)
	if (gforce >= GFORCE_MOB_PANCAKE_THRESHOLD)
		var/gib_counter = GET_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER)

		if (gib_counter > rand(9, 11))
			global.message_admins("Extremely high gravity ([target.gforce / 100]G) gibbed [target] at [log_loc(target)]")
			logTheThing(LOG_COMBAT, src, "[target] was gibbed with excessive gravity of [target.gforce]G at [log_loc(target)]")
			APPLY_ATOM_PROPERTY(target, PROP_HUMAN_DROP_BRAIN_ON_GIB, "gravity")
			target.gravitygib()
			return

		if (probmult(67))
			boutput(target, SPAN_ALERT("Your entire being strains against the immense gravity. <b>Staying here is not safe!</b>"), "grav_gib_warning")
			APPLY_ATOM_PROPERTY(target, PROP_ATOM_GRAVITY_GIB_COUNTER, "gravity", gib_counter + 0.7)
			return

	// ~9% minimum chance to continue.
	if (!probmult(4 * gforce / GFORCE_EARTH_GRAVITY))
		return

	var/damage = max(rand(GFORCE_MOB_EXTREME_THRESHOLD, gforce), GFORCE_MOB_GREYOUT_THRESHOLD)/GFORCE_EARTH_GRAVITY
	if (ishuman(target))
		var/mob/living/carbon/human/H = target

		switch(rand(1, 3))
			// Drop item.
			if (1)
				var/obj/item/I = H.equipped()
				if (!istype(I))
					return

				boutput(H, SPAN_NOTICE("The extreme gravity [pick("yanks", "tears", "pulls")] [I] from your grip!"), "grav-life")
				H.drop_item(I)

			// Fall over.
			if (2)
				if (H.lying)
					return

				boutput(H, SPAN_NOTICE("The extreme gravity [pick("forces", "pulls")] you to the ground!"), "grav-life")
				H.changeStatus("knockdown", 1 SECOND)
				H.force_laydown_standup()

			// Crinkle bones.
			if (3)
				// Roaches take no damage from high gravity.
				if (istype(H.mutantrace, /datum/mutantrace/roach))
					boutput(H, SPAN_ALERT("The extreme gravity feels [pick("weird", "odd", "disconcerting", "uncomfortable")] on your carapace!"), "grav-life")
					return

				// Skeletons take double damage from high gravity.
				if (istype(H.mutantrace, /datum/mutantrace/skeleton))
					damage *= 2
					boutput(H, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] <b>all</b> your bones!"), "grav-life")
				else
					boutput(H, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your skeleton!"), "grav-life")

				H.TakeDamage("All", round(damage), damage_type = DAMAGE_CRUSH)
				H.playsound_local(H, 'sound/effects/bones_break.ogg', 40, TRUE)

	else if (isrobot(target))
		var/mob/living/silicon/robot/M = target

		switch (rand(1, 3))
			// Strain frame.
			if (1)
				boutput(M, SPAN_ALERT("The extreme gravity [pick("strains", "taxes", "bends")] your frame!"), "grav-life")
				M.playsound_local(M, "sound/effects/creaking_metal[rand(1, 2)].ogg", 40, TRUE)
				M.TakeDamage("chest", damage, damage_type = DAMAGE_CRUSH)

			// Reset tools.
			if (2)
				boutput(M, SPAN_ALERT("The extreme gravity trips your automatic tool reset!"), "grav-life")
				M.uneq_all()

			// Damage arms.
			if (3)
				var/list/choices = list()
				if (M.part_arm_l)
					choices += "l_hand"
				if (M.part_arm_r)
					choices += "r_hand"

				if (!length(choices))
					return

				boutput(M, SPAN_ALERT("The extreme gravity [pick("tugs", "yanks", "pulls")] at your arms!"), "grav-life")
				M.TakeDamage(pick(choices), damage, damage_type = DAMAGE_CRUSH)
