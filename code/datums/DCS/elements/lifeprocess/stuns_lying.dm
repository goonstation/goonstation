/datum/element/lifeprocess/stuns_lying/process(mob/living/target, mult, datum/gas_mixture/environment)
	var/lying_old = target.lying
	var/can_lie = src.can_lie(target)

	var/list/status_list = target.getStatusList()
	if (!can_lie && status_list["resting"])
		target.delStatus("resting")
		status_list -= "resting"

	if (isdead(target))
		target.lying = (can_lie && !ismobcritter(target))
		target.blinded = TRUE
		setdead(target)

	else
		var/datum/abilityHolder/changeling/C = target.get_ability_holder(/datum/abilityHolder/changeling)
		var/changeling_fakedeath = C?.in_fakedeath

		var/resting		= status_list["resting"] || istype(target.buckled, /obj/stool/bed)
		var/unconscious	= status_list["unconscious"]
		var/stunned		= status_list["stunned"]
		var/knockdown	= status_list["knockdown"]
		var/pinned		= status_list["pinned"]
		var/paralysis	= status_list["paralysis"]

		// Stunned.
		if ( \
			(can_lie && resting) \
			|| changeling_fakedeath \
			|| unconscious \
			|| stunned \
			|| knockdown \
			|| pinned \
			|| paralysis \
		)
			// Statuses that force lying.
			if (can_lie && (resting || unconscious || knockdown || pinned))
				target.lying = TRUE

			// Alive/unconscious handling.
			if (unconscious)
				// The target only just got knocked out, so call `lastgasp()`.
				if (isalive(target) && target.mind)
					target.lastgasp()

				target.stat = STAT_UNCONSCIOUS

			else if (stunned || knockdown || pinned)
				target.stat = STAT_ALIVE

			target.empty_hands()

			// Small chance to heal by a miniscule amount.
			if (!ON_COOLDOWN(target, "stun_recovery", 6 SECONDS) && prob(10))
				target.take_oxygen_deprivation(-0.3)
				target.lose_breath(-0.3)
				target.HealDamage("All", 0.2, 0.2, 0.2)

		// Not stunned.
		else
			target.lying = FALSE
			target.stat = STAT_ALIVE

	if (target.lying != lying_old)
		target.update_lying()

		if (!target::density || (ismobcritter(target) && isdead(target)))
			target.set_density(FALSE)
		else
			target.set_density(!target.lying)

		if (target.lying && !target.buckled && !HAS_ATOM_PROPERTY(target, PROP_MOB_SUPPRESS_LAYDOWN_SOUND))
			var/turf/T = get_turf(target)
			if (T?.active_liquid)
				if (T.active_liquid.my_depth_level <= 3)
					T.active_liquid.Crossed(target)
					playsound(target.loc, 'sound/misc/splash_2.ogg', ishuman(target) ? 40 : 15, 1, 0.3)

			else
				playsound(target.loc, 'sound/misc/body_thud.ogg', ishuman(target) ? 40 : 15, 1, 0.3)

/// Whether a target is capable of lying down.
/datum/element/lifeprocess/stuns_lying/proc/can_lie(mob/living/target)
	if (!target.can_lie)
		return FALSE

	if (isrobot(target) || ishivebot(target))
		return FALSE

	if (target.buckled && !istype(target.buckled, /obj/stool/bed))
		return FALSE

	var/atom/A = target.loc
	if (istype(A, /obj/machinery/atmospherics/unary/cryo_cell))
		return FALSE

	var/mob/living/carbon/human/H = target
	if ( \
		istype(H) \
		&& H.limbs \
		&& (istype(H.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/treads) || istype(H.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/treads)) \
		&& !locate(/obj/table, A) \
		&& !locate(/obj/machinery/optable, A) \
	)
		return FALSE

	return TRUE
