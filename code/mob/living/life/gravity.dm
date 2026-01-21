/datum/lifeprocess/gravity
	VAR_PRIVATE/gib_counter = 0
/datum/lifeprocess/gravity/process(datum/gas_mixture/environment)
	. = ..()
	var/turf/T = get_turf(src.owner)

	if (src.owner.gforce != T.get_gforce_current())
		src.owner.set_gravity(T)
		src.owner.update_traction(T)

	// immunity from gravity, so clean up any gravity debuffs
	if (HAS_ATOM_PROPERTY(src.owner, PROP_ATOM_GRAVITY_IMMUNE))
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
		REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
		REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
		src.human_owner?.removeOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)
		src.human_owner?.removeOverlayComposition(/datum/overlayComposition/greyout)
		return

	if (T != src.owner.loc)
		if (HAS_ATOM_PROPERTY(src.owner.loc, PROP_ATOM_GRAVITY_IMMUNE_INSIDE))
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_NO_MOVEMENT_PUFFS, "gravity")
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND, "gravity")
			REMOVE_MOVEMENT_MODIFIER(src.owner, /datum/movement_modifier/gravity, "gravity")
			src.human_owner?.removeOverlayComposition(/datum/overlayComposition/steelmask/tunnel_vision)
			src.human_owner?.removeOverlayComposition(/datum/overlayComposition/greyout)
			return

	// don't take any on-tick effects while submerged in water
	if (istype(T, /turf/space/fluid))
		return
	else if (T.active_liquid)
		var/obj/fluid/F = T.active_liquid
		if (F.amt >= depth_levels[length(depth_levels)])
			return

	var/mult = get_multiplier()

	switch(src.owner.gforce)
		if (GFORCE_MOB_REGULAR_THRESHOLD to GFORCE_EARTH_GRAVITY)
			;  // quick no-op for most common gravity
		if (GFORCE_GRAVITY_MINIMUM to GFORCE_MOB_REGULAR_THRESHOLD)
			// spacefaring, salvagers, and skeletons immune; lower the gravity, higher the probability, ~2 to ~20%
			if (human_owner && !human_owner.lying && !human_owner.is_spacefaring() && !issalvager(human_owner) && !isskeleton(human_owner) && probmult(round((1 - src.owner.gforce) * 20)))
				switch(rand(1, 3))
					if (1) // nausea
						if (istype(human_owner.wear_suit, /obj/item/clothing/suit/space) || ischangeling(human_owner) || iszombie(human_owner))
							return // wearing a space suit or not caring about organs makes you immune
						boutput(human_owner, SPAN_ALERT("You feel your insides [pick("squirm", "shift", "wiggle", "float")] uncomfortably in low-gravity."))
						human_owner.nauseate(1)
					if (2) // stamina sap
						if (human_owner.traction == TRACTION_FULL)
							return // unless you're on solid footing
						if (istype(human_owner.back, /obj/item/tank/jetpack))
							var/obj/item/tank/jetpack/J = human_owner.back
							if(J.allow_thrust(0.01, human_owner))
								return // or jetpacking
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
							human_owner.change_eye_blurry((1-src.owner.gforce/100)*40, 15)
							msg_output += "bulging your eyes slightly."
						else
							human_owner.change_misstep_chance((1-src.owner.gforce/100)*40)
							msg_output += "disorienting you."
						boutput(human_owner, SPAN_ALERT(msg_output))
		if (GFORCE_MOB_EXTREME_THRESHOLD to INFINITY)
			if (src.owner.gforce >= GFORCE_MOB_PANCAKE_THRESHOLD)
				if (src.gib_counter > rand(9, 11))
					message_admins("Extremely high gravity ([src.owner.gforce/100]G) gibbed [src.owner] at [log_loc(src.owner)]")
					logTheThing(LOG_COMBAT, src, "[src.owner] was gibbed with excessive gravity of [src.owner.gforce]G at [log_loc(src.owner)]")
					APPLY_ATOM_PROPERTY(src.owner, PROP_HUMAN_DROP_BRAIN_ON_GIB, "gravity")
					src.owner.gravitygib()
					return
				if (probmult(67))
					boutput(src.owner, SPAN_ALERT("Your entire being strains against the immense gravity. <b>Staying here is not safe!</b>"), "grav_gib_warning")
					src.gib_counter += 0.69
					return // slow people down from dying a lil bit so they gib >:o)
			if (probmult(src.owner.gforce * 4)) // ~9% minimum
				var/damage = max(rand(GFORCE_MOB_EXTREME_THRESHOLD, src.owner.gforce), GFORCE_MOB_GREYOUT_THRESHOLD)/GFORCE_EARTH_GRAVITY
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
							robot_owner.TakeDamage("chest", damage, damage_type=DAMAGE_CRUSH)
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
							robot_owner.TakeDamage(pick(choices), damage, damage_type=DAMAGE_CRUSH)
