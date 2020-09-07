ABSTRACT_TYPE(/datum/buildmode)
/datum/buildmode
	var/list/extra_buttons = list()
	New(var/datum/buildmode_holder/H)
		..()
		holder = H

	// Called when mode is selected
	proc/selected()
		for (var/obj/screen/S in extra_buttons)
			holder.owner.screen += S
		update_button_text()

	// Called when mode is deselected
	proc/deselected()
		for (var/obj/screen/S in extra_buttons)
			holder.owner.screen -= S

	// Called when entering buildmode
	proc/resumed()
		for (var/obj/screen/S in extra_buttons)
			holder.owner.screen += S

	// Called when exiting buildmode
	proc/paused()
		for (var/obj/screen/S in extra_buttons)
			holder.owner.screen -= S

	proc/update_icon_state(var/newstate)
		icon_state = newstate
		holder.update_mode_icon()

	proc/update_button_text(var/new_text = "")
		holder.button_mode.maptext	= "<span style='font-family: Tahoma; -dm-text-outline: 1px black; vertical-align: top; font-size: 9px;'><strong>[name]</strong><br>[new_text]</span>"

	// For when you absolutely must handle all clicks yourself.
	// Not recommended.
	// Do not use in tandem with the other click procs.
	proc/click_raw(var/atom/object, location, control, params)

	proc/click_mode_right(var/ctrl, var/alt, var/shift)

	proc/click_left(atom/object, var/ctrl, var/alt, var/shift)

	proc/click_right(atom/object, var/ctrl, var/alt, var/shift)

	var/name = "You shouldn't see me."
	var/desc = "<span class='alert'>Someone is a lazy bum.</span>"
	var/datum/buildmode_holder/holder = null
	var/icon_state = null
	var/admin_level = LEVEL_BABBY // restricts certain things to certain ranks

/datum/buildmode_holder
	var/client/owner
	var/datum/buildmode/mode
	var/list/modes_cache = list()

	var/is_active = 0
	var/dir = SOUTH

	New(var/client/C)
		..()
		owner = C
		button_dir = new(null, src)
		button_help = new(null, src)
		button_mode = new(null, src)
		button_quit = new(null, src)

		for (var/T in concrete_typesof(/datum/buildmode))
			var/datum/buildmode/M = new T(src)
			if ((!owner.holder && M.admin_level > LEVEL_BABBY) || M.admin_level > owner.holder.level)
				DEBUG_MESSAGE("[key_name(owner)] is too low rank to have buildmode [M.name] ([M.type]) and the buildmode is being disposed (min level is [level_to_rank(M.admin_level)] and [owner.ckey] is [owner.holder ? level_to_rank(owner.holder.level) : "not an admin"])")
				qdel(M)
				continue
			if (!mode)
				select_mode(M)
			modes_cache += M.name
			modes_cache[M.name] = M

	proc/select_mode(var/datum/buildmode/M)
		if (mode)
			mode.deselected()
		mode = M
		M.selected()
		update_mode_icon()
		display_help()

	proc/update_mode_icon()
		button_mode.icon_state = mode.icon_state
		button_mode.maptext_width = 256
		button_mode.maptext_height = 64
		button_mode.maptext_y = -64
		button_mode.maptext_x = -62

	proc/build_click(atom/target, location, control, list/params)
		if (istype(target, /obj/screen/buildmode))
			target:clicked(params)
			return
		if (params.Find("left"))
			mode.click_left(target, params.Find("ctrl"), params.Find("alt"), params.Find("shift"))
		else if (params.Find("right"))
			mode.click_right(target, params.Find("ctrl"), params.Find("alt"), params.Find("shift"))

		mode.click_raw(target, location, control, params)

	proc/activate()
		is_active = 1
		owner.screen += button_dir
		owner.screen += button_help
		owner.screen += button_mode
		owner.screen += button_quit
		mode.resumed()

	proc/deactivate()
		is_active = 0
		owner.screen -= button_dir
		owner.screen -= button_help
		owner.screen -= button_mode
		owner.screen -= button_quit
		mode.paused()

	proc/display_help()
		boutput(usr, "<span class='notice'>[mode.desc]</span>")

	// You shouldn't actually interact with these anymore.
	var/obj/screen/buildmode/builddir/button_dir
	var/obj/screen/buildmode/buildhelp/button_help
	var/obj/screen/buildmode/buildmode/button_mode
	var/obj/screen/buildmode/buildquit/button_quit

/client/proc/togglebuildmode()
	set name = "Build Mode"
	set desc = "Toggle build Mode on/off."
	SET_ADMIN_CAT(ADMIN_CAT_SELF)

	if(!src.buildmode)
		src.buildmode = new /datum/buildmode_holder(src)

	if(src.buildmode.is_active)
		src.buildmode.deactivate()
		src.show_popup_menus = 1
		if (!usr.client.holder.buildmode_view)
			usr.client.cmd_admin_aview()
		usr.see_in_dark = initial(usr.see_in_dark)
		usr.see_invisible = 16
	else
		src.buildmode.activate()
		if (!usr.client.holder.buildmode_view)
			usr.client.cmd_admin_aview()
		usr.see_in_dark = 10
		usr.see_invisible = 21
		src.show_popup_menus = 0

/obj/screen/buildmode/builddir
	name = "Set direction"
	density = 1
	anchored = 1
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = SOUTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "direction"
	screen_loc = "NORTH,WEST"
	var/datum/buildmode_holder/holder = null

	New(L, H)
		..()
		holder = H

	clicked(list/paramList)
		var/icon_x = text2num(paramList["icon-x"])
		var/icon_y = text2num(paramList["icon-y"])

		if (icon_y <= 11)
			if (icon_x <= 11)
				dir = 10
			else if (icon_x >= 22)
				dir = 6
			else
				dir = 2
		else if (icon_y >= 22)
			if (icon_x <= 11)
				dir = 9
			else if (icon_x >= 22)
				dir = 5
			else
				dir = 1
		else if (icon_x <= 16)
			dir = 8
		else
			dir = 4

		holder.dir = dir

/obj/screen/buildmode/buildhelp
	name = "Click for help"
	density = 1
	anchored = 1
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	var/datum/buildmode_holder/holder = null

	New(L, H)
		..()
		holder = H

	clicked(location, control, params)
		holder.display_help()

/obj/screen/buildmode/buildquit
	name = "Click to exit build mode"
	density = 1
	anchored = 1
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"
	var/datum/buildmode_holder/holder = null

	New(L, H)
		..()
		holder = H

	clicked(location, control, params)
		holder.owner.togglebuildmode()

/obj/screen/buildmode/buildmode
	name = "Click to select mode"
	density = 1
	anchored = 1
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/datum/buildmode_holder/holder = null

	New(L, H)
		..()
		holder = H

	clicked(list/pa)
		if (pa.Find("left"))
			var/modename = input("Select new mode", "Select new mode", holder.mode.name) in sortList(holder.modes_cache)
			if (modename == holder.mode.name)
				return
			holder.select_mode(holder.modes_cache[modename])
		else if (pa.Find("right"))
			holder.mode.click_mode_right(pa.Find("ctrl"), pa.Find("alt"), pa.Find("shift"))
var/image/buildmodeBlink = image('icons/effects/effects.dmi',"empdisable")//guH GUH GURGLE
/proc/blink(var/turf/T)
	if (!T)
		return

	SPAWN_DBG(0)//WHY DOUBLE SPAWN AND NEW IMAGE EVERY BLINK IT MAKES SOMEPOTATO SAD

		T.overlays += buildmodeBlink
		sleep(0.5 SECONDS)
		T.overlays -= buildmodeBlink

	//kinda gross
