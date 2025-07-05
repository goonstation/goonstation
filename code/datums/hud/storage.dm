
#define MAX_GROUP_SIZE 8 //! Maximum width of an inventory before it begins to wrap around. This is -1 for the first row, as the exit button takes a slot.
#define ABS_SCREEN_CENTER_X 11.5 //! The center of the screen on the x-axis for everyone. Absolutely messes up with other screen sizes than standard though
#define PIXEL_Y_ADJUST 16 //! Amount of pixels to move the UI up on TG layouts. Prevents it from overlapping with the rest of the inventory UI

/datum/hud/storage
	/* primary group is the section of the inventory grid that can be a square.
	   the secondary group is the part which will have less slots than the primary for its group */
	var/atom/movable/screen/hud/primary_group = null
	var/atom/movable/screen/hud/secondary_group = null
	var/atom/movable/screen/close_button = null //! The close button for the UI.
	var/atom/movable/screen/selection_highlight = null //! The highlight button for the UI. Used to highlight the selected slot in the inventory
	var/datum/storage/master
	var/list/obj_locs = null // hi, haine here, I'm gunna crap up this efficient code with REGEX BULLSHIT YEAHH!!
	var/empty_obj_loc = null

	New(master)
		..()
		src.master = master
		src.primary_group = create_screen("boxes", "Storage", 'icons/mob/screen1.dmi', "block", ui_storage_area)
		// top cluster only init'd when needed
		src.close_button = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
		src.selection_highlight = create_screen("sel", "sel", 'icons/mob/hud_human_new.dmi', "sel", null, HUD_LAYER+1.2)
		if(src.master)
			update()

	disposing()
		src.master = null
		src.primary_group = null
		src.secondary_group = null
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

	proc/update_box_icons(mob/user)
		var/icon/hud_style = hud_style_selection[get_hud_style(user)] // Used style of the HUD to determine background slot sprites
		if (isicon(hud_style))
			if (src.primary_group && (src.primary_group.icon != hud_style))
				src.primary_group.icon = hud_style
			if (src.secondary_group && (src.secondary_group.icon != hud_style))
				src.secondary_group.icon = hud_style

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

For inventories larger than MAX_GROUP_SIZE slots, they are composed of two UI elements for the boxes instead of one.
This is because if one 'square' element was used to cover the entire space, you would be left with extra slots which do not actually 'hold' items.

*/

	proc/update(mob/user = usr)
		if (isnull(user))
			return

		src.update_box_icons(user)

		var/tg_layout = user.client?.tg_layout //! TRUE if the user has a TG layout, FALSE if the user has a Goon layout
		// var/list/hud_contents = src.master.get_hud_contents() //! This is a list of all the things stored inside this container
		var/max_slots = src.master.get_visible_slots() //! Total amount of storage capacity for this inventory.
		var/slots_per_group = min(max_slots+1, MAX_GROUP_SIZE) //! The max amount of slots in a group, with +1 for inventories 0-7 for the 'x'
		var/groups = ceil((max_slots + 1) / slots_per_group) //! The size over the y-axis (y 'tiles'). [+1 to account for close button]
		var/pixel_y_adjust = tg_layout ? PIXEL_Y_ADJUST : 0 //! TG layouts need to be shifted up a few px to account for the UI below
		var/pos_x = tg_layout ? (ABS_SCREEN_CENTER_X - 1/2 - slots_per_group/2) : 1 //! The leftmost starting position for the inventory
		var/pos_y = tg_layout ? 2 : 1 //! The bottommost starting position for the inventory
		var/width = tg_layout ? (pos_x + slots_per_group-1) : (pos_y + groups-1-(groups>1?1:0)) //! Width which is accurate for either goon/tg layout
		var/height = tg_layout ? (pos_y + groups-1-(groups>1?1:0)) : (pos_x + slots_per_group-1) //! Height which is accurate for either goon/tg layout

		src.primary_group.screen_loc = "[pos_x],[pos_y]:[pixel_y_adjust] to [width],[height]:[pixel_y_adjust]"

		// Only setup secondary group if its needed
		if (groups > 1)
			var/primary_cluster_slots = ((groups-2)*MAX_GROUP_SIZE) + (MAX_GROUP_SIZE-1) // Middle row storage slots + Bottom row storage slots
			var/secondary_cluster_slots = max_slots - primary_cluster_slots // Will always range from 1 to MAX_GROUP_SIZE
			if (isnull(src.secondary_group))
				src.secondary_group = create_screen("boxes", "Storage", 'icons/mob/screen1.dmi', "block", ui_storage_area)
			var/start_x = tg_layout ? pos_x : (pos_x+groups-1)
			var/start_y = tg_layout ? (pos_y+groups-1) : pos_y
			var/end_x = tg_layout ? start_x + secondary_cluster_slots - 1 : start_x
			var/end_y = tg_layout ? start_y : start_y + secondary_cluster_slots - 1
			src.secondary_group.screen_loc = "[start_x],[start_y]:[pixel_y_adjust] to [end_x],[end_y]:[pixel_y_adjust]"

		close_button.screen_loc = "[pos_x-(tg_layout ? 1/2 : 0)]:[pixel_y_adjust],[pos_y]:[pixel_y_adjust]"

		// src.obj_locs = list()
		// var/i = 1 // start at 1 to skip x on first row
		// var/num_items_per_row = slots_per_group
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
		else // goon layout
			var/list/hud_contents = src.master.get_hud_contents()				//! This is a list of all the items stored inside the container
			var/num_contents = src.master.get_visible_slots()					//! Total amount of storage capacity for the inventory.
			var/contents_per_column = min(num_contents+1, MAX_GROUP_SIZE)	//! Amount of items shown in a row at the most. +1 for 1st row as exit button takes a slot
			var/height = contents_per_column									//! The size over the y-axis (y 'tiles')
			var/width = ceil((num_contents + 1) / contents_per_column)			//! The size over the x-axis (x 'tiles') [+1 to account for close button]
			var/pos_x = 1
			var/pos_y = 1

			// There is an additional -1 to the top-right corner because otherwise the screen_loc will think we want more boxes in each direction than needed
			// the ternary at the end of pos_y+height-1-(height>1?1:0) just means that we don't go to the usual max height so as not to block the top row obj
			src.primary_group.screen_loc = "[pos_x],[pos_y] to [pos_x+width-1-(width>1?1:0)],[pos_y+height-1]"

			if (width > 1)
				var/primary_cluster_slots = ((width-2)*MAX_GROUP_SIZE) + (MAX_GROUP_SIZE-1) // Middle row storage slots + Bottom row storage slots
				var/secondary_cluster_slots = num_contents - primary_cluster_slots // Will always range from 1 to MAX_GROUP_SIZE
				if (isnull(src.secondary_group))
					src.secondary_group = src.get_background_cluster()
				src.secondary_group.screen_loc = "[pos_x],[pos_y] to [pos_x+width-1],[secondary_cluster_slots]"

			if (!src.close_button)
				src.close_button = create_screen("close", "Close", 'icons/mob/screen1.dmi', "x", ui_storage_close, HUD_LAYER+1)
			src.close_button.screen_loc = "[pos_x],[pos_y]"

			src.obj_locs = list()
			var/i = 1
			for (var/obj/item/I as anything in hud_contents)
				if (!(I in src.objects)) // ugh
					add_object(I, HUD_LAYER+1)
				var/obj_loc = "[pos_x+round(i/contents_per_column)],[pos_y+(i%contents_per_column)]" //no pixel coords cause that makes click detection harder above
				var/final_loc = "[pos_x+round(i/contents_per_column)],[pos_y+(i%contents_per_column)]"
				I.screen_loc = do_hud_offset_thing(I, final_loc)
				src.obj_locs[obj_loc] = I
				i++
			empty_obj_loc = "[pos_x+round(i/contents_per_column)],[pos_y+(i%contents_per_column)]"
			master.linked_item?.UpdateIcon()
		*/

	proc/add_item(obj/item/I, mob/user = usr)
		update(user)

	proc/remove_item(obj/item/I, mob/user = usr)
		remove_object(I)
		update(user)

#undef MAX_GROUP_SIZE
#undef ABS_SCREEN_CENTER_X
#undef PIXEL_Y_ADJUST
