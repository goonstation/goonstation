/datum/element/lifeprocess/status_update/process(mob/living/target, datum/gas_mixture/environment)
	if (isdead(target) || target.bioHolder?.HasEffect("revenant"))
		return

	var/mult = src.get_multiplier(target)

	target.stamina_max = max((STAMINA_MAX + target.get_stam_mod_max()), 0)
	target.stamina = min(target.stamina, target.stamina_max)

	// Sleeping.
	if (target.sleeping)
		if (target.hasStatus("resting"))
			target.sleeping = 2
		else
			target.sleeping = max(target.sleeping - mult, 0)

		target.changeStatus("unconscious", 3 SECONDS * mult)
		if (prob(10) && (target.health > 0))
			target.emote("snore")

		// The target is asleep but wasn't previously.
		if (!target.last_sleep)
			target.last_sleep = TRUE
			target.UpdateOverlays(target.sleep_bubble, "sleep_bubble")

			if (iscritter(target))
				var/mob/living/critter/M = target
				M.on_sleep()

	// The target was previously asleep but isn't anymore.
	else if (target.last_sleep)
		target.last_sleep = FALSE
		target.UpdateOverlays(null, "sleep_bubble")

		if (iscritter(target))
			var/mob/living/critter/M = target
			M.on_wake()

	if (prob(50) && target.hasStatus("disorient"))
		target.emote("twitch")


	if (target.getStatusDuration("blinded") || target.getStatusDuration("teleporting") || target.loc?.getStatusDuration("teleporting"))
		target.blinded = TRUE

	else if (!HAS_ATOM_PROPERTY(target, PROP_MOB_XRAYVISION) && !HAS_ATOM_PROPERTY(target, PROP_MOB_XRAYVISION_WEAK))
		for (var/obj/item/I as anything in target.get_equipped_items())
			if (I.block_vision)
				target.blinded = TRUE
				break

	// Temporary blindness.
	if (target.get_eye_damage(TRUE))
		target.take_eye_damage(-mult, TRUE)
		target.blinded = TRUE

	if (target.stuttering)
		target.stuttering = max(target.stuttering - mult, 0)

	// Temporary deafness.
	if (target.get_ear_damage(TRUE))
		target.take_ear_damage(-mult, TRUE)

	var/ear_damage = target.get_ear_damage()
	if (ear_damage && (ear_damage <= target.get_ear_damage_natural_healing_threshold()))
		target.take_ear_damage(-0.05 * mult)

	if (target.get_eye_blurry())
		target.change_eye_blurry(-mult)

	if (target.druggy)
		target.druggy = max(target.druggy - mult, 0)

	if (target.nodamage)
		target.HealDamage("All", 10000, 10000)
		target.take_toxin_damage(-5000)
		target.take_oxygen_deprivation(-5000)
		target.take_brain_damage(-120)
		target.stuttering = 0
		target.take_ear_damage(-INFINITY)
		target.take_ear_damage(-INFINITY, TRUE)
		target.change_eye_blurry(-INFINITY)
		target.druggy = 0
		target.blinded = null
