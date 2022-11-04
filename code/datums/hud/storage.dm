/datum/hud/storage
	var/atom/movable/screen/hud
		boxes
		close
		sel
	var/obj/item/storage/master
	var/list/obj_locs = null // hi, haine here, I'm gunna crap up this efficient code with REGEX BULLSHIT YEAHH!!
	var/empty_obj_loc = null

	New(master)
		..()
		src.master = master
		src.boxes = create_screen("boxes", "Storage", 'icons/mob/screen1.dmi', "block", ui_storage_area)
		src.close = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
		src.sel = create_screen("sel", "sel", 'icons/mob/hud_human_new.dmi', "sel", null, HUD_LAYER+1.2)
		if(src.master)
			update()

	disposing()
		src.master = null
		src.boxes.dispose()
		src.close.dispose()
		src.obj_locs.len = 0
		src.obj_locs = null
		..()

	clear_master()
		master = null
		..()

	relay_click(id, mob/user, params)
		switch (id)
			if ("boxes")
				if (params && islist(src.obj_locs))
					var/list/prams = params
					if (!islist(prams))
						prams = params2list(prams)
					if (islist(prams))
						var/clicked_loc = prams["screen-loc"] // should be in the format 1:16,1:16 (tile x : pixel offset x, tile y : pixel offset y)
						//DEBUG_MESSAGE(clicked_loc)
						//var/regex/loc_regex = regex("(\\d*):\[^,]*,(\\d*):\[^\n]*")
						//clicked_loc = loc_regex.Replace(clicked_loc, "$1,$2")
						//DEBUG_MESSAGE(clicked_loc)

						//MBC : I DONT KNOW REGEX BUT THE ABOVE IS NOT WORKING LETS DO THIS INSTEAD


						var/firstcolon = findtext(clicked_loc,":")
						var/comma = findtext(clicked_loc,",")
						var/secondcolon = findtext(clicked_loc,":",comma)
						if (firstcolon == secondcolon)
							if (firstcolon > comma)
								firstcolon = 0
							else
								secondcolon = 0

						var/x = copytext(clicked_loc,1,firstcolon ? firstcolon : comma)
						var/px = firstcolon ? copytext(clicked_loc,firstcolon+1,comma) : 0
						var/y = copytext(clicked_loc,comma+1,secondcolon ? secondcolon : 0)
						var/py = secondcolon ? copytext(clicked_loc,secondcolon+1) : 0

						if (user.client && user.client.byond_version == 512 && user.client.byond_build == 1469) //sWAP EM BECAUSE OF BAD BYOND BUG
							var/temp = y
							y = px
							px = temp

						//ddumb hack for offset storage
						var/turfd = (isturf(master.loc) && !istype(master, /obj/item/storage/bible))

						var/pixel_y_adjust = 0
						if (user && user.client && user.client.tg_layout && !turfd)
							pixel_y_adjust = 1

						if (pixel_y_adjust && text2num(py) > 16)
							y = text2num(y) + 1
							py = text2num(py) - 16
						//end dumb hack

						clicked_loc = "[x],[y]"


						var/obj/item/I = src.obj_locs[clicked_loc]
						if (I)
							//DEBUG_MESSAGE("clicking [I] with params [list2params(params)]")
							user.click(I, params)
						else if (user.equipped())
							//DEBUG_MESSAGE("clicking [src.master] with [user.equipped()] with params [list2params(params)]")
							user.click(src.master, params)

			if ("close")
				user.detach_hud(src)
				user.s_active = null

	//issue below with th4e way we draw boxes : all boxes are one object drawn multiple tiles using screenloc...
	//I cannot get specific values for one box or find which item is in which box without some maybe-expensive string parsing. Figure out not-slow fix later
	MouseEntered(var/atom/movable/screen/hud/H, location, control, params)
		if (!H || H.id != "boxes") return
		if (usr)
			var/obj/item/I = usr.equipped()
			if (src.master && I && src.master.loc == usr && src.master.check_can_hold(I)>0)
				sel.screen_loc = empty_obj_loc


	MouseExited(var/atom/movable/screen/hud/H)
		if (!H) return
		sel.screen_loc = null

//idk if i can even use the params of mousedrop for this
/*
	mouse_drop(var/atom/movable/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
		var/obj/item/I = src.obj_locs[H.screen_loc]
		if (I)
			I.mouse_drop(over_object, src_location, over_location, over_control, params)
*/
	proc/update(mob/user = usr)
		var x = 1
		var y = 1 + master.slots
		var sx = 1
		var sy = master.slots + 1
		var/turfd = 0

		if (isturf(master.loc) && !istype(master, /obj/item/storage/bible)) // goddamn BIBLES (prevents conflicting positions within different bibles)
			x = 7
			y = 8
			sx = (master.slots + 1) / 2
			sy = 2

			turfd = 1

		if (istype(user,/mob/living/carbon/human))
			if (user.client && user.client.tg_layout) //MBC TG OVERRIDE IM SORTY
				x = 11 - round(master.slots / 2)
				y = 3
				sx = master.slots + 1
				sy = 1

				if (turfd) // goddamn BIBLES (prevents conflicting positions within different bibles)
					x = 8
					y = 8
					sx = (master.slots + 1) / 2
					sy = 2

		if (!boxes)
			return
		if (ishuman(user))
			var/mob/living/carbon/human/player = user
			var/icon/hud_style = hud_style_selection[get_hud_style(player)]
			if (isicon(hud_style) && boxes.icon != hud_style)
				boxes.icon = hud_style

		var/pixel_y_adjust = 0
		if (user && user.client && user.client.tg_layout && !turfd)
			pixel_y_adjust = -16

		boxes.screen_loc = "[x],[y]:[pixel_y_adjust] to [x+sx-1],[y-sy+1]:[pixel_y_adjust]"
		if (!close)
			src.close = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
		close.screen_loc = "[x+sx-1]:[pixel_y_adjust],[y-sy+1]:[pixel_y_adjust]"

		if (!turfd && istype(user,/mob/living/carbon/human))
			if (user && user.client?.tg_layout) //MBC TG OVERRIDE IM SORTY
				boxes.screen_loc = "[x-1],[y]:[pixel_y_adjust] to [x+sx-2],[y-sy+1]:[pixel_y_adjust]"
				close.screen_loc = "[x-1],[y-sy+1]:[pixel_y_adjust]"

		src.obj_locs = list()
		var/i = 0
		for (var/obj/item/I in master.get_contents())
			if (!(I in src.objects)) // ugh
				add_object(I, HUD_LAYER+1)
			var/obj_loc = "[x+(i%sx)],[y-round(i/sx)]" //no pixel coords cause that makes click detection harder above
			var/final_loc = "[x+(i%sx)],[y-round(i/sx)]:[pixel_y_adjust]"
			I.screen_loc = do_hud_offset_thing(I, final_loc)
			src.obj_locs[obj_loc] = I
			i++
		empty_obj_loc =  "[x+(i%sx)],[y-round(i/sx)]:[pixel_y_adjust]"
		if(isitem(master))
			var/obj/item/I = master
			I.tooltip_rebuild = 1
		master.UpdateIcon()

	proc/add_item(obj/item/I, mob/user = usr)
		update(user)

	proc/remove_item(obj/item/I)
		remove_object(I)
		update()
