/datum/component/extradimensional_storage/ladder

/datum/component/extradimensional_storage/ladder/Initialize(width = 9, height = 9, region_init_proc = null)
	if (!istype(src.parent, /obj/ladder))
		return COMPONENT_INCOMPATIBLE
	src.exit = get_turf(src.parent)
	. = ..()

	var/obj/ladder/ladder = src.parent
	ladder.unclimbable = TRUE

	var/image/I = image(icon(ladder.icon,"ladder_void"))
	I.filters += filter(type="alpha",icon=icon(ladder.icon,"[ladder.icon_state]-extra"))
	ladder.UpdateOverlays(I,"extradim")

	src.RegisterSignal(src.parent, COMSIG_ATTACKHAND, PROC_REF(on_entered))
	src.RegisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(on_disposing))

/datum/component/extradimensional_storage/ladder/UnregisterFromParent()
	var/obj/ladder/ladder = src.parent
	ladder.UpdateOverlays(null,"extradim")
	ladder.unclimbable = FALSE
	src.UnregisterSignal(src.parent, COMSIG_ATTACKHAND)
	src.UnregisterSignal(src.parent, COMSIG_PARENT_PRE_DISPOSING)
	. = ..()

/datum/component/extradimensional_storage/ladder/on_entered(atom/movable/thing, mob/user)
	var/obj/ladder/ladder = src.parent
	if (istype(ladder, /obj/ladder/embed))
		boutput(user, SPAN_SUCCESS("You enter the gap in the wall."))
	else
		boutput(user, SPAN_SUCCESS("You climb [ladder.icon_state == "ladder" ? "down" : "up"] the ladder."))
	user.set_loc(src.region.turf_at(rand(3, src.region.width - 2), rand(3, src.region.height - 2)))

/datum/component/extradimensional_storage/ladder/proc/change_overlay(icon/overlay_icon)
	var/obj/ladder/ladder = src.parent

	// cram the icon into the 32x32 space
	overlay_icon.Scale(world.icon_size,world.icon_size)
	var/image/I = image(overlay_icon)

	I.filters += filter(type="alpha",icon=icon(ladder.icon,"[ladder.icon_state]-extra"))

	ladder.UpdateOverlays(I,"extradim")
