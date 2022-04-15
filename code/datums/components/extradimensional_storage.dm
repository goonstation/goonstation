/datum/component/extradimensional_storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/allocated_region/region

TYPEINFO(/datum/component/extradimensional_storage)
	initialization_args = list(
		ARG_INFO("width", DATA_INPUT_NUM, "Dimension width", 9),
		ARG_INFO("height", DATA_INPUT_NUM, "Dimension height", 9),
	)

/datum/component/extradimensional_storage/Initialize(width=9, height=9, region_init_proc=null)
	if(!istype(parent, /obj/storage))
		return COMPONENT_INCOMPATIBLE
	region = global.region_allocator.allocate(width, height)
	if(region_init_proc)
		call(region_init_proc)(region, parent)
	else
		src.default_init_region()
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/on_entered)
	RegisterSignal(parent, COMSIG_STORAGE_CLOSED, .proc/on_closed)

/datum/component/extradimensional_storage/proc/default_init_region()
	var/obj/storage/parent = src.parent
	region.clean_up(/turf/unsimulated/floor/setpieces/gauntlet)

	for(var/x in 2 to region.width - 1)
		var/turf/T = region.turf_at(x, 2)
		new/obj/decal/nothing{dir=NORTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = parent

		T = region.turf_at(x, region.height - 1)
		new/obj/decal/nothing{dir=SOUTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = parent

	for(var/y in 2 to region.height - 1)
		var/turf/T = region.turf_at(2, y)
		new/obj/decal/nothing{dir=WEST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = parent

		T = region.turf_at(region.width - 1, y)
		new/obj/decal/nothing{dir=EAST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = parent

/datum/component/extradimensional_storage/proc/on_entered(atom/movable/Obj, atom/OldLoc)
	var/obj/storage/parent = src.parent
	var/turf/old_turf = OldLoc
	if(parent.open && istype(old_turf) && region.turf_in_region(old_turf))
		Obj.set_loc(parent.loc)

/datum/component/extradimensional_storage/proc/on_closed()
	var/obj/storage/parent = src.parent
	for(var/atom/movable/AM in parent)
		var/turf/T = region.turf_at(rand(3, region.width - 2), rand(3, region.height - 2))
		AM.set_loc(T)

/datum/component/extradimensional_storage/UnregisterFromParent()
	var/obj/storage/parent = src.parent
	for(var/x in 1 to region.width)
		for(var/y in 1 to region.height)
			var/turf/T = region.turf_at(x, y)
			for(var/atom/movable/AM in T)
				if(!AM.anchored)
					AM.set_loc(parent.loc)
	region.clean_up(/turf/space, /turf/space)
	qdel(region)
	UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	UnregisterSignal(parent, COMSIG_STORAGE_CLOSED)
	. = ..()
