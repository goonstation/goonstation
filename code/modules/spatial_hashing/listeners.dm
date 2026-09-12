/datum/spatial_hashmap/listeners
	cell_size = DEFAULT_HEARING_RANGE * 2

/datum/spatial_hashmap/listeners/register_hashmap_entry(datum/listen_module/input/entry, atom/tracked_atom)
	. = ..()
	src.RegisterSignal(entry, COMSIG_LISTENER_ORIGIN_UPDATED, PROC_REF(update_tracked_atom_wrapper))

/datum/spatial_hashmap/listeners/unregister_hashmap_entry(datum/listen_module/input/entry)
	. = ..()
	src.UnregisterSignal(entry, COMSIG_LISTENER_ORIGIN_UPDATED)

/datum/spatial_hashmap/listeners/proc/update_tracked_atom_wrapper(datum/listen_module/input/entry, atom/old_origin, atom/new_origin)
	src.update_tracked_atom(entry, new_origin)
