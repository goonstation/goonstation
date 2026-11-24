/datum/component/extradimensional_storage/floor

/datum/component/extradimensional_storage/floor/Initialize(width = 9, height = 9, region_init_proc = null)
	if (!istype(src.parent, /turf))
		return COMPONENT_INCOMPATIBLE
	src.exit = src.parent
	. = ..()

	src.RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	src.RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/floor/UnregisterFromParent()
	src.UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
	src.UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()

/datum/component/extradimensional_storage/floor/default_init_region()
	. = ..()
	var/turf/origin = src.parent
	for (var/x in 2 to src.region.width - 1)
		var/turf/T = src.region.turf_at(x, 2)
		T.warptarget = get_step(src.exit, SOUTH)
		T = src.region.turf_at(x, src.region.height - 1)
		T.warptarget = get_step(src.exit, NORTH)

	for (var/y in 2 to src.region.height - 1)
		var/turf/T = src.region.turf_at(2, y)
		T.warptarget = get_step(src.exit, WEST)
		T = src.region.turf_at(src.region.width - 1, y)
		T.warptarget = get_step(src.exit, EAST)

	for (var/x in 2 to src.region.width - 1)
		for (var/y in 2 to src.region.height - 1)
			var/turf/T = src.region.turf_at(x, y)
			T.appearance = origin.appearance

/datum/component/extradimensional_storage/floor/on_entered(turf/floor, atom/movable/Obj, atom/OldLoc)
	var/enterDir = get_dir(src.parent, OldLoc)
	Obj.set_loc(src.region.turf_at((enterDir&EAST) ? src.region.width-2 : (enterDir&WEST) ? 3 : floor((src.region.width+1)/2),
	(enterDir&NORTH) ? src.region.height-2 : (enterDir&SOUTH) ? 3 : floor((src.region.height+1)/2)))
