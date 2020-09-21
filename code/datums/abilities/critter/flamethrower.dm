// --------------------------------------------------
// Fire elemental ability - shoot flames in direction
// --------------------------------------------------
/datum/targetable/critter/flamethrower
	name = "Flamethrower"
	desc = "Throw flames towards a target location up to three squares away."
	cooldown = 150
	targeted = 1
	target_anything = 1
	var/throws = 0
	var/heat = 3000

	cast(atom/target)
		if (..())
			return 1
		if (target && !isturf(target))
			target = get_turf(target)
		if (!target)
			return 1
		var/turf/OT = get_turf(holder.owner)
		var/turf/original_target = get_turf(target)
		var/it = 7
		while (get_dist(OT, target) > 3)
			target = get_step(target, get_dir(target, OT))
			it--
			if (it <= 0)
				return 1
		while (get_dist(OT, target) < 3)
			target = get_step(target, get_dir(OT, target))
			it--
			if (it <= 0)
				return 1
		if (target == holder.owner || target == OT)
			return 1
		playsound(target, "sound/effects/spray.ogg", 50, 1, -1,1.5)
		var/list/L = getline(OT, target)
		for (var/turf/T in L)
			if (T == OT)
				continue
			fireflash_sm(T, 0, heat, 0)
			for (var/mob/living/M in T)
				if (!M.is_heat_resistant())
					M.TakeDamage("All", 0, 15, 0, DAMAGE_BURN)
					M.changeStatus("stunned", 2 SECONDS)
					M.emote("scream")
					if (throws)
						M.throw_at(original_target, 20, 2)
		return 0


	throwing
		desc = "Blast targets backwards with flames."
		icon_state = "fire_e_flamethrower"
		throws = 1
		heat = T0C + 60
