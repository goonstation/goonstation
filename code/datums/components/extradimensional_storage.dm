ABSTRACT_TYPE(/datum/component/extradimensional_storage)
/datum/component/extradimensional_storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/allocated_region/region
	var/atom/exit

TYPEINFO(/datum/component/extradimensional_storage)
	initialization_args = list(
		ARG_INFO("width", DATA_INPUT_NUM, "Dimension width", 9),
		ARG_INFO("height", DATA_INPUT_NUM, "Dimension height", 9),
	)

/datum/component/extradimensional_storage/Initialize(width=9, height=9, region_init_proc=null)
	. = ..()
	region = global.region_allocator.allocate(width, height)
	if(region_init_proc)
		call(region_init_proc)(region, parent)
	else
		src.default_init_region()

/datum/component/extradimensional_storage/proc/default_init_region()
	region.clean_up(/turf/unsimulated/floor/setpieces/gauntlet)

	for(var/x in 2 to region.width - 1)
		var/turf/T = region.turf_at(x, 2)
		new/obj/decal/nothing{dir=NORTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = exit

		T = region.turf_at(x, region.height - 1)
		new/obj/decal/nothing{dir=SOUTH; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = exit

	for(var/y in 2 to region.height - 1)
		var/turf/T = region.turf_at(2, y)
		new/obj/decal/nothing{dir=WEST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = exit

		T = region.turf_at(region.width - 1, y)
		new/obj/decal/nothing{dir=EAST; color="#000"; mouse_opacity=FALSE}(T)
		new /obj/map/light/brightwhite(T)
		T.warptarget = exit

/datum/component/extradimensional_storage/proc/on_entered()
	return

/datum/component/extradimensional_storage/proc/on_disposing()
	exit = null
	qdel(src)

/datum/component/extradimensional_storage/UnregisterFromParent()
	var/obj/parent = src.parent
	src.region.move_movables_to((exit || parent))
	region.clean_up(/turf/space, /turf/space)
	qdel(region)
	. = ..()

/// subtype of the component that handles storage
/datum/component/extradimensional_storage/storage

/datum/component/extradimensional_storage/storage/Initialize(width=9, height=9, region_init_proc=null)
	if(!istype(parent, /obj/storage))
		return COMPONENT_INCOMPATIBLE
	exit = src.parent
	. = ..()

	RegisterSignal(src.parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/storage/on_entered(obj/storage/locker, atom/movable/Obj, atom/OldLoc)
	var/turf/old_turf = OldLoc
	if(istype(old_turf) && region.turf_in_region(old_turf))
		if(locker.open)
			Obj.set_loc(locker.loc)
		else
			;
	else
		Obj.set_loc(region.turf_at(rand(3, region.width - 2), rand(3, region.height - 2)))

/datum/component/extradimensional_storage/storage/UnregisterFromParent()
	UnregisterSignal(src.parent, COMSIG_ATOM_ENTERED)
	UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()

/// subtype of the component that instead handles ladders
/datum/component/extradimensional_storage/ladder

/datum/component/extradimensional_storage/ladder/Initialize(width=9, height=9, region_init_proc=null)
	if(!istype(parent, /obj/ladder))
		return COMPONENT_INCOMPATIBLE
	exit = get_turf(src.parent)
	. = ..()

	var/obj/ladder/ladder = src.parent
	ladder.unclimbable = TRUE

	var/image/I = image(icon(ladder.icon,"ladder_void"))
	I.filters += filter(type="alpha",icon=icon(ladder.icon,"[ladder.icon_state]-extra"))
	ladder.UpdateOverlays(I,"extradim")

	RegisterSignal(src.parent, COMSIG_ATTACKHAND, PROC_REF(on_entered))
	RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/ladder/proc/change_overlay(icon/overlay_icon)
	var/obj/ladder/ladder = src.parent

	// cram the icon into the 32x32 space
	overlay_icon.Scale(world.icon_size,world.icon_size)
	var/image/I = image(overlay_icon)

	I.filters += filter(type="alpha",icon=icon(ladder.icon,"[ladder.icon_state]-extra"))

	ladder.UpdateOverlays(I,"extradim")

/datum/component/extradimensional_storage/ladder/on_entered(atom/movable/thing,mob/user)
	var/obj/ladder/ladder = src.parent
	if (istype(ladder, /obj/ladder/embed))
		boutput(user, "You enter the gap in the wall.")
	else
		boutput(user, "You climb [ladder.icon_state == "ladder" ? "down" : "up"] the ladder.")
	user.set_loc(region.turf_at(rand(3, region.width - 2), rand(3, region.height - 2)))

/datum/component/extradimensional_storage/ladder/UnregisterFromParent()
	var/obj/ladder/ladder = src.parent
	ladder.UpdateOverlays(null,"extradim")
	ladder.unclimbable = FALSE
	UnregisterSignal(src.parent, COMSIG_ATTACKHAND)
	UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()
