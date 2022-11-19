/datum/unit_test/passability_cache
	var/can_have_cross = list(
		/turf/simulated/floor, // Cross() is the only consistent way to handle 2x2 pods
		/turf/simulated/shuttle, // Ditto
		/turf/unsimulated/floor // Ditto
	)

/datum/unit_test/passability_cache/Run()
	generate_procs_by_type()
	for(var/type in procs_by_type)
		if(!ispath(type, /atom))
			continue
		var/atom/atom_type = type
		if(initial(atom_type.jpsUnstable))
			continue

		var/forbid_cross = TRUE
		for(var/path in src.can_have_cross)
			if(ispath(type, path))
				forbid_cross = FALSE
				break

		if(procs_by_type[type]["Enter"])
			Fail("[type] is stable and should not override Enter");
		if(procs_by_type[type]["Exit"])
			Fail("[type] is stable and should not override Exit");
		if(forbid_cross && procs_by_type[type]["Cross"])
			Fail("[type] is stable and should not override Cross");
