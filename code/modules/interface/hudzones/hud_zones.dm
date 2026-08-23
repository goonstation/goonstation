/*
 * File is mainly for `/datum/hud_zone`-related functions
 */

/// The internal datum representation of a hud zone
/datum/hud_zone
	/// What's the master /datum/hud this lives in?
	var/datum/hud/master = null
	/// What this hud_zone is indexed with in the hud_zones list
	var/name = null
	/// Assoc list with format `list(x_low = num, y_low = num, x_high = num, y_high = num)`, 1-indexed
	var/list/coords = null
	/// Assoc list of `"elem_alias" = /datum/hud_element` elements
	var/list/elements = null
	/// What horizontal side of the hud zone are new elements added from? can be `"EAST"` or `"WEST"`
	var/horizontal_edge = 0
	/// What vertical side of the hud zone are new elements added from? can be `"NORTH"` or `"SOUTH"`
	var/vertical_edge = 0
	/// Current relative horizontal offset to place new elements at
	var/horizontal_offset = 0
	/// Current relative vertical offset to place new elements at
	var/vertical_offset = 0
	/// Did this hud zone ignore overlapping zones on creation?
	var/ignore_overlap = FALSE

/datum/hud_zone/New(master, coords, alias, horizontal_edge, vertical_edge, ignore_overlap)
	. = ..()
	src.master = master
	src.coords = coords
	src.name = alias
	src.horizontal_edge = horizontal_edge
	src.vertical_edge = vertical_edge
	src.ignore_overlap = ignore_overlap
	src.elements = list()

/datum/hud_zone/disposing()
	. = ..()
	master = null
	elements = null

/// Internal use only. Recalculates all offsets for the elements/
/datum/hud_zone/proc/recalculate_offsets()
	PRIVATE_PROC(TRUE)
	src.horizontal_offset = 0
	src.vertical_offset = 0

	var/list/elements = src.elements

	for (var/adjust_index in 1 to length(elements))
		var/adjust_alias = elements[adjust_index]
		var/datum/hud_element/to_adjust = elements[adjust_alias]
		src.adjust_offset(to_adjust)

/// internal use only. accepts an element and tries to position that element in the zone based on current element positions.
/datum/hud_zone/proc/adjust_offset(datum/hud_element/element)
	PRIVATE_PROC(TRUE)

/*
	HUD Zones are positioned on a client's screen using `screen_loc`, see: https://secure.byond.com/docs/ref/#/atom/movable/var/screen_loc
	For HUD Zones, `screen_loc` takes the form `"V_DIR±V_OFFSET, H_DIR±H_OFFSET"`. This form is relative and 0-indexed,
	whereas the HUD Zone grid is absolute and 1-indexed, so a conversion between the two must be made.
*/

	// Relative horizontal position to the horizontal edge.
	var/relative_pos_horizontal = null
	// If the horizontal edge is the east edge, the relative position is taken as number of tiles from that edge.
	if (src.horizontal_edge == "EAST")
		relative_pos_horizontal = WIDE_TILE_WIDTH - src.coords["x_high"] + (element.width - 1)
	// If the horizontal edge is the west edge, the relative position is equal to the absolute position minus one, as absolute position is measured from the south western corner.
	else
		relative_pos_horizontal = src.coords["x_low"] - 1

	// Relative vertical position to the vertical edge.
	var/relative_pos_vertical = null
	// If the vertical edge is the north edge, the relative position is taken as number of tiles from that edge.
	if (src.vertical_edge == "NORTH")
		relative_pos_vertical = TILE_HEIGHT - src.coords["y_high"]
	// If the vertical edge is the south edge, the relative position is equal to the absolute position minus one, as absolute position is measured from the south western corner.
	else
		relative_pos_vertical = src.coords["y_low"] - 1

	// Wraparound handling.
	switch (src.ensure_empty(element))
		if (HUD_ZONE_WRAPAROUND)
			src.horizontal_offset = 0
			src.vertical_offset += 1
		if (HUD_ZONE_FULL)
			CRASH("Tried to add an element to a full hud zone.")

	// Elements added with an east edge move left, elements with a west edge move right.
	var/screen_loc_horizontal = src.horizontal_edge
	var/horizontal_offset_adjusted = (relative_pos_horizontal + src.horizontal_offset)
	if (screen_loc_horizontal == "EAST")
		screen_loc_horizontal += SIGNED_NUM_STRING(-horizontal_offset_adjusted)
	else
		screen_loc_horizontal += SIGNED_NUM_STRING(horizontal_offset_adjusted)

	// Elements added with a north edge move down, elements with a south edge move up.
	var/screen_loc_vertical = src.vertical_edge
	var/vertical_offset_adjusted = (relative_pos_vertical + src.vertical_offset)
	if (screen_loc_vertical == "NORTH")
		screen_loc_vertical += SIGNED_NUM_STRING(-vertical_offset_adjusted)
	else
		screen_loc_vertical += SIGNED_NUM_STRING(vertical_offset_adjusted)

	element.screen_obj.screen_loc = "[screen_loc_horizontal], [screen_loc_vertical]"
	src.horizontal_offset += element.width

/// Whether this HUD is allowed to exist beyond the screen boundaries.
/datum/hud/var/exceeds_boundaries = FALSE

/// Returns `TRUE` if a rectangle defined by coords is within screen dimensions, `FALSE` if it isnt
/datum/hud/proc/screen_boundary_check(list/coords)
	PRIVATE_PROC(TRUE)
	if (!coords)
		return null

	if (src.exceeds_boundaries)
		return TRUE

	// We only support widescreen right now
	// Zero because screen-loc coords are zero-indexed
	if (coords["x_low"] < 1 || coords["x_low"] > WIDE_TILE_WIDTH)
		return FALSE
	if (coords["y_low"] < 1 || coords["y_low"] > TILE_HEIGHT)
		return FALSE
	if (coords["x_high"] < 1 || coords["x_high"] > WIDE_TILE_WIDTH)
		return FALSE
	if (coords["y_high"] < 1 || coords["y_high"] > TILE_HEIGHT)
		return FALSE

	return TRUE

/// Returns `TRUE` if a rectangle defined by coords doesnt overlap with any existing hud zone, `FALSE` if it does
/datum/hud/proc/zone_overlap_check(list/coords, ignore_overlap = FALSE)
	PRIVATE_PROC(TRUE)
	if (ignore_overlap)
		return TRUE

	if (!coords)
		return null

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
			var/datum/hud_element/element = elements[element_alias]
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] alias: [element_alias]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] width: [element.width]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] height: [element.height]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] icon_state: [element.screen_obj.icon_state]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] screenloc: [element.screen_obj.screen_loc]")

	boutput(world, "-------------------------------------------")

// ZEWAKA TODO: uhh doesn't this break for the other direction, negative
// TODO: only works for 1-height elements
/**
 * Argument: The `datum/hud_element` we're adding
 *
 * Returns `HUD_ZONE_FULL` if completely full,
 * `HUD_ZONE_WRAPAROUND` if it needed to wrap around to a new vertical layer,
 * and `HUD_ZONE_EMPTY` if it was empty.
 */
/datum/hud_zone/proc/ensure_empty(datum/hud_element/new_elem)
	PRIVATE_PROC(TRUE)
	// If adding the element exceeds the length of the zone, try to wraparound.
	if ((src.horizontal_offset + new_elem.width) > (HUD_ZONE_LENGTH(src.coords)))
		// If adding one more element exceeds the height of the zone, it's full.
		/* Why `+ 2`?
			When the algorithm finishes adding a column, the horizontal offset is incremented accordingly. This is not the case
			with rows, as there is no way of knowing if the next element will fill up the current row due to variable width
			elements, so vertical offset is not incremented after an element is added. This is why the height of both the
			current row and the new row must be added to the vertical offset, hence `+ 2`.
		*/
		if ((src.vertical_offset + 2) > (HUD_ZONE_HEIGHT(src.coords)))
			return HUD_ZONE_FULL
		// Otherwise the zone can wrap around.
		else
			return HUD_ZONE_WRAPAROUND
	else
		return HUD_ZONE_EMPTY

/// Adds an element without adjusting positions automatically - manually set instead. no safety checking
/datum/hud_zone/proc/add_elem_no_adjust(elem_alias, datum/hud_element/element, pos_x, pos_y)
	if (!elem_alias || !element)
		return FALSE

	src.elements[elem_alias] = element //registered element
	src.set_elem_position(element, src.coords, pos_x, pos_y) //set pos

/// Removes an element without adjusting positions automatically - will probably fuck stuff up if theres any dynamically positioned elements
/datum/hud_zone/proc/deregister_element_no_adjust(elem_alias)
	if (!elem_alias)
		return FALSE

	src.remove_element( elem_alias)

/// Used to manually set the position of an element relative to the BOTTOM LEFT corner of a hud zone. no safety checks
/datum/hud_zone/proc/set_elem_position(datum/hud_element/element, list/zone_coords, pos_x, pos_y)
	if (!element || !zone_coords)
		return FALSE

	var/x_low = zone_coords["x_low"]
	var/x_loc = "WEST"
	var/adjusted_pos_x = ((x_low + pos_x) - 1) // Convert from 1-indexed to 0-indexed

	// we have to manually add a + sign
	if (adjusted_pos_x < 0)
		x_loc += "[adjusted_pos_x]"
	else
		x_loc += "+[adjusted_pos_x]"

	var/y_low = zone_coords["y_low"]
	var/y_loc = "SOUTH"
	var/adjusted_pos_y = ((y_low + pos_y) - 1) // Convert from 1-indexed to 0-indexed

	// manually add +
	if (adjusted_pos_y < 0)
		y_loc += "[adjusted_pos_y]"
	else
		y_loc += "+[adjusted_pos_y]"

	var/new_loc = "[x_loc], [y_loc]"
	element.screen_obj.screen_loc = new_loc
