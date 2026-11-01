/**
 *	The proc ownership cache is responsible for handling the generation and storage of proc ownership data. This is necessary
 *	because BYOND offers no method to access or check which procs a type defines, overrides, or inherits.
 */
/datum/proc_ownership_cache
	/// A list of every type and its associated procs. This specifically refers to procs overridden or defined on that type, rather than inherited.
	var/list/list/procs_by_type

/datum/proc_ownership_cache/New()
	. = ..()

	src.procs_by_type = list()

	/// Loop over all valid proc memory addresses, and sort them based on their owner's type.
	var/subaddress = 0
	while (TRUE)
		var/address = BUILD_ADDR(PROC_TYPEID, subaddress)
		var/proc_ref = locate(address)
		if (!proc_ref)
			break

		var/proc_path = "[proc_ref]"

		var/last_slash = findlasttext(proc_path, "/")
		var/proc_name = copytext(proc_path, last_slash + 1)

		var/owner_type
		switch (copytext(proc_path, last_slash - 5, last_slash))
			if ("/proc", "/verb")
				owner_type = text2path(copytext(proc_path, 1, last_slash - 5))
			else
				owner_type = text2path(copytext(proc_path, 1, last_slash))

		src.procs_by_type[owner_type] ||= list()
		src.procs_by_type[owner_type][proc_name] = proc_ref
		subaddress++

	/// Sort the proc list into alphabetical order.
	for (var/type in src.procs_by_type)
		sortList(src.procs_by_type[type], /proc/cmp_text_asc)

/// Returns the reference to most recent definition of the specified proc name on the specified type.
/datum/proc_ownership_cache/proc/get_proc_ref(type, proc_name)
	while (type)
		if (!src.procs_by_type[type]?[proc_name])
			type = type2parent(type)
			continue

		return src.procs_by_type[type][proc_name]
