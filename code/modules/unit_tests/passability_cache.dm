/datum/unit_test/passability_cache

/datum/unit_test/passability_cache/Run()
	generate_procs_by_type()
	for(var/type in procs_by_type)
		if(!ispath(type, /atom))
			continue
		var/atom/atom_type = type
		if(initial(atom_type.jpsUnstable))
			continue
		if(procs_by_type[type]["Cross"])
			Fail("[type] is stable and should not override Cross")
