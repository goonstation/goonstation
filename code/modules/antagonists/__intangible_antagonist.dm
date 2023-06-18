ABSTRACT_TYPE(/datum/antagonist/mob/intangible)
/datum/antagonist/mob/intangible
	mob_path = /mob/living/intangible

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


ABSTRACT_TYPE(/datum/antagonist/subordinate/mob/intangible)
/datum/antagonist/subordinate/mob/intangible
	mob_path = /mob/living/intangible

	relocate()
		var/turf/T = get_turf(src.master.current)
		if (!(T && isturf(T)) || (T.z != Z_LEVEL_STATION))
			var/spawn_loc = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, Z_LEVEL_STATION))
			if (spawn_loc)
				src.owner.current.set_loc(spawn_loc)
			else
				src.owner.current.z = Z_LEVEL_STATION
		else
			src.owner.current.set_loc(T)
