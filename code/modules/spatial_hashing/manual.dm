/datum/spatial_hashmap/manual

/datum/spatial_hashmap/manual/register_hashmap_entry(datum/entry, turf/T)
	if (src.atoms_by_entry[entry])
		return

	if (!T && isatom(entry))
		T = get_turf(entry)

	if (!istype(T))
		return

	src.RegisterSignal(entry, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(unregister_hashmap_entry))
	src.atoms_by_entry[entry] = T

	if (T.z && (T.z <= src.z_order))
		var/x = ceil(T.x / src.cell_size)
		var/y = ceil(T.y / src.cell_size)
		src.hashmap[T.z][y][x] += entry

/datum/spatial_hashmap/manual/unregister_hashmap_entry(datum/entry)
	var/turf/T = src.atoms_by_entry[entry]
	if (!istype(T))
		return

	src.UnregisterSignal(entry, COMSIG_PARENT_PRE_DISPOSING)
	src.atoms_by_entry -= entry

	if (T?.z && (T.z <= src.z_order))
		var/x = ceil(T.x / src.cell_size)
		var/y = ceil(T.y / src.cell_size)
		src.hashmap[T.z][y][x] -= entry

