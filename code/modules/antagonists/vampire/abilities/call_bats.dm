/datum/abilityHolder/vampire/var/list/bat_orbiters = list()

/// Called when the vampire flips, launches all orbiters into nearby targets
/datum/abilityHolder/vampire/proc/launch_bat_orbiters(mob/vampire)
	var/list/mob/mob_targets = list()
	for(var/mob/M in view(7, vampire.loc))
		if (isliving(M) && !isdead(M))
			mob_targets += M
	mob_targets -= vampire
	if (length(bat_orbiters))
		for (var/obj/projectile/P in bat_orbiters)
			if (GET_DIST(P,src.owner) < 4)
				P.targets = list(pick(mob_targets))
		bat_orbiters.len = 0

/// Called when the vampire points, launches a single orbiter
/datum/abilityHolder/vampire/proc/targeted_bat_orbiters(mob/pointer, atom/target)
	if (!ismob(target))
		return
	if (isintangible(target))
		return
	if (length(bat_orbiters))
		var/obj/projectile/P = pick(bat_orbiters)
		if (istype(P))
			P.targets = list(target)
			bat_orbiters -= P

/datum/targetable/vampire/call_frost_bats
	name = "Call Frost Bats"
	desc = "Calls a swarm of frost bats. They will orbit you, stopping all projectiles and flinging mobs they hit. Point at a mob to send one bat, or flip to send all to nearby mobs."
	icon_state = "frostbats"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 600
	pointCost = 0//150
	when_stunned = 0
	not_when_handcuffed = 0
	unlock_message = "You have gained Call Frost Bats, a protection spell."
	var/datum/projectile/special/homing/orbiter/spiritbat/frost/P = new

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		. = ..()
		var/turf/T = get_turf(M)
		if (T && isturf(T))
			var/create = 4
			var/turf/shoot_at = get_step(M,pick(alldirs))
			P.auto_find_targets = FALSE
			for (var/i = 0, i < create, i += 0.1) //pay no mind :)
				var/obj/projectile/proj = initialize_projectile_pixel_spread(M, P, shoot_at)
				if (proj && !proj.disposed)
					proj.targets = list(M)

					H.bat_orbiters += proj

					proj.launch()
					proj.special_data["orbit_angle"] = round(i)/create * 360

					i++

		else
			boutput(M, SPAN_ALERT("The bats did not respond to your call!"))
			return 1 // No cooldown here, though.

		playsound(M.loc, 'sound/effects/gust.ogg', 60, 1)

		logTheThing(LOG_COMBAT, M, "uses call frost bats at [log_loc(M)].")
		return 0

/datum/targetable/vampire/call_spirit_bats
	name = "Call Spirit Bats"
	desc = "Call a swarm of spirit bats. They will orbit you, stopping one projectile and disorienting mobs they hit. Point at a mob to send one bat, or flip to send all to nearby mobs."
	icon_state = "frostbats" //TODO: Different icon?
	targeted = FALSE
	target_nodamage_check = 0
	max_range = 0
	cooldown = 300
	pointCost = 0
	when_stunned = FALSE
	not_when_handcuffed = 0
	unlock_message = "You have gained Call Spirit Bats, a protection spell."
	var/datum/projectile/special/homing/orbiter/spiritbat/disorient/P = new

	cast(mob/target)
		if (!holder)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		. = ..()

		var/turf/T = get_turf(M)
		if (T && isturf(T))
			var/create = 4
			var/turf/shoot_at = get_step(M, pick(alldirs))
			P.auto_find_targets = FALSE

			for (var/i = 0, i < create, i += 0.1) //pay no mind :)
				var/obj/projectile/proj = initialize_projectile_pixel_spread(M, P, shoot_at)
				if (proj && !proj.disposed)
					proj.targets = list(M)

					H.bat_orbiters += proj

					proj.launch()
					proj.special_data["orbit_angle"] = round(i)/create * 360

					i++
		else
			boutput(M, SPAN_ALERT("The bats did not respond to your call!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		playsound(M.loc, 'sound/effects/gust.ogg', 60, 1)

		logTheThing(LOG_COMBAT, M, "uses call spirit bats at [log_loc(M)].")
		return CAST_ATTEMPT_SUCCESS
