/datum/abilityHolder/vampire/var/list/bat_orbiters

/datum/abilityHolder/vampire/proc/launch_bat_orbiters()
	if (length(bat_orbiters))
		for (var/obj/projectile/P in bat_orbiters)
			if (GET_DIST(P, src.owner) < 4)
				P.targets = 0

		bat_orbiters.len = 0

/datum/targetable/vampire/call_bats
	name = "Call Frost Bats"
	desc = "Calls a swarm of frost bat spirits. They will orbit you, protecting your personal space from projectiles and living assailants. You can use the Flip emote to launch them."
	icon_state = "frostbats"
	cooldown = 60 SECONDS
	incapacitation_restriction = ABILITY_NO_INCAPACITATED_USE
	can_cast_while_cuffed = TRUE
	unlock_message = "You have gained Call Frost Bats, a protection spell."
	var/num_bats = 4

	cast(mob/target)
		. = ..()

		var/mob/living/user = holder.owner
		var/datum/abilityHolder/vampire/AH = holder

		var/turf/T = get_turf(user)
		if (isturf(T))
			//play sound pls
			//either here or in projectile launch

			AH.bat_orbiters = list()

			var/turf/shoot_at = get_step(user, pick(alldirs))

			for (var/i = 0, i < num_bats, i += 0.1) //pay no mind :)
				var/obj/projectile/proj = initialize_projectile_pixel_spread(M, P, shoot_at)
				if (proj && !proj.disposed)
					proj.targets = list(user)

					AH.bat_orbiters += proj

					proj.launch()
					proj.special_data["orbit_angle"] = round(i)/num_bats * 360

					i++

		else
			boutput(user, "<span class='alert'>The bats did not respond to your call!</span>")
			return TRUE // No cooldown here, though.

		playsound(user.loc, 'sound/effects/gust.ogg', 60, TRUE)

		logTheThing(LOG_COMBAT, user, "uses call bats at [log_loc(user)].")
		return FALSE

/datum/targetable/vampire/call_bats/turbo
	name = "Call Bat Swarm"
	num_bats = 10
