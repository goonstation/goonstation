// ---------------------
// Martian teleportation
// ---------------------
/datum/targetable/critter/teleport
	name = "Teleport"
	desc = "Phase yourself to a nearby visible spot."
	cooldown = 300
	targeted = 1
	target_anything = 1
	restricted_area_check = 1

	cast(atom/target)
		if (..())
			return 1
		if (!isturf(target))
			target = get_turf(target)
		if (target == get_turf(holder.owner))
			return 1
		var/turf/T = target
		holder.owner.set_loc(T)
		SPAWN_DBG(0)
			var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
			s.set_up(5, 1, holder.owner)
			s.start()
		playsound(T, "sound/effects/ghost2.ogg", 100, 1)
		holder.owner.say("TELEPORT!", 1)
		return 0
