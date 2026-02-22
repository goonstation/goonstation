/datum/unit_test/passability_cache
	// DO NOT APPROVE CHANGES IF THEY MODIFY THIS LIST WITHOUT A DAMN GOOD REASON
	/// List of types which are permitted to violate certain stability rules.
	var/permitted_instability = list(
		/atom = list("Cross"), // Density check, handled in jpsTurfPassable.
		/turf = list("Enter", "Exit"), // newloc smuggling, optimizations & vismirrors
		/turf/simulated/floor = list("Cross"), // 2x2 pod collision handling (handled in /datum/pathfind by disabling cache for pods)
		/turf/simulated/shuttle = list("Cross"), // ditto
		/turf/unsimulated/floor = list("Cross"), // ditto
		/mob/dead = list("Cross"), // overrides Cross() to suppress the /mob/Cross and always returns TRUE
		/mob/dead/observer = list("Cross") // just projectile collision
	)
	/// List of procs that are forbidden to be implemented on stable atoms.
	var/forbidden_procs = list("Enter", "Exit", "Cross", "Uncross")

/**
 * JPS Passability cache flag [/atom/var/pass_unstable] correctness checking.
 * Issue a failure for every descendent of /atom claiming to be stable, that is itself, or a descendant of, any type that contains an implementation
 * of a proc listed in forbidden_procs that is not explicitly allowed in permitted_instability.
 */
/datum/unit_test/passability_cache/Run()
	// var/list/empty_list = list()
	var/list/unstable_types = list()

	for(var/type in concrete_typesof(/atom))
		var/atom/atom_type = type

		var/direct_parent_path = type2parent(type)
		var/atom/direct_parent
		if(ispath(direct_parent_path, /atom))
			direct_parent = direct_parent_path
		var/stable = !initial(atom_type.pass_unstable)

		// Fail if this type is the first descendant of a unstable lineage to claim to be stable.
		if(stable && direct_parent && initial(direct_parent.pass_unstable))
			var/unstable_parent = predecessor_path_in_list(type, unstable_types)
			if(unstable_parent)
				var/list/blocking_procs_list = unstable_types[unstable_parent]
				var/blocking_procs = istype(blocking_procs_list) ? blocking_procs_list.Join(", ") : "forbidden procs"
				Fail("[type] cannot possibly be stable because [unstable_parent] implements [blocking_procs]")

		var/procs = global.get_singleton(/datum/proc_ownership_cache).procs_by_type[type]
		if(!procs)
			continue
		var/permitted_procs = src.permitted_instability[type]

		// Fail if this type claims to be stable but implements forbidden procs.
		for(var/forbidden_proc in forbidden_procs)
			if(procs[forbidden_proc])
				if(forbidden_proc in permitted_procs)
					continue // Don't track permitted instability
				LAZYLISTADD(unstable_types[type], forbidden_proc)
				if(stable)
					Fail("[type] is stable and must not implement [forbidden_proc]")
