/// Melee attack. Shocks a targeted mob, or can be used on an airlock to temporarily cut its power.
/datum/targetable/arcfiend/discharge
	name = "Discharge"
	desc = "Run a powerful current through a target in melee range. Mobs will be shocked and knocked back a short distance, while airlocks will be briefly depowered."
	icon_state = "discharge"
	cooldown = 15 SECONDS
	target_anything = TRUE
	targeted = TRUE
	pointCost = 25
	///how far to knock mobs away from ourselves
	var/target_dist = 4
	///how fast to throw affected mobs away
	var/throw_speed = 1
	/// This is the amount of power considered to be in use when we're shocking a mob.
	var/wattage = 7500 WATTS
	/// how much direct burn damage this attack deals, on top of any damage from the shock itself
	var/direct_burn_damage = 15

	cast(atom/target)
		. = ..()
		if (target == src.holder.owner)
			return TRUE
		if (!(BOUNDS_DIST(src.holder.owner, target) == 0))
			return TRUE
		if (ismob(target))
			var/mob/M = target
			M.shock(src.holder.owner, src.wattage, ignore_gloves = TRUE)
			if (issilicon(M))
				random_burn_damage(M, direct_burn_damage*2)
				playsound(src.holder.owner, 'sound/effects/electric_shock.ogg', 50, TRUE) // needed for borgs hit to play the sound
			else
				random_burn_damage(M, direct_burn_damage)
			target.add_fingerprint(src.holder.owner)
			var/turf/T = get_ranged_target_turf(M, get_dir(holder.owner, M), target_dist)
			if (T)
				var/falloff = GET_DIST(holder.owner, M)
				M.throw_at(T, target_dist - falloff, throw_speed)
			logTheThing(LOG_COMBAT, src.holder.owner, "[key_name(src.holder.owner)] used <b>[src.name]</b> on [key_name(target)] [log_loc(src.holder.owner)].")
		else if (istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/airlock = target
			if (airlock.hardened)
				boutput(src.holder.owner, "<span class='alert'>[target] is hardened against your electrical attacks, your [name] skill has no effect!</span>")
				return TRUE
			airlock.loseMainPower()
			target.add_fingerprint(src.holder.owner)
			playsound(src.holder.owner, 'sound/effects/electric_shock.ogg', 50, TRUE)
			boutput(src.holder.owner, "<span class='alert'>You run a powerful current into [target], temporarily cutting its power!</span>")
		else
			return TRUE
		var/datum/effects/system/spark_spread/S = new /datum/effects/system/spark_spread
		S.set_up(2, FALSE, target)
		S.start()
		src.holder.owner.set_dir(get_dir(src.holder.owner, target))
