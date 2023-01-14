/atom/movable/screen
	anchored = 1
	plane = PLANE_HUD//wow WOW why won't you use /atom/movable/screen/hud, HUD OBJECTS???
	text = ""
	New()
		..()
		appearance_flags |= NO_CLIENT_COLOR

	set_loc(atom/newloc)
		. = ..()
		if(!isnull(newloc))
			CRASH("HUD object [identify_object(src)] was moved to [identify_object(newloc)]")

/atom/movable/screen/hud
	plane = PLANE_HUD
	var/datum/hud/master
	var/id = ""
	var/tooltipTheme
	var/obj/item/item

	clicked(list/params)
		sendclick(params, usr)

	proc/sendclick(list/params,mob/user = null)
		if (master && (!master.click_check || (user in master.mobs)))
			master.relay_click(src.id, user, params)

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

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseDrop(src, over_object, src_location, over_location, over_control, params)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (master && (!master.click_check || (user in master.mobs)))
			master.MouseDrop_T(src, O, user)

	disposing()
		src.screen_loc = null // idk if this is necessary but im writing it anyways so there
		..()

/datum/hud
	var/list/mob/living/mobs = list()
	var/list/client/clients = list()
	var/list/atom/movable/screen/hud/objects = list()
	var/click_check = 1

	/**
	* assoc list of hud zones with the format:
	*
	* list(
	*
	*	"zone_alias" = list(
	*
	*		"coords" = list( // list of 2 coordinate pairs for the lower left corner and the upper right corner of the hud zone
	*			x_low = num, y_low = num, x_high = num, y_high = num
	*
	*		"elements" = list( // list of all visible hud elements in the hud zone
	*			"elem_alias" = screenobj // screenobj is the hud object that is visible on the players screen
	*
	*		"horizontal_edge" = "" // what horizontal edge of the zone elements are initially added from. should be EAST or WEST.
	*
	*		"vertical_edge" = "" // what vertical edge of the zone elements are intially added from. should be NORTH or SOUTH.
	*
	*		"horizontal_offset" = num // offset for the horizontal placement of elements, used when placing new elements so they dont overlap
	*
	*		"vertical_offset" = num // offset for the horizontal placement of elements, used when placing new elements so they dont overlap
	**/
	var/list/list/list/hud_zones = null

	disposing()
		for (var/mob/M in src.mobs)
			M.detach_hud(src)
		for (var/atom/movable/screen/hud/S in src.objects)
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

	proc/create_screen(id, name, icon, state, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null, mouse_opacity = 1)
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
		src.objects -= S
		for (var/client/C in src.clients)
			C.screen -= S

	proc/remove_screen_id(var/id)
		var/atom/movable/screen/S = get_by_id(id)
		if(S)
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
	proc/MouseDrop_T(var/atom/movable/screen/hud/H, atom/movable/O as obj, mob/user as mob)

/*
	dynamic hud stuff
	if you want to use this i strongly recommend looking at existing examples of how it's used
	i also strongly recommend copying the hud_layout_template.png file
	it is 21x15 (like widescreen mode) and you can colour in cells to show different hud zones
	this makes it easier to see where things are in relation to eachother, since codewise its all coordinate pairs
	and coordinate pairs are harder to intuit
*/

/**
* defines a hud zone within the bounds of the screen at the supplied coordinates
*
* coords: assoc list with format list(x_low = num, y_low = num, x_high = num, y_high = num)
* 	x_low and y_low are the x and y coordinates of the bottom left corner of the zone
* 	x_high and y_high are the x and y coordinates of the top right corner of the zone
*
* alias: string, key for the hud zone, used like this: src.hud_zones["[alias]"]
*
* horizontal_edge: what horizontal side of the hud zone are new elements added from? can be EAST or WEST
*	for example, if its EAST then the first element is added at the right edge of the zone
*	the second element is added to the left side of the first element
* 	the third element is added to the left side of the second element, etc.
*
* vertical_edge: what vertical side of the hud zone are new elements added from? can be NORTH or SOUTH
*	for example, if its NORTH then the first element is added at the top edge of the zone
*	the second element is added to the bottom side of the first element
* 	the third element is added to the bottom side of the second element, etc.
**/

/datum/hud/proc/add_hud_zone(var/list/coords, var/alias, var/horizontal_edge = "WEST", var/vertical_edge = "SOUTH", var/ignore_overlap = 0)
	if (!coords || !alias || !src.hud_zones || !horizontal_edge || !vertical_edge)
		return

	if (!src.screen_boundary_check(coords) || !src.zone_overlap_check(coords, ignore_overlap))
		return

	src.hud_zones[alias] = list("coords" = coords, "elements" = list(), "horizontal_edge" = "[horizontal_edge]",\
	"vertical_edge" = "[vertical_edge]", "horizontal_offset" = 0, "vertical_offset" = 0)

/// removes a hud zone and deletes all elements inside of it
/datum/hud/proc/remove_hud_zone(var/alias)
	var/list/hud_zone = src.hud_zones[alias]

	// remove elements
	var/list/elements = hud_zone["elements"]
	for (var/element_alias in elements)
		var/atom/movable/screen/hud/to_delete = elements[element_alias]
		elements.Remove(to_delete)
		qdel(to_delete)

	src.hud_zones.Remove(hud_zone)

/// adds a hud element (which will be associated with elem_alias) to the elements list of the hud zone associated with zone_alias.
/datum/hud/proc/register_element(var/zone_alias, var/atom/movable/screen/hud/element, var/elem_alias)
	if (!zone_alias || !src.hud_zones.Find(zone_alias) || !elem_alias || !element)
		return

	var/hud_zone = src.hud_zones[zone_alias]
	if ((length(hud_zone["elements"]) >= HUD_ZONE_AREA(hud_zone["coords"]))) // if the amount of hud elements in the zone is greater than its max
		CRASH("Couldn't add element [elem_alias] to zone [zone_alias] because [zone_alias] was full.")

	hud_zone["elements"][elem_alias] = element // adds element to internal list

	src.adjust_offset(hud_zone, element) // sets it correctly (and automatically) on screen

/// removes hud element "element_alias" from the hud zone "zone_alias" and deletes it, then readjusts offsets
/datum/hud/proc/unregister_element(var/zone_alias, var/elem_alias)
	if (!zone_alias || !elem_alias)
		return

	// remove target element
	var/list/hud_zone = src.hud_zones[zone_alias]
	var/list/elements = hud_zone["elements"]
	var/atom/movable/screen/hud/to_remove = elements[elem_alias]
	elements.Remove(elem_alias)
	qdel(to_remove)

	// reset offsets
	hud_zone["horizontal_offset"] = 0
	hud_zone["vertical_offset"] = 0

	// recalculate all positions
	for (var/adjust_index in 1 to length(elements))
		var/adjust_alias = elements[adjust_index]
		var/atom/movable/screen/hud/to_adjust = elements[adjust_alias]
		src.adjust_offset(hud_zone, to_adjust)

/// adds an element without adjusting positions automatically - manually set instead. no safety checking
/datum/hud/proc/add_elem_no_adjust(var/zone_alias, var/elem_alias, var/atom/movable/screen/hud/element, var/pos_x, var/pos_y)
	if (!zone_alias || !src.hud_zones[zone_alias] || !elem_alias || !element)
		return

	src.hud_zones[zone_alias]["elements"][elem_alias] = element //registered element
	src.set_elem_position(element, src.hud_zones[zone_alias]["coords"], pos_x, pos_y) //set pos

/// removes an element without adjusting positions automatically - will probably fuck stuff up if theres any dynamically positioned elements
/datum/hud/proc/del_elem_no_adjust(var/zone_alias, var/elem_alias)
	if (!zone_alias || !elem_alias)
		return

	var/atom/movable/screen/hud/to_remove = src.hud_zones[zone_alias]["elements"][elem_alias] // grab elem ref
	src.hud_zones[zone_alias]["elements"] -= to_remove // unregister element
	qdel(to_remove) // delete

/// used to manually set the position of an element relative to the BOTTOM LEFT corner of a hud zone. no safety checks
/datum/hud/proc/set_elem_position(var/atom/movable/screen/hud/element, var/list/zone_coords, var/pos_x, var/pos_y)
	if (!element || !zone_coords)
		return

	var/x_low = zone_coords["x_low"]
	var/x_loc = "WEST"
	var/adjusted_pos_x = ((x_low + pos_x) - 1)

	// we have to manually add a + sign
	if (adjusted_pos_x < 0)
		x_loc += "[adjusted_pos_x]"
	else
		x_loc += "+[adjusted_pos_x]"

	var/y_low = zone_coords["y_low"]
	var/y_loc = "SOUTH"
	var/adjusted_pos_y = ((y_low + pos_y) - 1)

	// manually add +
	if (adjusted_pos_y < 0)
		y_loc += "[adjusted_pos_y]"
	else
		y_loc += "+[adjusted_pos_y]"

	var/new_loc = "[x_loc], [y_loc]"
	element.screen_loc = new_loc

/// internal use only. accepts a zone and an element, and then tries to position that element in the zone based on current element positions.
/datum/hud/proc/adjust_offset(var/list/hud_zone, var/atom/movable/screen/hud/element)
	PRIVATE_PROC(TRUE)
	var/dir_horizontal = hud_zone["horizontal_edge"] // what direction elements are added from horizontally (east or west)
	var/dir_vertical = hud_zone["vertical_edge"] // what direction elements are added from when wrapping around horizontally (north or south)
	var/curr_horizontal = hud_zone["horizontal_offset"] // current horizontal offset inside of the hud zone, not relative to edges
	var/curr_vertical = hud_zone["vertical_offset"] // current vertical offset inside of the hud zone, not relative to edges
	var/absolute_pos_horizontal = 0 // absolute horizontal position (whole screen) where new elements are added, used with hud offsets
	var/absolute_pos_vertical = 0 // absolute vertical position (whole screen) where new elements are added, used with hud offsets

	// prework

	if (dir_horizontal == "EAST")
		absolute_pos_horizontal = 21 - hud_zone["coords"]["x_high"] // take x loc of right corner (east edge), adjust to be on west edge
	else // west
		absolute_pos_horizontal = 1 - hud_zone["coords"]["x_low"] // take x loc of left corner (west edge)

	if (dir_vertical == "NORTH")
		absolute_pos_vertical = 15 - hud_zone["coords"]["y_high"] // take y loc of top corner (north edge), adjust to be on south edge
	else // south
		absolute_pos_vertical = 1 - hud_zone["coords"]["y_low"] // take y loc of bottom corner (south edge)

	// wraparound handling

	if ((curr_horizontal + 1) > HUD_ZONE_LENGTH(hud_zone["coords"])) // if adding 1 more element exceeds the length of the zone, try to wraparound
		if ((curr_vertical + 1) > HUD_ZONE_HEIGHT(hud_zone["coords"])) // if adding 1 more element exceeds the height of the zone, its full up
			CRASH("Tried to add an element to a full hud zone")
		else // we can wrap around
			curr_horizontal = 0
			curr_vertical++

	// screenloc figuring outing

	var/screen_loc_horizontal = "[dir_horizontal]"
	var/horizontal_offset_adjusted = (absolute_pos_horizontal + curr_horizontal)
	if (dir_horizontal == "EAST") // elements added with an east bound move left, elements with a west bound move right
		screen_loc_horizontal += "-[horizontal_offset_adjusted]"
	else
		screen_loc_horizontal += "+[horizontal_offset_adjusted]"

	var/screen_loc_vertical = "[dir_vertical]"
	var/vertical_offset_adjusted = (absolute_pos_vertical + curr_vertical)
	if (dir_vertical == "NORTH") // elements added with an east bound move left, elements with a west bound move right
		screen_loc_vertical += "-[vertical_offset_adjusted]"
	else
		screen_loc_vertical += "+[vertical_offset_adjusted]"

	// set new screen loc

	var/screen_loc = "[screen_loc_horizontal], [screen_loc_vertical]"
	element.screen_loc = screen_loc

	// increment and update offsets
	curr_horizontal++
	hud_zone["horizontal_offset"] = curr_horizontal
	hud_zone["vertical_offset"] = curr_vertical

/// returns true if a rectangle defined by coords is within screen dimensions, false if it isnt
/datum/hud/proc/screen_boundary_check(var/list/coords)
	if (!coords)
		return FALSE

	// we only support widescreen right now
	if (coords["x_low"] < 1 || coords["x_low"] > 21)
		return FALSE
	if (coords["y_low"] < 1 || coords["y_low"] > 15)
		return FALSE
	if (coords["x_high"] < 1 || coords["x_high"] > 21)
		return FALSE
	if (coords["y_high"] < 1 || coords["y_high"] > 15)
		return FALSE

	return TRUE

/// returns true if a rectangle defined by coords doesnt overlap with any existing hud zone, false if it does
/datum/hud/proc/zone_overlap_check(var/list/coords, var/ignore_overlap = 0)
	if (ignore_overlap)
		return TRUE

	if (!coords)
		return FALSE

	var/x_low_1 = coords["x_low"]
	var/y_low_1 = coords["y_low"]
	var/x_high_1 = coords["x_high"]
	var/y_high_1 = coords["y_high"]

	for (var/list/zone_alias in src.hud_zones)
		var/list/other_coords = src.hud_zones[zone_alias][coords]
		var/x_low_2 = other_coords["x_low"]
		var/y_low_2 = other_coords["y_low"]
		var/x_high_2 = other_coords["x_high"]
		var/y_high_2 = other_coords["y_high"]

		// sov googled this algorithm for me :3

		// is one rectangle to the right of the other?
		if (x_low_1 >= x_high_2 || x_low_2 >= x_high_1)
			continue

		// is one above the other??
		if (y_low_1 >= y_high_2 || y_low_2 >= y_high_1)
			continue

		// they overlap
		return FALSE

	// no overlaps ever :]
	return TRUE

/// returns /atom/movable/screen/hud with in zone_alias with alias elem_alias
/datum/hud/proc/get_element(var/zone_alias, var/elem_alias)
	if (!zone_alias || !elem_alias)
		return null

	var/list/elements = src.hud_zones[zone_alias]["elements"]
	var/atom/movable/screen/hud/element = elements[elem_alias]
	return element

/// debug purposes only, call this to print ALL of the information you could ever need
/datum/hud/proc/debug_print_all()
	if (!length(src.hud_zones))
		boutput(world, "no hud zones, aborting")
		return

	boutput(world, "-------------------------------------------")

	for (var/zone_index in 1 to length(src.hud_zones))
		var/zone_alias = src.hud_zones[zone_index]
		var/list/hud_zone = src.hud_zones["[zone_alias]"]
		boutput(world, "ZONE [zone_index] alias: [zone_alias]")

		var/list/coords = hud_zone["coords"]
		boutput(world, "ZONE [zone_index] bottom left corner coordinates: ([coords["x_low"]], [coords["y_low"]])")
		boutput(world, "ZONE [zone_index] top right corner coordinates: ([coords["x_high"]], [coords["y_high"]])")

		boutput(world, "ZONE [zone_index] horizontal edge: [hud_zone["horizontal_edge"]]")
		boutput(world, "ZONE [zone_index] vertical edge: [hud_zone["vertical_edge"]]")

		boutput(world, "ZONE [zone_index] current horizontal offset: [hud_zone["horizontal_offset"]]")
		boutput(world, "ZONE [zone_index] current vertical offset: [hud_zone["vertical_offset"]]")

		var/list/elements = hud_zone["elements"]

		if (!length(elements))
			boutput(world, "ZONE [zone_index] has no elements")
			continue

		for (var/element_index in 1 to length(elements))
			var/element_alias = elements[element_index]
			var/atom/movable/screen/hud/element = elements[element_alias]
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] alias: [element_alias]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] icon_state: [element.icon_state]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] screenloc: [element.screen_loc]")

	boutput(world, "-------------------------------------------")
