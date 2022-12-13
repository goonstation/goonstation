/// Super simple CC. Short-ranged elecflash.
/datum/targetable/arcfiend/elecflash
	name = "Flash"
	desc = "Release a sudden burst of power around yourself, blasting nearby creatures back and disorienting them."
	icon_state = "flash"
	cooldown = 10 SECONDS
	pointCost = 25
	container_safety_bypass = TRUE
	///how far to knock mobs away from ourselves
	var/target_dist = 6
	///how fast to throw affected mobs away
	var/throw_speed = 1

	cast(atom/target)
		. = ..()
		elecflash(holder.owner, 2, 6, TRUE)
		for (var/mob/living/L in viewers(3, holder.owner))
			if (isobserver(L) || isintangible(L))
				continue
			var/turf/T = get_ranged_target_turf(L, get_dir(holder.owner, L), target_dist)
			if (T)
				var/falloff = GET_DIST(holder.owner, L)
				L.throw_at(T, target_dist - falloff, throw_speed)
/* 				if (falloff == 1 || (falloff == 2 && prob(50))) // if they were adjacent they get knocked down too
					L.changeStatus("weakened", 1.5 SECOND)
					L.force_laydown_standup() */

