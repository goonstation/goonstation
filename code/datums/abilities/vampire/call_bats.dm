/datum/abilityHolder/vampire/var/list/bat_orbiters

/datum/abilityHolder/vampire/proc/launch_bat_orbiters()
	if (length(bat_orbiters))
		for (var/obj/projectile/P in bat_orbiters)
			if (GET_DIST(P,src.owner) < 4)
				P.targets = 0

		bat_orbiters.len = 0

/datum/targetable/vampire/call_bats
	name = "Call Frost Bats"
	desc = "Calls a swarm of frost bat spirits. They will orbit you, protecting your personal space from projectiles and living assailants. You can use the Flip emote to launch them."
	icon_state = "frostbats"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 600
	pointCost = 0//150
	when_stunned = 0
	not_when_handcuffed = 0
	unlock_message = "You have gained Call Frost Bats, a protection spell."
	var/datum/projectile/special/homing/orbiter/spiritbat/P = new

	flip_callback()
		var/datum/abilityHolder/vampire/H = holder
		H.launch_bat_orbiters()

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		var/turf/T = get_turf(M)
		if (T && isturf(T))
			//play sound pls
			//either here or in projectile launch

			H.bat_orbiters = list()

			var/create = 4
			var/turf/shoot_at = get_step(M,pick(alldirs))

			for (var/i = 0, i < create, i += 0.1) //pay no mind :)
				var/obj/projectile/proj = initialize_projectile_ST(M, P, shoot_at)
				if (proj && !proj.disposed)
					proj.targets = list(M)

					H.bat_orbiters += proj

					proj.launch()
					proj.special_data["orbit_angle"] = round(i)/create * 360

					i++

		else
			boutput(M, "<span class='alert'>The bats did not respond to your call!</span>")
			return 1 // No cooldown here, though.

		if (src.pointCost && istype(H))
			H.blood_tracking_output(src.pointCost)

		playsound(M.loc, 'sound/effects/gust.ogg', 60, 1)

		logTheThing(LOG_COMBAT, M, "uses call bats at [log_loc(M)].")
		return 0



//OLD
/datum/targetable/vampire/call_bats_old
	name = "Call bats"
	desc = "Calls a swarm of bats to attack your foes."
	icon_state = "batsum"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 1200
	pointCost = 150
	when_stunned = 0
	not_when_handcuffed = 1
	unlock_message = "You have gained call bats, which summons bats to fight for you."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M)
			return 1

		if (M.wear_mask && istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			boutput(M, "<span class='alert'>How do you expect this to work? You're muzzled!</span>")
			M.visible_message("<span class='alert'><b>[M]</b> makes a loud noise.</span>")
			if (istype(H)) H.blood_tracking_output(src.pointCost)
			return 0 // Cooldown because spam is bad.

		var/turf/T = get_turf(M)
		if (T && isturf(T))
			M.say("BATT PHAR")
			new /obj/critter/bat/buff(T)
			new /obj/critter/bat/buff(T)
			new /obj/critter/bat/buff(T)
			for (var/obj/critter/bat/buff/B in range(M, 1))
				B.friends += M
		else
			boutput(M, "<span class='alert'>The bats did not respond to your call!</span>")
			return 1 // No cooldown here, though.

		if (istype(H)) H.blood_tracking_output(src.pointCost)
		logTheThing(LOG_COMBAT, M, "uses call bats at [log_loc(M)].")
		return 0
