/datum/component/extradimensional_storage/prefab
	/// The path of the prefab to use.
	var/prefab_path = null
	/// The atoms within the prefab that objects entering the prefab may be sent to.
	var/list/atom/entrances = null

TYPEINFO(/datum/component/extradimensional_storage/prefab)
	initialization_args = list(
		ARG_INFO("prefab_path", DATA_INPUT_TYPE, "Prefab path"),
	)

/datum/component/extradimensional_storage/prefab/Initialize(prefab_path = null)
	if (!ispath(prefab_path, /datum/mapPrefab/allocated))
		return COMPONENT_INCOMPATIBLE

	src.prefab_path = prefab_path
	. = ..()

/datum/component/extradimensional_storage/prefab/UnregisterFromParent()
	src.entrances = null
	. = ..()

/datum/component/extradimensional_storage/prefab/set_up_allocated_region()
	var/datum/mapPrefab/allocated/prefab = global.get_singleton(src.prefab_path)
	src.region = prefab.load()

	src.entrances = list()
	for_by_tcl(entrance, /datum/component/extradimensional_prefab_entrance)
		if (!src.region.turf_in_region(get_turf(entrance.parent)))
			continue

		src.entrances += entrance.parent

	for_by_tcl(exit, /datum/component/extradimensional_prefab_exit)
		if (!src.region.turf_in_region(get_turf(exit.parent)))
			continue

		src.RegisterSignal(exit, COMSIG_EXTRADIMENSIONAL_PREFAB_EXIT, PROC_REF(try_exit))

/datum/component/extradimensional_storage/prefab/on_entered(atom/movable/AM, atom/old_loc)
	var/atom/entrance = pick(src.entrances)
	SEND_SIGNAL(entrance, COMSIG_EXTRADIMENSIONAL_PREFAB_ENTERED, AM)

/datum/component/extradimensional_storage/prefab/proc/try_exit(datum/component/extradimensional_prefab_exit/exit, atom/movable/AM, atom/old_loc)
	if (!src.region.turf_in_region(get_turf(old_loc)))
		return

	exit.exit_callback.Invoke(AM, src.exit)
