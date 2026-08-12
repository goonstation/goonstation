/datum/component/extradimensional_storage/storage

/datum/component/extradimensional_storage/storage/Initialize(width = 9, height = 9, region_init_proc = null)
	if (!istype(src.parent, /obj/storage))
		return COMPONENT_INCOMPATIBLE
	src.exit = src.parent
	. = ..()

	src.RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	src.RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/storage/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
	src.UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()

/datum/component/extradimensional_storage/storage/on_entered(obj/storage/locker, atom/movable/Obj, atom/OldLoc)
	var/turf/old_turf = OldLoc
	if (istype(old_turf) && src.region.turf_in_region(old_turf))
		if (locker.open)
			Obj.set_loc(locker.loc)
	else
		Obj.set_loc(src.region.turf_at(rand(3, src.region.width - 2), rand(3, src.region.height - 2)))
