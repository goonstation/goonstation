ABSTRACT_TYPE(/datum/antagonist/intangible)
/datum/antagonist/intangible
	var/intangible_mob_path = /mob/living/intangible

	give_equipment()
		var/mob/current_mob = src.owner.current
		var/mob/living/intangible/intangible_mob = new intangible_mob_path(get_turf(current_mob))
		src.owner.transfer_to(intangible_mob)
		qdel(current_mob)

	remove_equipment()
		var/mob/current_mob = src.owner.current
		src.owner.current.ghostize()
		qdel(current_mob)

	relocate()
		var/turf/T = get_turf(src.owner.current)
		if (!(T && isturf(T)) || (T.z != Z_LEVEL_STATION))
			var/spawn_loc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, Z_LEVEL_STATION))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = Z_LEVEL_STATION
		else
			src.owner.current.set_loc(T)
