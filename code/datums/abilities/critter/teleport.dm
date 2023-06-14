// ---------------------
// Martian teleportation
// ---------------------
/datum/targetable/critter/teleport
	name = "Teleport"
	desc = "Phase yourself to a nearby visible spot."
	cooldown = 300
	targeted = 1
	target_anything = 1
	restricted_area_check = ABILITY_AREA_CHECK_ALL_RESTRICTED_Z

	cast(atom/target)
		if (..())
			return 1
		if (!isturf(target))
			target = get_turf(target)
		if (target == get_turf(holder.owner))
			return 1
		var/turf/T = target
		holder.owner.set_loc(T)
		elecflash(T)
		playsound(T, 'sound/effects/ghost2.ogg', 100, 1)
		holder.owner.say("TELEPORT!", 1)
		return 0
