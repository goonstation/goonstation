/atom/movable/screen
	anchored = ANCHORED
	plane = PLANE_HUD//wow WOW why won't you use /atom/movable/screen/hud, HUD OBJECTS???
	animate_movement = SLIDE_STEPS
	text = ""

	New(loc)
		..()
		appearance_flags |= NO_CLIENT_COLOR
		if(isatom(loc) && !istype(loc, /atom/movable/screen))
			CRASH("HUD object [identify_object(src)] was created in [identify_object(loc)]")

	set_loc(atom/newloc)
		. = ..()
		if(!isnull(newloc))
			CRASH("HUD object [identify_object(src)] was moved to [identify_object(newloc)]")

/**
 * Sets screen_loc of this screen object, in form of point coordinates,
 * with optional pixel offset (px, py).
 *
 * There's finer equivalents below this for hud datums
 *
 * If applicable, "assigned_map" has to be assigned before this proc call.
 *
 * Code Snippet licensed under MIT from /tg/station (#49960)
 * Copyright (c) 2020 Aleksej Komarov
 */
/atom/movable/screen/proc/set_position(x, y, px = 0, py = 0)
	screen_loc = "[x]:[px],[y]:[py]"
	fix_screen_loc(x, y, px, py)

/// 516 hack fix for screen_loc issues with the TGUI ByondUI element
/atom/movable/screen/proc/fix_screen_loc(x, y, px, py)
    set waitfor = FALSE
    sleep(0.1 SECONDS)
    screen_loc = "[x]:100:0,100:0"
    sleep(0.1 SECONDS)
    screen_loc = "[x]:[px],[y]:[py]"

/atom/movable/screen/hud
	plane = PLANE_HUD
	var/datum/hud/master
	var/id = ""
	var/tooltipTheme
	var/obj/item/item

/atom/movable/screen/hud/disposing()
	qdel(src.master)
	src.master = null
	// TODO: Eject on floor? Probably not for cyborg tools...
	src.item = null
	. = ..()

/atom/movable/screen/hud/clicked(list/params)
	sendclick(params, usr)

/atom/movable/screen/hud/proc/sendclick(list/params,mob/user = null)
	if (master && (!master.click_check || (user in master.mobs)))
		master.relay_click(src.id, user, params)

//WIRE TOOLTIPS
/atom/movable/screen/hud/MouseEntered(location, control, params)
	if (src.id == "stats" && istype(master, /datum/hud/human))
		var/datum/hud/human/H = master
		H.update_stats()
	if (usr.client.tooltipHolder && src.tooltipTheme)
		usr.client.tooltipHolder.showHover(src, list(
			"params" = params,
			"title" = src.name,
			"content" = (src.desc ? src.desc : null),
			"theme" = src.tooltipTheme
		))
	else
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseEntered(src, location, control, params)

/atom/movable/screen/hud/MouseExited()
	if (usr.client.tooltipHolder)
		usr.client.tooltipHolder.hideHover()
	if (master && (!master.click_check || (usr in master.mobs)))
		master.MouseExited(src)

/atom/movable/screen/hud/MouseWheel(dx, dy, loc, ctrl, parms)
	if (master && (!master.click_check || (usr in master.mobs)))
		master.scrolled(src.id, dx, dy, usr, parms, src)
		return TRUE

/atom/movable/screen/hud/mouse_drop(atom/over_object, src_location, over_location, over_control, params)
	if (master && (!master.click_check || (usr in master.mobs)))
		master.MouseDrop(src, over_object, src_location, over_location, over_control, params)

/atom/movable/screen/hud/MouseDrop_T(atom/movable/O as obj, mob/user as mob, src_location, over_location, over_control, src_control, params)
	if (master && (!master.click_check || (user in master.mobs)))
		master.MouseDrop_T(src, O, user, params)

/atom/movable/screen/hud/disposing()
	src.master = null
	src.item = null
	src.screen_loc = null // idk if this is necessary but im writing it anyways so there
	..()

/datum/hud
	var/list/mob/living/mobs = list()
	var/list/client/clients = list()
	var/list/atom/movable/screen/hud/objects = list()
	var/click_check = 1

	/**
	* List of `/datum/hud_zone`s, see hudzones/README
	**/
	var/list/datum/hud_zone/hud_zones = list()

	disposing()
		for (var/mob/M in src.mobs)
			M.detach_hud(src)
		for (var/atom/movable/Obj in src.objects)
			Obj.plane = initial(Obj.plane)
			if(istype(Obj, /atom/movable/screen/hud))
				var/atom/movable/screen/hud/H = Obj
				if (H.master == src)
					H.master = null
		src.objects = null

		for (var/datum/hud_zone/zone in src.hud_zones)
			qdel(zone)
		src.hud_zones = null

		for (var/client/C in src.clients)
			remove_client(C)

		src.clear_master()
		..()

	proc/clear_master() //only some have masters. i use this for clean gc. itzs messy, im sorry
		.= 0

	proc/check_objects()
		for (var/i = 1; i <= src.objects.len; i++)
			var/j = 0
			while (j+i <= src.objects.len && isnull(src.objects[j+i]))
				j++
			if (j)
				src.objects.Cut(i, i+j)

	proc/add_client(client/C)
		check_objects()
		C.screen |= src.objects
		src.clients |= C

	proc/remove_client(client/C)
		src.clients -= C
		for (var/atom/A in src.objects)
			C.screen -= A

	proc/create_screen(id, name, icon, state, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null, mouse_opacity = 1)
		if(QDELETED(src))
			CRASH("Tried to create a screen (id '[id]', name '[name]') on a deleted datum/hud")
		var/atom/movable/screen/hud/S
		if (customType)
			if (!ispath(customType, /atom/movable/screen/hud))
				CRASH("Invalid type passed to create_screen ([customType])")
			S = new customType
		else
			S = new

		S.name = name
		S.desc = desc
		S.id = id
		S.master = src
		S.icon = icon
		S.icon_state = state
		S.screen_loc = loc
		S.layer = layer
		S.set_dir(dir)
		S.tooltipTheme = tooltipTheme
		S.mouse_opacity = mouse_opacity
		src.objects += S

		for (var/client/C in src.clients)
			C.screen += S
		return S

	proc/add_object(atom/movable/A, layer = HUD_LAYER, loc)
		if (loc)
			//A.screen_loc = loc
			A.screen_loc = do_hud_offset_thing(A, loc)
		A.layer = layer
		A.plane = PLANE_HUD
		if (!(A in src.objects))
			src.objects += A
			for (var/client/C in src.clients)
				C.screen += A

	proc/remove_object(atom/movable/A)
		A.plane = initial(A.plane) // object should really be restoring this by itself, but we'll just make sure it doesnt get trapped in the HUD plane
		if (src.objects)
			src.objects -= A
		for (var/client/C in src.clients)
			C.screen -= A

	proc/add_screen(atom/movable/screen/S)
		if (!(S in src.objects))
			src.objects += S
			for (var/client/C in src.clients)
				C.screen += S

	proc/set_visible_id(id, visible)
		var/atom/movable/screen/S = get_by_id(id)
		if(S)
			if(visible)
				S.invisibility = INVIS_NONE
			else
				S.invisibility = INVIS_ALWAYS
		return

	proc/set_visible(atom/movable/screen/S, visible)
		if(S)
			if(visible)
				S.invisibility = INVIS_NONE
			else
				S.invisibility = INVIS_ALWAYS
		return

	proc/remove_screen(atom/movable/screen/S)
		if(src.objects)
			src.objects -= S
		for (var/client/C in src.clients)
			C.screen -= S

	proc/remove_screen_id(var/id)
		var/atom/movable/screen/S = get_by_id(id)
		if(S)
			if(src.objects)
				src.objects -= S
			for (var/client/C in src.clients)
				C.screen -= S

	proc/get_by_id(var/id)
		for(var/atom/movable/screen/hud/SC in src.objects)
			if(SC.id == id)
				return SC
		return null

	proc/relay_click(id)
	proc/scrolled(id, dx, dy, user, parms)
	proc/MouseEntered(id,location, control, params)
	proc/MouseExited(id)
	proc/MouseDrop(var/atom/movable/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
	proc/MouseDrop_T(var/atom/movable/screen/hud/H, atom/movable/O as obj, mob/user as mob, params)
