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
	flags = ON_BORDER
	opacity = 0
	brainloss_stumble = 1
	autoclose = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CHECKEXIT | USE_CANPASS
	object_flags = CAN_REPROGRAM_ACCESS

	New()
		..()

		if (src.req_access && src.req_access.len)
			src.icon_state = "[src.icon_state]"
			src.base_state = src.icon_state
		return

	attack_hand(mob/user as mob)
		if (issilicon(user) && src.hardened == 1)
			user.show_text("You cannot control this door.", "red")
			return
		else
			return src.attackby(null, user)

	attackby(obj/item/I as obj, mob/user as mob)
		if (user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || user.stat || user.restrained())
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

	emp_act()
		..()
		if (prob(20) && (src.density && src.cant_emag != 1 && src.isblocked() != 1))
			src.open(1)
		if (prob(40))
			if (src.secondsElectrified == 0)
				src.secondsElectrified = -1
				SPAWN_DBG(30 SECONDS)
					if (src)
						src.secondsElectrified = 0
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.density && src.cant_emag != 1 && src.isblocked() != 1)
			flick(text("[]spark", src.base_state), src)
			SPAWN_DBG(0.6 SECONDS)
				if (src)
					src.open(1)
			return 1
		return 0


	demag(var/mob/user)
		if (src.operating != -1)
			return 0
		src.operating = 0
		sleep(0.6 SECONDS)
		close()
		return 1

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if (P.proj_data.window_pass)
				return 1

		if (get_dir(loc, target) == dir) // Check for appropriate border.
			return !density
		else
			return 1

	CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
		if (istype(mover, /obj/projectile))
			var/obj/projectile/P = mover
			if (P.proj_data.window_pass)
				return 1

		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1

	update_nearby_tiles(need_rebuild)
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

	open(var/emag_open = 0)
		if (!ticker)
			return 0
		if (src.operating)
			return 0
		src.operating = 1

		flick(text("[]opening", src.base_state), src)
		playsound(src.loc, "sound/machines/windowdoor.ogg", 100, 1)
		src.icon_state = text("[]open", src.base_state)

		SPAWN_DBG(0.8 SECONDS)
			if (src)
				src.set_density(0)
				if (ignore_light_or_cam_opacity)
					src.opacity = 0
				else
					src.RL_SetOpacity(0)
				src.update_nearby_tiles()
				if (emag_open == 1)
					src.operating = -1
				else
					src.operating = 0

		SPAWN_DBG(5 SECONDS)
			if (src && !src.operating && !src.density && src.autoclose == 1)
				src.close()

		return 1

	close()
		if (!ticker)
			return 0
		if (src.operating)
			return 0
		src.operating = 1

		flick(text("[]closing", src.base_state), src)
		playsound(src.loc, "sound/machines/windowdoor.ogg", 100, 1)
		src.icon_state = text("[]", src.base_state)

		src.set_density(1)
		if (src.visible)
			if (ignore_light_or_cam_opacity)
				src.opacity = 1
			else
				src.RL_SetOpacity(1)
		src.update_nearby_tiles()

		SPAWN_DBG(1 SECOND)
			if (src)
				src.operating = 0

		return 1

	// Since these things don't have a maintenance panel or any other place to put this, really (Convair880).
	verb/toggle_autoclose()
		set src in oview(1)
		set category = "Local"

		if (isobserver(usr) || isintangible(usr))
			return
		if (usr.getStatusDuration("stunned") > 0 || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis") > 0 || usr.stat || usr.restrained())
			return
		if (!in_range(src, usr))
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
			src.autoclose = 0
		else
			src.autoclose = 1
			SPAWN_DBG(5 SECONDS)
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
	var/id = 1.0
	req_access_txt = "2"
	autoclose = 0 //brig doors close only when the cell timer starts

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig/automatic (secure_closets.dm)
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door_timer (door_timer.dm)
	// /obj/machinery/flasher (flasher.dm)
	solitary
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

	solitary2
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

	solitary3
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

	solitary4
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

	minibrig
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

	minibrig2
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

	minibrig3
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

	genpop
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

	genpop_n
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

	genpop_s
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
