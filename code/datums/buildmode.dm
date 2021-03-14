ABSTRACT_TYPE(/datum/buildmode)
/datum/buildmode
	var/list/extra_buttons = list()
	var/hotkey_number = null
	var/name = "You shouldn't see me."
	var/desc = "<span class='alert'>Someone is a lazy bum.</span>"
	var/datum/buildmode_holder/holder = null
	var/icon_state = null
	var/admin_level = LEVEL_BABBY // restricts certain things to certain ranks
	var/atom/movable/screen/buildmode/hotkey/hotkey_button = null
	var/button_mode_text

	New(var/datum/buildmode_holder/H)
		..()
		holder = H
		update_button_text()

	proc/copy()
		var/datum/buildmode/new_mode = semi_deep_copy(src, copy_flags=COPY_SHALLOW_EXCEPT_FOR_LISTS)
		new_mode.hotkey_button = null
		new_mode.hotkey_number = null
		return new_mode

	// Called when mode is selected
	proc/selected()
		for (var/atom/movable/screen/S in extra_buttons)
			holder.owner.screen += S
		if(src.hotkey_number)
			src.hotkey_button?.color = list(0,0,1,0,1,0,1,0,0)
		else
			src.holder.button_mode.color = list(0,0,1,0,1,0,1,0,0)
		holder.button_mode.maptext = src.button_mode_text

	// Called when mode is deselected
	proc/deselected()
		for (var/atom/movable/screen/S in extra_buttons)
			holder.owner.screen -= S
		src.hotkey_button?.color = null
		if(isnull(src.hotkey_number))
			src.holder.button_mode.color = null

	// Called when entering buildmode
	proc/resumed()
		for (var/atom/movable/screen/S in extra_buttons)
			holder.owner.screen += S

	proc/on_add_to_hotkey_bar()
		src.hotkey_button = new(null, src.holder, src)
		src.hotkey_button.name = src.name
		src.hotkey_button.desc = src.desc
		src.hotkey_button.icon_state = src.icon_state
		src.hotkey_button.maptext = "<span class='ol pixel'>[src.hotkey_number % 10]</span>"

	// Called when exiting buildmode
	proc/paused()
		for (var/atom/movable/screen/S in extra_buttons)
			holder.owner.screen -= S

	proc/update_icon_state(var/newstate)
		icon_state = newstate
		holder.update_mode_icon()

	proc/update_button_text(var/new_text = "")
		src.button_mode_text = "<span style='font-family: Tahoma; -dm-text-outline: 1px black; vertical-align: top; font-size: 9px;'><strong>[name]</strong><br>[new_text]</span>"
		if(holder?.mode == src)
			holder.button_mode.maptext = src.button_mode_text

	// For when you absolutely must handle all clicks yourself.
	// Not recommended.
	// Do not use in tandem with the other click procs.
	proc/click_raw(var/atom/object, location, control, params)

	proc/click_mode_right(var/ctrl, var/alt, var/shift)

	proc/click_left(atom/object, var/ctrl, var/alt, var/shift)

	proc/click_right(atom/object, var/ctrl, var/alt, var/shift)

/datum/buildmode_holder
	var/client/owner
	var/datum/buildmode/mode
	var/list/modes_cache = list()
	var/list/hotkey_bar

	var/is_active = 0
	var/dir = SOUTH

	New(var/client/C)
		..()
		hotkey_bar = list()
		hotkey_bar.len = 10

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
			if (!mode || istype(M, /datum/buildmode/spawn_single))
				select_mode(M)
			modes_cache += M.name
			modes_cache[M.name] = M

	proc/select_mode(var/datum/buildmode/M)
		if (mode)
			mode.deselected()
		mode = M
		M.selected()
		update_mode_icon()
		if(isnull(M.hotkey_number))
			display_help()

	proc/number_key_pressed(numkey, keys_modifier)
		var/index = numkey
		if(index == 0)
			index = 10
		if(keys_modifier & MODIFIER_SHIFT)
			if(!isnull(src.hotkey_bar[index]))
				if(alert("Replace keybind [index] with [src.mode.name]?", "Replace?", "Yes", "No") == "No")
					return FALSE
				src.remove_from_hotkey_bar(src.hotkey_bar[index])
			src.add_to_hotkey_bar(src.mode.copy(), index)
			return TRUE
		else if(!isnull(src.hotkey_bar[index]))
			src.select_mode(src.hotkey_bar[index])
			return TRUE
		return FALSE

	proc/update_mode_icon()
		button_mode.icon_state = mode.icon_state
		button_mode.maptext_width = 256
		button_mode.maptext_height = 64
		button_mode.maptext_y = -64
		button_mode.maptext_x = -62

	proc/build_click(atom/target, location, control, list/params)
		if (istype(target, /atom/movable/screen/buildmode))
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
		for(var/datum/buildmode/mode in src.hotkey_bar)
			if(mode.hotkey_button)
				owner.screen += mode.hotkey_button
		mode.resumed()

	proc/deactivate()
		is_active = 0
		owner.screen -= button_dir
		owner.screen -= button_help
		owner.screen -= button_mode
		owner.screen -= button_quit
		for(var/datum/buildmode/mode in src.hotkey_bar)
			if(mode.hotkey_button)
				owner.screen -= mode.hotkey_button
		mode.paused()

	proc/add_to_hotkey_bar(datum/buildmode/mode, index=null)
		if(isnull(index))
			for(var/i in 1 to length(src.hotkey_bar))
				if(isnull(src.hotkey_bar[i]))
					index = i
					break
		if(isnull(index))
			return FALSE
		src.hotkey_bar[index] = mode
		mode.hotkey_number = index
		mode.on_add_to_hotkey_bar()
		if(!mode.hotkey_button)
			src.hotkey_bar[index] = null
			mode.hotkey_number = null
			return FALSE
		mode.hotkey_button.screen_loc = "NORTH,WEST+[index + 5]"
		owner.screen += mode.hotkey_button
		src.select_mode(mode)
		return TRUE

	proc/remove_from_hotkey_bar(datum/buildmode/mode)
		if(isnull(mode.hotkey_number))
			return FALSE
		if(hotkey_bar[mode.hotkey_number] != mode)
			mode.hotkey_number = null
			return FALSE
		hotkey_bar[mode.hotkey_number] = null
		owner.screen -= mode.hotkey_button
		qdel(mode.hotkey_button)
		mode.hotkey_button = null
		// at this point there should be no references to the mode anymore most likely so it should get garbage collected
		return TRUE

	proc/display_help()
		boutput(usr, "<span class='notice'>[mode.desc]</span>")

	// You shouldn't actually interact with these anymore.
	var/atom/movable/screen/buildmode/builddir/button_dir
	var/atom/movable/screen/buildmode/buildhelp/button_help
	var/atom/movable/screen/buildmode/buildmode/button_mode
	var/atom/movable/screen/buildmode/buildquit/button_quit

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

/atom/movable/screen/buildmode/builddir
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

/atom/movable/screen/buildmode/buildhelp
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

/atom/movable/screen/buildmode/buildquit
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

/atom/movable/screen/buildmode/buildmode
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
		if ("middle" in pa)
			src.holder.add_to_hotkey_bar(src.holder.mode.copy())
		else if ("left" in pa)
			var/modename = input("Select new mode", "Select new mode", holder.mode.name) in sortList(holder.modes_cache)
			if (modename == holder.mode.name && isnull(holder.mode.hotkey_number))
				return
			holder.select_mode(holder.modes_cache[modename])
		else if ("right" in pa)
			holder.mode.click_mode_right(pa.Find("ctrl"), pa.Find("alt"), pa.Find("shift"))

/atom/movable/screen/buildmode/hotkey
	density = 1
	anchored = 1
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/datum/buildmode_holder/holder = null
	var/datum/buildmode/mode = null

	New(L, H, datum/buildmode/mode)
		..()
		holder = H
		src.mode = mode

	clicked(list/pa)
		if ("middle" in pa)
			src.holder.remove_from_hotkey_bar(src.mode)
		else if ("left" in pa)
			holder.select_mode(mode)
		else if ("right" in pa)
			mode.click_mode_right(pa.Find("ctrl"), pa.Find("alt"), pa.Find("shift"))


var/image/buildmodeBlink = image('icons/effects/effects.dmi',"empdisable")//guH GUH GURGLE
/proc/blink(var/turf/T)
	if (!T)
		return

	SPAWN_DBG(0)//WHY DOUBLE SPAWN AND NEW IMAGE EVERY BLINK IT MAKES SOMEPOTATO SAD

		T.overlays += buildmodeBlink
		sleep(0.5 SECONDS)
		T.overlays -= buildmodeBlink

	//kinda gross
