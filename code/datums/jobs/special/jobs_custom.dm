/datum/job/created
	name = "Special Job"
	job_category = JOB_CREATED

	//handle special spawn location
	Write(F)
		. = ..()
		if(istext(src.special_spawn_location))
			F["special_spawn_location"] << src.special_spawn_location
		else if(ismovable(src.special_spawn_location) || isturf(src.special_spawn_location))
			var/atom/A = src.special_spawn_location
			var/turf/T = get_turf(A)
			F["special_spawn_location_coords"] << list(T.x, T.y, T.z)

	Read(F)
		. = ..()
		src.special_spawn_location = null
		var/maybe_spawn_loc = null
		F["special_spawn_location"] >> maybe_spawn_loc
		if(istext(maybe_spawn_loc))
			src.special_spawn_location = maybe_spawn_loc
		else
			var/list/maybe_coords = null
			F["special_spawn_location_coords"] >> maybe_coords
			if(islist(maybe_coords))
				src.special_spawn_location = locate(maybe_coords[1], maybe_coords[2], maybe_coords[3])
