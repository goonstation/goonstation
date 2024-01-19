
/**
* ### Defines a hud zone within the bounds of the screen at the supplied coordinates
* Arguments:
*
* coords: assoc list with format `list(x_low = num, y_low = num, x_high = num, y_high = num)`
*
*	x_low and y_low are the x and y coordinates of the bottom left corner of the zone
*	x_high and y_high are the x and y coordinates of the top right corner of the zone
*
* alias: string, key for the hud zone, used like this: `src.hud_zones["[alias]"]`
*
* horizontal_edge: what horizontal side of the hud zone are new elements added from? can be `EAST` or `WEST`
*
*	for example, if its EAST then the first element is added at the right edge of the zone
*	the second element is added to the left side of the first element
*	the third element is added to the left side of the second element, etc.
*
* vertical_edge: what vertical side of the hud zone are new elements added from? can be `NORTH` or `SOUTH`
*
*	for example, if its NORTH then the first element is added at the top edge of the zone
*	the second element is added to the bottom side of the first element
*	the third element is added to the bottom side of the second element, etc.
*
* Returns: `null` if you passed an improper argument, `FALSE` if there was an error placing it, `TRUE` otherwise
**/
/datum/hud/proc/add_hud_zone(list/coords, alias, horizontal_edge = WEST, vertical_edge = SOUTH, ignore_overlap = FALSE)
	if (!coords || !alias || !src.hud_zones || !horizontal_edge || !vertical_edge)
		return null

	if (!src.screen_boundary_check(coords) || !src.zone_overlap_check(coords, ignore_overlap))
		return FALSE

	src.hud_zones[alias] = list(
		"coords" = coords,
		"elements" = list(),
		"horizontal_edge" = dirvalues["[horizontal_edge]"],
		"vertical_edge" = dirvalues["[vertical_edge]"],
		"horizontal_offset" = 0,
		"vertical_offset" = 0
	)
	return TRUE

/// Removes a hud zone and deletes all elements inside of it
/datum/hud/proc/remove_hud_zone(alias)
	var/list/hud_zone = src.hud_zones[alias]

	// remove elements
	var/list/elements = hud_zone["elements"]
	for (var/element_alias in elements)
		var/atom/movable/screen/hud/to_delete = elements[element_alias]
		elements.Remove(to_delete)
		qdel(to_delete)

	src.hud_zones.Remove(hud_zone)
	qdel(hud_zone)

/**
 * ### Adds a hud element (which will be associated with elem_alias) to the elements list of the hud zone associated with zone_alias.
 *
 * Returns `FALSE` if there was an error, `TRUE` otherwise
 */
/datum/hud/proc/register_element(zone_alias, atom/movable/screen/hud/element, elem_alias)
	if (!zone_alias || !src.hud_zones.Find(zone_alias) || !elem_alias || !element)
		return FALSE

	var/hud_zone = src.hud_zones[zone_alias]
	if ((length(hud_zone["elements"]) >= HUD_ZONE_AREA(hud_zone["coords"]))) // if the amount of hud elements in the zone is greater than its max
		CRASH("Couldn't add element [elem_alias] to zone [zone_alias] because [zone_alias] was full.")

	hud_zone["elements"][elem_alias] = element // adds element to internal list
	src.objects += element // adds element to the tracked object list (for adding to clients)

	src.adjust_offset(hud_zone, element) // sets it correctly (and automatically) on screen
	return TRUE

/// removes hud element "element_alias" from the hud zone "zone_alias" and deletes it, then readjusts offsets
/datum/hud/proc/unregister_element(zone_alias, elem_alias)
	if (!zone_alias || !elem_alias)
		return FALSE

	// remove target element
	var/list/hud_zone = src.hud_zones[zone_alias]
	var/list/elements = hud_zone["elements"]
	var/atom/movable/screen/hud/to_remove = elements[elem_alias]
	elements.Remove(elem_alias)
	qdel(to_remove)

	src.recalculate_offsets(hud_zone)
	return TRUE

/// Adds an element without adjusting positions automatically - manually set instead. no safety checking
/datum/hud/proc/add_elem_no_adjust(zone_alias, elem_alias, atom/movable/screen/hud/element, pos_x, pos_y)
	if (!zone_alias || !src.hud_zones[zone_alias] || !elem_alias || !element)
		return FALSE

	src.hud_zones[zone_alias]["elements"][elem_alias] = element //registered element
	src.set_elem_position(element, src.hud_zones[zone_alias]["coords"], pos_x, pos_y) //set pos

/// Removes an element without adjusting positions automatically - will probably fuck stuff up if theres any dynamically positioned elements
/datum/hud/proc/del_elem_no_adjust(zone_alias, elem_alias)
	if (!zone_alias || !elem_alias)
		return FALSE

	var/atom/movable/screen/hud/to_remove = src.hud_zones[zone_alias]["elements"][elem_alias] // grab elem ref
	src.hud_zones[zone_alias]["elements"] -= to_remove // unregister element
	qdel(to_remove) // delete

/// Used to manually set the position of an element relative to the BOTTOM LEFT corner of a hud zone. no safety checks
/datum/hud/proc/set_elem_position(atom/movable/screen/hud/element, list/zone_coords, pos_x, pos_y)
	if (!element || !zone_coords)
		return FALSE

	var/x_low = zone_coords["x_low"]
	var/x_loc = "WEST"
	var/adjusted_pos_x = ((x_low + pos_x))

	// we have to manually add a + sign
	if (adjusted_pos_x < 0)
		x_loc += "[adjusted_pos_x]"
	else
		x_loc += "+[adjusted_pos_x]"

	var/y_low = zone_coords["y_low"]
	var/y_loc = "SOUTH"
	var/adjusted_pos_y = ((y_low + pos_y))

	// manually add +
	if (adjusted_pos_y < 0)
		y_loc += "[adjusted_pos_y]"
	else
		y_loc += "+[adjusted_pos_y]"

	var/new_loc = "[x_loc], [y_loc]"
	element.screen_loc = new_loc

/// Internal use only. Recalculates all offsets for the elements of a given hud zone
/datum/hud/proc/recalculate_offsets(list/hud_zone)
	PRIVATE_PROC(TRUE)
	hud_zone["horizontal_offset"] = 0
	hud_zone["vertical_offset"] = 0

	var/list/elements = hud_zone["elements"]

	for (var/adjust_index in 1 to length(elements))
		var/adjust_alias = elements[adjust_index]
		var/atom/movable/screen/hud/to_adjust = elements[adjust_alias]
		src.adjust_offset(hud_zone, to_adjust)

/// internal use only. accepts a zone and an element, and then tries to position that element in the zone based on current element positions.
/datum/hud/proc/adjust_offset(list/hud_zone, atom/movable/screen/hud/element)
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
		absolute_pos_horizontal = 0 + hud_zone["coords"]["x_low"] // take x loc of left corner (west edge)

	if (dir_vertical == "NORTH")
		absolute_pos_vertical = 15 - hud_zone["coords"]["y_high"] // take y loc of top corner (north edge), adjust to be on south edge
	else // south
		absolute_pos_vertical = 0 + hud_zone["coords"]["y_low"] // take y loc of bottom corner (south edge)

	// wraparound handling

	//TODO: uhh doesn't this break for the other direction, negative
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
	element.screen_loc = "[screen_loc_horizontal], [screen_loc_vertical]"

	// increment and update offsets
	curr_horizontal++
	hud_zone["horizontal_offset"] = curr_horizontal
	hud_zone["vertical_offset"] = curr_vertical

/// Returns `TRUE` if a rectangle defined by coords is within screen dimensions, `FALSE` if it isnt
/datum/hud/proc/screen_boundary_check(list/coords)
	if (!coords)
		return FALSE

	// we only support widescreen right now
	if (coords["x_low"] < 0 || coords["x_low"] > WIDE_TILE_WIDTH)
		return FALSE
	if (coords["y_low"] < 0 || coords["y_low"] > TILE_HEIGHT)
		return FALSE
	if (coords["x_high"] < 0 || coords["x_high"] > WIDE_TILE_WIDTH)
		return FALSE
	if (coords["y_high"] < 0 || coords["y_high"] > TILE_HEIGHT)
		return FALSE

	return TRUE

/// Returns `TRUE` if a rectangle defined by coords doesnt overlap with any existing hud zone, `FALSE` if it does
/datum/hud/proc/zone_overlap_check(list/coords, ignore_overlap = FALSE)
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

/// Returns the `/atom/movable/screen/hud` with in `zone_alias` with alias `elem_alias`
/datum/hud/proc/get_element(zone_alias, elem_alias)
	if (!zone_alias || !elem_alias)
		return null

	var/list/elements = src.hud_zones[zone_alias]["elements"]
	var/atom/movable/screen/hud/element = elements[elem_alias]
	return element

/// Debug use, edit the coords of a hud zone directly
/datum/hud/proc/edit_coords(zone_alias, x, y, a, b)
	PRIVATE_PROC(TRUE)
	var/list/hud_zone = hud_zones[zone_alias]

	hud_zone["coords"]["x_low"] = x
	hud_zone["coords"]["y_low"] = y
	hud_zone["coords"]["x_high"] = a
	hud_zone["coords"]["y_high"] = b
	src.recalculate_offsets(hud_zone)

/// debug purposes only, call this to print ALL of the information you could ever need
/datum/hud/proc/debug_print_all()
	if (!length(src.hud_zones))
		boutput(world, SPAN_ADMIN("no hud zones, aborting"))
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
