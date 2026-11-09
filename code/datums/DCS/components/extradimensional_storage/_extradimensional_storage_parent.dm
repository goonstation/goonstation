ABSTRACT_TYPE(/datum/component/extradimensional_storage)
/datum/component/extradimensional_storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/allocated_region/region = null
	var/atom/exit = null

TYPEINFO(/datum/component/extradimensional_storage)
	initialization_args = list(
		ARG_INFO("width", DATA_INPUT_NUM, "Dimension width", 9),
		ARG_INFO("height", DATA_INPUT_NUM, "Dimension height", 9),
	)

/datum/component/extradimensional_storage/Initialize(width = 9, height = 9, region_init_proc = null)
	. = ..()
	src.set_up_allocated_region(width, height, region_init_proc)

/datum/component/extradimensional_storage/UnregisterFromParent()
	src.region.move_movables_to((src.exit || src.parent))
	src.region.clean_up(/turf/space, /turf/space)
	qdel(src.region)
	. = ..()

/datum/component/extradimensional_storage/proc/set_up_allocated_region(width, height, region_init_proc)
	src.region = global.region_allocator.allocate(width, height)
	if (region_init_proc)
		call(region_init_proc)(src.region, src.parent)
	else
		src.default_init_region()

/datum/component/extradimensional_storage/proc/default_init_region()
	src.region.clean_up(/turf/unsimulated/floor/setpieces/gauntlet)

	for (var/x in 2 to src.region.width - 1)
		var/turf/T = src.region.turf_at(x, 2)
		new /obj/decal/nothing{dir=NORTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = src.exit

		T = src.region.turf_at(x, src.region.height - 1)
		new /obj/decal/nothing{dir=SOUTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = src.exit

	for (var/y in 2 to src.region.height - 1)
		var/turf/T = src.region.turf_at(2, y)
		new /obj/decal/nothing{dir=WEST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = src.exit

		T = src.region.turf_at(src.region.width - 1, y)
		new /obj/decal/nothing{dir=EAST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = src.exit

/datum/component/extradimensional_storage/proc/on_entered()
	return

/datum/component/extradimensional_storage/proc/on_disposing()
	src.exit = null
	qdel(src)
