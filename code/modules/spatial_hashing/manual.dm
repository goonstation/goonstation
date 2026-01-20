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

	var/x = ceil(T.x / src.cell_size)
	var/y = ceil(T.y / src.cell_size)
	var/z = T.z
	if (z && (z <= src.z_order))
		src.hashmap[z][y][x] += entry

/datum/spatial_hashmap/manual/unregister_hashmap_entry(datum/entry)
	var/turf/T = src.atoms_by_entry[entry]
	if (!istype(T))
		return

	src.UnregisterSignal(entry, COMSIG_PARENT_PRE_DISPOSING)
	src.atoms_by_entry -= entry

	var/x = ceil(T.x / src.cell_size)
	var/y = ceil(T.y / src.cell_size)
	var/z = T.z
	if (z && (z <= src.z_order))
		src.hashmap[z][y][x] -= entry

