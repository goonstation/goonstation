TYPEINFO(/obj/ladder)
	mat_appearances_to_ignore = list("negativematter")
ADMIN_INTERACT_PROCS(/obj/ladder, proc/toggle_extradimensional, proc/change_extradimensional_overlay)
ADMIN_INTERACT_PROCS(/obj/ladder/embed, proc/toggle_hidden)

/obj/ladder
	name = "ladder"
	desc = "A series of parallel bars designed to allow for controlled change of elevation.  You know, by climbing it.  You climb it."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ladder"
	anchored = ANCHORED
	density = 0
	var/id = null
	/// if true, disables ladder climbing behavior
	var/unclimbable = FALSE
	mat_changename = FALSE
	appearance_flags = KEEP_TOGETHER

/obj/ladder/broken
	name = "broken ladder"
	desc = "it's too damaged to climb."
	icon_state = "ladder_wall_broken"
	unclimbable = TRUE

/obj/ladder/embed
	name = "gap in the wall"
	icon_state = "wall_embed"
	desc = "A section of this wall appears to be missing. Entering it might take you somewhere."
	plane = PLANE_WALL
	var/hidden = FALSE

/obj/ladder/embed/climb(mob/user as mob)
	var/obj/ladder/otherLadder = src.get_other_ladder()
	if (!istype(otherLadder))
		boutput(user, "You try to enter the gap in the wall, but seriously fail! Perhaps there's nowhere to go?")
		return
	boutput(user, "You enter the gap in the wall.")
	user.set_loc(get_turf(otherLadder))

/obj/ladder/embed/New()
	. = ..()
	src.UpdateIcon()

/obj/ladder/embed/update_icon()
	. = ..()
	if (!src.hidden)
		var/turf/T = get_step(src,NORTH)
		if (!istype(T,/turf/simulated/wall) && !istype(T,/turf/unsimulated/wall))
			// if there's no wall above us, hide in a way that we still show up in orange(1)
			// so the wall can update us
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "hidden", INVIS_ALWAYS_ISH)
		else
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY,"hidden")
	else
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "hidden", INVIS_ALWAYS_ISH)


/obj/ladder/embed/ex_act(severity,last_touched)
	if (src.hidden)
		src.hidden = FALSE
		src.UpdateIcon()
	. = ..(severity, last_touched)

/obj/ladder/embed/extradimensional
	default_material = "negativematter"

/obj/ladder/extradimensional
	default_material = "negativematter"

// admin interact procs
/obj/ladder/proc/toggle_extradimensional()
	set name = "Toggle Extradimensional"

	var/datum/component/E = src.GetComponent(/datum/component/extradimensional_storage/ladder)
	if (E)
		E.RemoveComponent(/datum/component/extradimensional_storage/ladder)
	else
		src.AddComponent(/datum/component/extradimensional_storage/ladder)

/obj/ladder/proc/change_extradimensional_overlay()
	set name = "Change Extradimensional Overlay"

	var/datum/component/extradimensional_storage/ladder/E = src.GetComponent(/datum/component/extradimensional_storage/ladder)
	if (!E)
		return
	var/mob/user = usr
	var/icon_to_use = input(user, "Icon to use for the overlay") as icon | null
	if (icon_to_use)
		var/icon/icon = icon(icon_to_use)
		E.change_overlay(icon)

/obj/ladder/embed/proc/toggle_hidden()
	set name = "Toggle Hidden"
	src.hidden = !src.hidden
	src.update_icon()

/obj/ladder/New()
	..()
	START_TRACKING
	if (!id)
		id = "generic"
	src.update_id()

/obj/ladder/disposing()
	STOP_TRACKING
	. = ..()

/obj/ladder/onMaterialChanged()
	. = ..()
	if(isnull(src.material))
		return
	var/found_negative = (src.material.getID() == "negativematter")
	if(!found_negative)
		for(var/datum/material/parent_mat in src.material.getParentMaterials())
			if(parent_mat.getID() == "negativematter")
				found_negative = TRUE
				break
	if(found_negative)
		src.AddComponent(/datum/component/extradimensional_storage/ladder)

/obj/ladder/proc/update_id(new_id)
	if(new_id)
		src.id = new_id
	src.tag = "ladder_[id][src.icon_state == "ladder" ? 0 : 1]"

/obj/ladder/proc/get_other_ladder()
	RETURN_TYPE(/atom)
	. = locate("ladder_[id][src.icon_state == "ladder"]")

/obj/ladder/embed/update_id(new_id)
	if(new_id)
		src.id = new_id
	src.tag = "ladder_[id]embed"

/obj/ladder/embed/get_other_ladder() // these literally do not care which is the top
	RETURN_TYPE(/atom)
	for_by_tcl(ladder,/obj/ladder)
		if (ladder.id == src.id && ladder != src)
			return ladder

/obj/ladder/attack_hand(mob/user)
	if (src.unclimbable) return
	if (user.stat || user.getStatusDuration("weakened") || BOUNDS_DIST(user, src) > 0)
		return
	src.climb(user)

/obj/ladder/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/ladder/attackby(obj/item/W, mob/user)
	if (src.unclimbable) return
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/grab = W
		if (!grab.affecting || BOUNDS_DIST(grab.affecting, src) > 0)
			return
		user.lastattacked = src
		src.visible_message("<span class='alert'><b>[user] is trying to shove [grab.affecting] [icon_state == "ladder"?"down":"up"] [src]!</b></span>")
		return climb(grab.affecting)

/obj/ladder/proc/climb(mob/user as mob)
	var/obj/ladder/otherLadder = src.get_other_ladder()
	if (!istype(otherLadder))
		boutput(user, "You try to climb [src.icon_state == "ladder" ? "down" : "up"] the ladder, but seriously fail! Perhaps there's nowhere to go?")
		return

	boutput(user, "You climb [src.icon_state == "ladder" ? "down" : "up"] the ladder.")

	// do the fancy thing i stole from kitchen grinders
	var/atom/movable/proxy = new(src)
	proxy.mouse_opacity = FALSE
	proxy.appearance = user.appearance
	proxy.transform = null
	proxy.dir = NORTH

	if (src.icon_state == "ladder") // only filter if we're the top
		proxy.add_filter("ladder_climbmask", 1, alpha_mask_filter(x=0, y=0, icon=icon('icons/obj/kitchen_grinder_mask.dmi', "ladder-mask")))

	user.set_loc(src)
	src.vis_contents += proxy

	// if we're not the top ladder, animate up instead of down
	var/climbdir = src.icon_state == "ladder" ? 1 : -1

	animate(proxy, pixel_y = -32*climbdir, time = 1 SECOND)
	if (src.icon_state == "ladder")
		animate(proxy.get_filter("ladder_climbmask"), y = 32, time = 1 SECOND, flags = ANIMATION_PARALLEL)

	SPAWN(1 SECOND) // after the animation is done, teleport and clean up
		if (user.loc == src)
			if (get_turf(otherLadder))
				user.set_loc(get_turf(otherLadder))
			else
				user.set_loc(get_turf(src))

		src.vis_contents -= proxy
		qdel(proxy)
