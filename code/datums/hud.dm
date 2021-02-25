/obj/screen
	anchored = 1
	plane = PLANE_HUD//wow WOW why won't you use /obj/screen/hud, HUD OBJECTS???
	text = ""
	New()
		..()
		appearance_flags |= NO_CLIENT_COLOR

/obj/screen/hud
	plane = PLANE_HUD
	var/datum/hud/master
	var/id = ""
	var/tooltipTheme
	var/obj/item/item

	clicked(list/params)
		sendclick(params, usr)

	proc/sendclick(list/params,mob/user = null)
		if (master && (!master.click_check || (user in master.mobs)))
			master.clicked(src.id, user, params)

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
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

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseExited(src)

	MouseWheel(dx, dy, loc, ctrl, parms)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.scrolled(src.id, dx, dy, usr, parms, src)


	MouseDrop(atom/over_object, src_location, over_location, over_control, params)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseDrop(src, over_object, src_location, over_location, over_control, params)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseDrop_T(src, O, user)


/datum/hud
	var/list/mob/living/mobs = list()
	var/list/client/clients = list()
	var/list/obj/screen/hud/objects = list()
	var/click_check = 1

	disposing()
		for (var/mob/M in src.mobs)
			M.detach_hud(src)
		for (var/obj/screen/hud/S in src.objects)
			if (S.master == src)
				S.master = null
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
		C.screen += src.objects
		src.clients += C

	proc/remove_client(client/C)
		src.clients -= C
		for (var/atom/A in src.objects)
			C.screen -= A

	proc/create_screen(id, name, icon, state, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null)
		var/obj/screen/hud/S
		if (customType)
			if (!ispath(customType, /obj/screen/hud))
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
		src.objects += S

		for (var/client/C in src.clients)
			C.screen += S
		return S

	proc/add_object(atom/movable/A, layer = HUD_LAYER, loc)
		if (loc)
			A.screen_loc = loc
		A.layer = layer
		A.plane = PLANE_HUD
		if (!src.objects.Find(A))
			src.objects += A
			for (var/client/C in src.clients)
				C.screen += A

	proc/remove_object(atom/movable/A)
		A.plane = initial(A.plane) // object should really be restoring this by itself, but we'll just make sure it doesnt get trapped in the HUD plane
		if (src.objects)
			src.objects -= A
		for (var/client/C in src.clients)
			C.screen -= A

	proc/add_screen(obj/screen/S)
		if (!src.objects.Find(S))
			src.objects += S
			for (var/client/C in src.clients)
				C.screen += S

	proc/set_visible_id(id, visible)
		var/obj/screen/S = get_by_id(id)
		if(S)
			if(visible)
				S.invisibility = 0
			else
				S.invisibility = 101
		return

	proc/set_visible(obj/screen/S, visible)
		if(S)
			if(visible)
				S.invisibility = 0
			else
				S.invisibility = 101
		return

	proc/remove_screen(obj/screen/S)
		src.objects -= S
		for (var/client/C in src.clients)
			C.screen -= S

	proc/remove_screen_id(var/id)
		var/obj/screen/S = get_by_id(id)
		if(S)
			src.objects -= S
			for (var/client/C in src.clients)
				C.screen -= S

	proc/get_by_id(var/id)
		for(var/obj/screen/hud/SC in src.objects)
			if(SC.id == id)
				return SC
		return null

	proc/clicked(id)
	proc/scrolled(id, dx, dy, user, parms)
	proc/MouseEntered(id,location, control, params)
	proc/MouseExited(id)
	proc/MouseDrop(var/obj/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
	proc/MouseDrop_T(var/obj/screen/hud/H, atom/movable/O as obj, mob/user as mob)
