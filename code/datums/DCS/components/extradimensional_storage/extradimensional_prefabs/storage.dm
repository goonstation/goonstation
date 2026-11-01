/datum/component/extradimensional_storage/prefab/storage

/datum/component/extradimensional_storage/prefab/storage/Initialize(prefab_path = null)
	if (!istype(src.parent, /obj/storage))
		return COMPONENT_INCOMPATIBLE
	src.exit = src.parent
	. = ..()

	src.RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(enter_locker))
	src.RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/prefab/storage/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
	src.UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()

/datum/component/extradimensional_storage/prefab/storage/proc/enter_locker(obj/storage/locker, atom/movable/AM, turf/old_loc)
	var/turf/old_turf = get_turf(old_loc)
	if (istype(old_turf) && src.region.turf_in_region(old_turf))
		if (locker.open)
			AM.set_loc(locker.loc)

		return

	src.on_entered(AM, old_turf)
