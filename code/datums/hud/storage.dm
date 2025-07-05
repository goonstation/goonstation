
#define MAX_INVENTORY_WIDTH 8 //! Maximum width of an inventory before it begins to wrap around. This is -1 for the first row, as the exit button takes a slot.
#define ABS_SCREEN_CENTER_X 11.5 //! The center of the screen on the x-axis for everyone. Absolutely messes up with other screen sizes than standard though
/datum/hud/storage
	var/atom/movable/screen/hud/boxes_bottom = null //! The bottom grid of boxes. Used with boxes_top to make the UI
	var/atom/movable/screen/hud/boxes_top = null //! The top row of boxes. Used with boxes_bottom to make the UI
	var/atom/movable/screen/close_button = null //! The close button for the UI.
	var/atom/movable/screen/selection_highlight = null //! The highlight button for the UI. Used to highlight the selected slot in the inventory
	var/datum/storage/master
	var/list/obj_locs = null // hi, haine here, I'm gunna crap up this efficient code with REGEX BULLSHIT YEAHH!!
	var/empty_obj_loc = null

	New(master)
		..()
		src.master = master
		src.boxes_bottom = src.get_background_cluster()
		// top cluster only init'd when needed
		src.close_button = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
		src.selection_highlight = create_screen("sel", "sel", 'icons/mob/hud_human_new.dmi', "sel", null, HUD_LAYER+1.2)
		if(src.master)
			update()

	disposing()
		src.master = null
		src.boxes_bottom = null
		src.boxes_top = null
		src.close_button.dispose()
		src.obj_locs.len = 0
		src.obj_locs = null
		..()

	clear_master()
		master = null
		..()

	relay_click(id, mob/user, params)
		switch (id)
			if ("boxes")
				var/clicked_loc = src.get_clicked_position(user, params)
				if (!clicked_loc)
					return
				var/obj/item/I = src.obj_locs[clicked_loc]
				if (I)
					//DEBUG_MESSAGE("clicking [I] with params [list2params(params)]")
					user.click(I, params)
				else if (user.equipped())
					//DEBUG_MESSAGE("clicking [src.master.linked_item] with [user.equipped()] with params [list2params(params)]")
					user.click(src.master.linked_item, params)

			if ("close")
				user.detach_hud(src)
				user.s_active = null

	//issue below with th4e way we draw boxes : all boxes are one object drawn multiple tiles using screenloc...
	//I cannot get specific values for one box or find which item is in which box without some maybe-expensive string parsing. Figure out not-slow fix later
	MouseEntered(var/atom/movable/screen/hud/H, location, control, params)
		if (!H || H.id != "boxes") return
		if (usr)
			var/obj/item/I = usr.equipped()
			if (src.master && I && src.master.linked_item.loc == usr && src.master.hud_can_add(I))
				selection_highlight.screen_loc = empty_obj_loc


	MouseExited(var/atom/movable/screen/hud/H)
		if (!H) return
		selection_highlight.screen_loc = null

	MouseDrop_T(atom/movable/screen/hud/H, atom/movable/O, mob/user, params)
		if (!(user in src.mobs))
			return
		if (!(O in src.master.get_contents()))
			return
		var/clicked_position = src.get_clicked_position(user, params)
		if (!clicked_position)
			return
		if (src.obj_locs[clicked_position] == O)
			user.click(O, params2list(params))

	/// returns position of the hud clicked
	proc/get_clicked_position(mob/user, list/params)
		if (!params)
			return
		if (!islist(src.obj_locs))
			return

		var/list/prams = params
		if (!islist(prams))
			prams = params2list(prams)
		if (!islist(prams))
			return

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
		var/turfd = (isturf(master.linked_item.loc) && !istype(master.linked_item, /obj/item/bible))

		var/pixel_y_adjust = 0
		if (user && user.client && user.client.tg_layout && !turfd)
			pixel_y_adjust = 1

		if (pixel_y_adjust && text2num(py) > 16)
			y = text2num(y) + 1
			py = text2num(py) - 16
		//end dumb hack

		return "[x],[y]"

	proc/get_background_cluster()
		return create_screen("boxes", "Storage", 'icons/mob/screen1.dmi', "block", ui_storage_area)

	proc/update_box_icons(mob/user)
		var/icon/hud_style = hud_style_selection[get_hud_style(user)] // Used style of the HUD to determine background slot sprites
		if (isicon(hud_style))
			if (src.boxes_bottom && (src.boxes_bottom.icon != hud_style))
				src.boxes_bottom.icon = hud_style
			if (src.boxes_top && (src.boxes_top.icon != hud_style))
				src.boxes_top.icon = hud_style

//idk if i can even use the params of mousedrop for this
/*
	mouse_drop(var/atom/movable/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
		var/obj/item/I = src.obj_locs[H.screen_loc]
		if (I)
			I.mouse_drop(over_object, src_location, over_location, over_control, params)
*/
/*
Updates a storage inventory which is being seen by a player/mob. The layout is dependent on the HUD option (TG/Goon).

Here's some helpful images in case you're unsure what either is meant to look like:

image_tg_inventory.png
image_goon_inventory.png

Both inventories will always have the 'close' button in the bottom-left corner.

The individual inventory 'background' slots are an illusion, the sprite itself is a repeating tile on one UI element. Moreover, the objects are just
plastered on top with an offset. Neither are particularly aware of the other, they just happen to co-exist.

For inventories larger than MAX_INVENTORY_WIDTH slots, they are composed of two UI elements for the boxes instead of one.
This is because if one 'square' element was used to cover the entire space, you would be left with extra slots which do not actually 'hold' items.

*/

	proc/update(mob/user = usr)

		if (isnull(user))
			return

		var/list/hud_contents = src.master.get_hud_contents()				//! This is a list of all the items stored inside the container
		var/num_contents = src.master.get_visible_slots()					//! Total amount of storage capacity for the inventory.
		var/num_contents_per_row = min(num_contents, MAX_INVENTORY_WIDTH)	//! Amount of items shown in a row at the most. 1 shorter for 1st row as exit button takes a slot
		var/tg_layout = user.client?.tg_layout								//! TRUE if the user has a TG layout, FALSE if the user has a Goon layout
		var/pixel_y_adjust = tg_layout ? 16 : 0								//! Slight y-adjustment for TG UIs, none for Goon UIs. Used to have a gap between inventory and usual UI
		var/width = num_contents_per_row									//! The size over the x-axis (x 'tiles')
		var/pos_x = ABS_SCREEN_CENTER_X - 1/2 - width/2
		var/pos_y = 2														//! The initial position relative to the bottomleft portion of the grid (1,1)
		var/height = ceil((num_contents + 1) / num_contents_per_row)		//! The size over the y-axis (y 'tiles'). [+1 to account for close button]
		var/center = user.getScreenParams()
		src.update_box_icons(user)

		src.boxes_bottom.screen_loc = "CENTER-[width/2],[pos_y]:[pixel_y_adjust] to CENTER+[width/2-1],[pos_y+height-2]:[pixel_y_adjust]"

		if (height > 1)
			var/bottom_cluster_slots = ((height-2)*MAX_INVENTORY_WIDTH) + (MAX_INVENTORY_WIDTH-1) // Middle row storage slots + Bottom row storage slots
			var/top_cluster_slots = num_contents - bottom_cluster_slots // Will always range from 0 to MAX_INVENTORY_WIDTH
			if (top_cluster_slots > 0)
				if (isnull(src.boxes_top))
					src.boxes_top = src.get_background_cluster()
				src.boxes_top.screen_loc = "[pos_x],[pos_y+height]:[pixel_y_adjust] to [pos_x-(MAX_INVENTORY_WIDTH-top_cluster_slots)],[pos_y+height]:[pixel_y_adjust]"

		if (!close_button)
			src.close_button = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
		close_button.screen_loc = "[pos_x+1/2]:[pixel_y_adjust],[pos_y]:[pixel_y_adjust]"

		// src.obj_locs = list()
		// var/i = 0
		// var/num_items_per_row = num_contents_per_row - 1
		// for (var/obj/item/I as anything in hud_contents)
		// 	if (!(I in src.objects)) // ugh
		// 		add_object(I, HUD_LAYER+1)
		// 	var/obj_loc = "[pos_x+(i%num_items_per_row)],[pos_y+round(i/num_items_per_row)]" //no pixel coords cause that makes click detection harder above
		// 	var/final_loc = "[pos_x+(i%num_items_per_row)],[pos_y+round(i/num_items_per_row)]:[pixel_y_adjust]"
		// 	I.screen_loc = do_hud_offset_thing(I, final_loc)
		// 	src.obj_locs[obj_loc] = I
		// 	i++
		// empty_obj_loc =  "[pos_x+(i%num_items_per_row)],[pos_y+round(i/num_items_per_row)]:[pixel_y_adjust]"
		// master.linked_item?.UpdateIcon()

		/*
		if (user && user.client?.tg_layout)
			pass
		else
			// Goon HUD layout is vertical, implementation is here.
			pos_x = 1
			pos_y = num_contents_per_row + 1
			size_x = ceil(num_contents / MAX_INVENTORY_WIDTH)
			size_y = num_contents_per_row + 1

			boxes.screen_loc = "[pos_x],[pos_y]:[0] to [pos_x+size_x-1],[pos_y-size_y+1]:[0]"
			if (!close)
				src.close = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
			close.screen_loc = "[pos_x+size_x-1]:[0],[pos_y-size_y+1]:[0]"

			src.obj_locs = list()
			var/i = 0
			for (var/obj/item/I as anything in hud_contents)
				if (!(I in src.objects)) // ugh
					add_object(I, HUD_LAYER+1)
				var/obj_loc = "[pos_x+(i%size_x)],[pos_y-round(i/size_x)]" //no pixel coords cause that makes click detection harder above
				var/final_loc = "[pos_x+(i%size_x)],[pos_y-round(i/size_x)]:[0]"
				I.screen_loc = do_hud_offset_thing(I, final_loc)
				src.obj_locs[obj_loc] = I
				i++
			empty_obj_loc =  "[pos_x+(i%size_x)],[pos_y-round(i/size_x)]:[0]"
			master.linked_item?.UpdateIcon()
		*/

	proc/add_item(obj/item/I, mob/user = usr)
		update(user)

	proc/remove_item(obj/item/I, mob/user = usr)
		remove_object(I)
		update(user)

#undef MAX_INVENTORY_WIDTH
#undef ABS_SCREEN_CENTER_X
