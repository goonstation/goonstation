// Contains:
// - Sliding door parent
// - Brig door
// - Opaque door
// - Generic door

////////////////////////////////////////////////////// Sliding door parent ////////////////////////////////////

/obj/machinery/door/window
	name = "interior door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	visible = 0
	flags = FPRINT | ON_BORDER
	health = 500
	health_max = 500
	opacity = 0
	brainloss_stumble = 1
	autoclose = TRUE
	event_handler_flags = USE_FLUID_ENTER
	object_flags = CAN_REPROGRAM_ACCESS | BOTS_DIRBLOCK | HAS_DIRECTIONAL_BLOCKING

/obj/machinery/door/window/New()
	..()

	if (src.req_access && length(src.req_access))
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	return

/obj/machinery/door/window/xmasify()
	return

/obj/machinery/door/window/attack_hand(mob/user)
	if (issilicon(user) && src.hardened == 1)
		user.show_text("You cannot control this door.", "red")
		return
	else
		return src.Attackby(null, user)

/obj/machinery/door/window/attackby(obj/item/I, mob/user)
	if (!can_act(usr))
		return
	if (src.isblocked() == 1)
		return
	if (src.operating)
		return

	src.add_fingerprint(user)

	if (src.density && src.brainloss_stumble && src.do_brainstumble(user) == 1)
		return

	if (!src.requiresID())
		if (src.density)
			src.open()
		else
			src.close()
		return

	if (src.allowed(user))
		if (src.density)
			src.open()
		else
			src.close()
	else
		if (src.density)
			flick(text("[]deny", src.base_state), src)

	return

/obj/machinery/door/window/emp_act()
	..()
	if (prob(20) && (src.density && src.cant_emag != 1 && src.isblocked() != 1))
		src.open(1)
	if (prob(40))
		if (src.secondsElectrified == 0)
			src.secondsElectrified = -1
			SPAWN(30 SECONDS)
				if (src)
					src.secondsElectrified = 0
	return

/obj/machinery/door/window/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.density && src.cant_emag != 1 && src.isblocked() != 1)
		flick(text("[]spark", src.base_state), src)
		SPAWN(0.6 SECONDS)
			if (src)
				src.open(1)
		return 1
	return 0


/obj/machinery/door/window/demag(var/mob/user)
	if (src.operating != -1)
		return 0
	src.operating = 0
	sleep(0.6 SECONDS)
	src.close()
	return 1

/obj/machinery/door/window/Cross(atom/movable/mover)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if (P.proj_data?.window_pass)
			return 1

	if (get_dir(loc, mover) & dir) // Check for appropriate border.
		if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
			if (ismob(mover) && mover:pulling && src.bumpopen(mover))
				// If they're pulling something and the door would open anyway,
				// just let the door open instead.
				return 0
			animate_door_squeeze(mover)
			return 1 // they can pass through a closed door
		return !density
	else
		return 1

/obj/machinery/door/window/gas_cross(turf/target)
	if(get_dir(loc, target) & dir)
		return !src.density
	else
		return TRUE

/obj/machinery/door/window/Uncross(atom/movable/mover, do_bump = TRUE)
	if (istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if (P.proj_data.window_pass)
			return TRUE
	if (get_dir(loc, mover.movement_newloc) & dir)
		if(density && mover && mover.flags & DOORPASS && !src.cant_emag)
			if (ismob(mover) && mover:pulling && src.bumpopen(mover))
				// If they're pulling something and the door would open anyway,
				// just let the door open instead.
				. = FALSE
				UNCROSS_BUMP_CHECK(mover)
				return
			animate_door_squeeze(mover)
			return TRUE // they can pass through a closed door
		. = !density
	else
		. = TRUE
	UNCROSS_BUMP_CHECK(mover)

/obj/machinery/door/window/update_nearby_tiles(need_rebuild)
	if (!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/target = get_step(source,dir)

	if (need_rebuild)
		if (istype(source)) // Rebuild resp. update nearby group geometry.
			if (source.parent)
				air_master.groups_to_rebuild |= source.parent
			else
				air_master.tiles_to_update |= source

		if (istype(target))
			if (target.parent)
				air_master.groups_to_rebuild |= target.parent
			else
				air_master.tiles_to_update |= target
	else
		if (istype(source)) air_master.tiles_to_update |= source
		if (istype(target)) air_master.tiles_to_update |= target

	if (istype(source))
		source.selftilenotify() //for fluids

	return 1

/obj/machinery/door/window/open(var/emag_open = 0)
	if (!ticker)
		return 0
	if (src.operating)
		return 0
	src.operating = 1

	flick(text("[]opening", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = text("[]open", src.base_state)

	SPAWN(0.8 SECONDS)
		if (src)
			src.set_density(0)
			if (ignore_light_or_cam_opacity)
				src.set_opacity(0)
			else
				src.RL_SetOpacity(0)
			src.update_nearby_tiles()
			if (emag_open == 1)
				src.operating = -1
			else
				src.operating = 0

	SPAWN(5 SECONDS)
		if (src && !src.operating && !src.density && src.autoclose == 1)
			src.close()

	return 1

/obj/machinery/door/window/close()
	if (!ticker)
		return 0
	if (src.operating)
		return 0
	src.operating = 1

	flick(text("[]closing", src.base_state), src)
	playsound(src.loc, 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = text("[]", src.base_state)

	src.set_density(1)
	if (src.visible)
		if (ignore_light_or_cam_opacity)
			src.opacity = 1
		else
			src.RL_SetOpacity(1)
	src.update_nearby_tiles()

	SPAWN(1 SECOND)
		if (src)
			src.operating = 0

	return 1

	// Since these things don't have a maintenance panel or any other place to put this, really (Convair880).
/obj/machinery/door/window/verb/toggle_autoclose()
	set src in oview(1)
	set category = "Local"

	if (isobserver(usr) || isintangible(usr))
		return
	if (!can_act(usr))
		return
	if (!in_interact_range(src, usr))
		usr.show_text("You are too far away.", "red")
		return
	if (src.hardened == 1)
		usr.show_text("You cannot control this door.", "red")
		return
	if (!src.allowed(usr))
		usr.show_text("Access denied.", "red")
		return
	if (src.operating == -1) // Emagged.
		usr.show_text("[src] is unresponsive.", "red")
		return

	if (src.autoclose)
		src.autoclose = FALSE
	else
		src.autoclose = TRUE
		SPAWN(5 SECONDS)
			if (src && !src.density)
				src.close()

	usr.show_text("Setting confirmed. [src] will [src.autoclose == 0 ? "no longer" : "now"] close automatically.", "blue")
	return

////////////////////////////////////////////// Brig door //////////////////////////////////////////////

/obj/machinery/door/window/brigdoor
	name = "Brig Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = 1
	req_access_txt = "2"
	autoclose = FALSE //brig doors close only when the cell timer starts

/obj/machinery/door/window/brigdoor/New()
	..()
	START_TRACKING

/obj/machinery/door/window/brigdoor/disposing()
	..()
	STOP_TRACKING
// Please keep synchronizied with these lists for easy map changes:
// /obj/storage/secure/closet/brig_automatic (secure_closets.dm)
// /obj/machinery/floorflusher (floorflusher.dm)
// /obj/machinery/door_timer (door_timer.dm)
// /obj/machinery/flasher (flasher.dm)
/obj/machinery/door/window/brigdoor/solitary
	name = "Cell"
	id = "solitary"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/solitary2
	name = "Cell #2"
	id = "solitary2"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/solitary3
	name = "Cell #3"
	id = "solitary3"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/solitary4
	name = "Cell #4"
	id = "solitary4"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/minibrig
	name = "Mini-Brig"
	id = "minibrig"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/minibrig2
	name = "Mini-Brig #2"
	id = "minibrig2"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/minibrig3
	name = "Mini-Brig #3"
	id = "minibrig3"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/genpop
	name = "General Population"
	id = "genpop"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/genpop_n
	name = "General Population North"
	id = "genpop_n"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/genpop_s
	name = "General Population South"
	id = "genpop_s"

	northleft
		dir = NORTH

	eastleft
		dir = EAST

	westleft
		dir = WEST

	southleft
		dir = SOUTH

	northright
		dir = NORTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

	eastright
		dir = EAST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	westright
		dir = WEST
		icon_state = "rightsecure"
		base_state = "rightsecure"

	southright
		dir = SOUTH
		icon_state = "rightsecure"
		base_state = "rightsecure"

/////////////////////////////////////////////////////////// Opaque door //////////////////////////////////////

/obj/machinery/door/window/opaque
	icon_state = "opaque-left"
	base_state = "opaque-left"
	visible = 1
	opacity = 1
/obj/machinery/door/window/opaque/northleft
	dir = NORTH
/obj/machinery/door/window/opaque/eastleft
	dir = EAST
/obj/machinery/door/window/opaque/westleft
	dir = WEST
/obj/machinery/door/window/opaque/southleft
	dir = SOUTH
/obj/machinery/door/window/opaque/northright
	dir = NORTH
	icon_state = "opaque-right"
	base_state = "opaque-right"
/obj/machinery/door/window/opaque/eastright
	dir = EAST
	icon_state = "opaque-right"
	base_state = "opaque-right"
/obj/machinery/door/window/opaque/westright
	dir = WEST
	icon_state = "opaque-right"
	base_state = "opaque-right"
/obj/machinery/door/window/opaque/southright
	dir = SOUTH
	icon_state = "opaque-right"
	base_state = "opaque-right"

//////////////////////////////////////////////////////// Generic door //////////////////////////////////////////////

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"
