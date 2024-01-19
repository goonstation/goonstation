
/// Adds an element without adjusting positions automatically - manually set instead. no safety checking
/datum/hud/proc/add_elem_no_adjust(zone_alias, elem_alias, atom/movable/screen/hud/element, pos_x, pos_y)
	if (!zone_alias || !src.hud_zones[zone_alias] || !elem_alias || !element)
		return FALSE

	src.hud_zones[zone_alias].elements[elem_alias] = element //registered element
	src.set_elem_position(element, src.hud_zones[zone_alias].coords, pos_x, pos_y) //set pos

/// Removes an element without adjusting positions automatically - will probably fuck stuff up if theres any dynamically positioned elements
/datum/hud/proc/del_elem_no_adjust(zone_alias, elem_alias)
	if (!zone_alias || !elem_alias)
		return FALSE

	var/atom/movable/screen/hud/to_remove = src.hud_zones[zone_alias].elements[elem_alias] // grab elem ref
	src.hud_zones[zone_alias].elements -= to_remove // unregister element
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
/datum/hud/proc/recalculate_offsets(datum/hud_zone/hud_zone)
	PRIVATE_PROC(TRUE)
	hud_zone.horizontal_offset = 0
	hud_zone.vertical_offset = 0

	var/list/elements = hud_zone.elements

	for (var/adjust_index in 1 to length(elements))
		var/adjust_alias = elements[adjust_index]
		var/atom/movable/screen/hud/to_adjust = elements[adjust_alias]
		src.adjust_offset(hud_zone, to_adjust)

/// internal use only. accepts a zone and an element, and then tries to position that element in the zone based on current element positions.
/datum/hud/proc/adjust_offset(datum/hud_zone/hud_zone, atom/movable/screen/hud/element)
	PRIVATE_PROC(TRUE)
	// prework
	var/absolute_pos_horizontal = 0 // absolute horizontal position (whole screen) where new elements are added, used with hud offsets
	if (hud_zone.horizontal_edge == "EAST")
		absolute_pos_horizontal = 21 - hud_zone.coords["x_high"] // take x loc of right corner (east edge), adjust to be on west edge
	else // west
		absolute_pos_horizontal = 0 + hud_zone.coords["x_low"] // take x loc of left corner (west edge)

	var/absolute_pos_vertical = 0 // absolute vertical position (whole screen) where new elements are added, used with hud offsets
	if (hud_zone.vertical_edge == "NORTH")
		absolute_pos_vertical = 15 - hud_zone.coords["y_high"] // take y loc of top corner (north edge), adjust to be on south edge
	else // south
		absolute_pos_vertical = 0 + hud_zone.coords["y_low"] // take y loc of bottom corner (south edge)

	// wraparound handling
	if (hud_zone.ensure_empty() == HUD_ZONE_FULL)
		CRASH("Tried to add an element to a full hud zone")

	// screenloc figuring outing
	var/screen_loc_horizontal = hud_zone.horizontal_edge
	var/horizontal_offset_adjusted = (absolute_pos_horizontal + hud_zone.horizontal_offset)
	if (screen_loc_horizontal == "EAST") // elements added with an east bound move left, elements with a west bound move right
		screen_loc_horizontal += "-[horizontal_offset_adjusted]"
	else
		screen_loc_horizontal += "+[horizontal_offset_adjusted]"

	var/screen_loc_vertical = hud_zone.vertical_edge
	var/vertical_offset_adjusted = (absolute_pos_vertical + hud_zone.vertical_offset)
	if (screen_loc_vertical == "NORTH") // elements added with an east bound move left, elements with a west bound move right
		screen_loc_vertical += "-[vertical_offset_adjusted]"
	else
		screen_loc_vertical += "+[vertical_offset_adjusted]"

	element.screen_loc = "[screen_loc_horizontal], [screen_loc_vertical]"
	hud_zone.horizontal_offset++ // We've added a new element

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
		var/list/other_coords = src.hud_zones[zone_alias].coords
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

	var/list/elements = src.hud_zones[zone_alias].elements
	var/atom/movable/screen/hud/element = elements[elem_alias]
	return element

/// Debug use, edit the coords of a hud zone directly
/datum/hud/proc/edit_coords(zone_alias, x, y, a, b)
	PRIVATE_PROC(TRUE)
	var/datum/hud_zone/hud_zone = hud_zones[zone_alias]

	hud_zone.coords["x_low"] = x
	hud_zone.coords["y_low"] = y
	hud_zone.coords["x_high"] = a
	hud_zone.coords["y_high"] = b
	src.recalculate_offsets(hud_zone)

/// debug purposes only, call this to print ALL of the information you could ever need
/datum/hud/proc/debug_print_all()
	if (!length(src.hud_zones))
		boutput(world, SPAN_ADMIN("no hud zones, aborting"))
		return

	boutput(world, "-------------------------------------------")

	for (var/zone_index in 1 to length(src.hud_zones))
		var/zone_alias = src.hud_zones[zone_index]
		var/datum/hud_zone/hud_zone = src.hud_zones["[zone_alias]"]
		boutput(world, "ZONE [zone_index] alias: [zone_alias]")

		var/list/coords = hud_zone.coords
		boutput(world, "ZONE [zone_index] bottom left corner coordinates: ([coords["x_low"]], [coords["y_low"]])")
		boutput(world, "ZONE [zone_index] top right corner coordinates: ([coords["x_high"]], [coords["y_high"]])")

		boutput(world, "ZONE [zone_index] horizontal edge: [hud_zone.horizontal_edge]")
		boutput(world, "ZONE [zone_index] vertical edge: [hud_zone.vertical_edge]")

		boutput(world, "ZONE [zone_index] current horizontal offset: [hud_zone.horizontal_offset]")
		boutput(world, "ZONE [zone_index] current vertical offset: [hud_zone.vertical_offset]")

		var/list/elements = hud_zone.elements

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

/// The internal datum representation of a hud zone
/datum/hud_zone
	/// What this hud_zone is indexed with in the hud_zones list
	var/name = null
	/// Assoc list with format `list(x_low = num, y_low = num, x_high = num, y_high = num)`
	var/list/coords = null
	/// Assoc list of `"elem_alias" = /atom/movable/screen/hud` elements
	var/list/elements = null
	/// What horizontal side of the hud zone are new elements added from? can be `"EAST"` or `"WEST"`
	var/horizontal_edge = 0
	/// What vertical side of the hud zone are new elements added from? can be `"NORTH"` or `"SOUTH"`
	var/vertical_edge = 0
	/// Current relative horizontal offset to place new elements at
	var/horizontal_offset = 0
	/// Current relative vertical offset to place new elements at
	var/vertical_offset = 0

/datum/hud_zone/New(coords, alias, horizontal_edge, vertical_edge)
	. = ..()
	src.coords = coords
	src.name = alias
	src.horizontal_edge = horizontal_edge
	src.vertical_edge = vertical_edge
	src.elements = list()

/datum/hud_zone/disposing()
	. = ..()
	elements = null

// ZEWAKA TODO: uhh doesn't this break for the other direction, negative
/**
 * Returns `HUD_ZONE_FULL` if completely full,
 * `HUD_ZONE_WRAPAROUND` if it needed to wrap around to a new vertical layer,
 * and `HUD_ZONE_EMPTY` if it was empty.
 */
/datum/hud_zone/proc/ensure_empty() as num
	// If adding 1 more element exceeds the length of the zone, try to wraparound
	if ((src.horizontal_offset + 1) > (HUD_ZONE_LENGTH(src.coords) - 1)) // -1 to convert from 1-indexed to 0-indexed
		// If adding 1 more element exceeds the height of the zone, its full up
		if ((src.vertical_offset + 1) > (HUD_ZONE_HEIGHT(src.coords) - 1)) // -1 to convert from 1-indexed to 0-indexed
			return HUD_ZONE_FULL
		else // we can wrap around
			src.horizontal_offset = 0
			src.vertical_offset++
			return HUD_ZONE_WRAPAROUND
	else
		return HUD_ZONE_EMPTY
