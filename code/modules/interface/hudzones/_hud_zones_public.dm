
// -- Hud Zones --
//
// See: The README in this folder for more of a guide on how to use these functions.
//

/// Returns the `/datum/hud_zone` with `zone_alias`, null if passed bad arguments
/datum/hud/proc/get_hudzone(zone_alias)
	RETURN_TYPE(/datum/hud_zone)
	if (!zone_alias)
		return null
	return src.hud_zones[zone_alias]

/**
* ### Creates a hud zone within the bounds of the screen at the supplied coordinates
* Arguments:
*
* coords: assoc list with format `list(x_low = num, y_low = num, x_high = num, y_high = num)`
*
*	x_low and y_low are the x and y coordinates of the bottom left corner of the zone
*	x_high and y_high are the x and y coordinates of the top right corner of the zone
*
* alias: string, key for the hud zone
*
* horizontal_edge: what horizontal side of the hud zone are new elements added from? can be `EAST` or `WEST`- Defaults to `WEST`
*
*	for example, if its EAST then the first element is added at the right edge of the zone
*	the second element is added to the left side of the first element
*	the third element is added to the left side of the second element, etc.
*
* vertical_edge: what vertical side of the hud zone are new elements added from? can be `NORTH` or `SOUTH` - Defaults to `SOUTH`
*
*	for example, if its NORTH then the first element is added at the top edge of the zone
*	the second element is added to the bottom side of the first element
*	the third element is added to the bottom side of the second element, etc.
*
* ignore_overlap: Whether to ignore if this hud zone overlaps with other hud zones - Defaults to `FALSE`
*
* Returns: `null` if passed bad arguments, `FALSE` if there was an error placing it, the new /datum/hud_zone otherwise
**/
/datum/hud/proc/create_hud_zone(list/coords, alias, horizontal_edge = WEST, vertical_edge = SOUTH, ignore_overlap = FALSE)
	if (!coords || !alias || isnull(horizontal_edge) || isnull(vertical_edge) || isnull(ignore_overlap))
		return null

	if (!src.hud_zones || !src.screen_boundary_check(coords) || !src.zone_overlap_check(coords, ignore_overlap))
		return FALSE

	var/datum/hud_zone/zone = new/datum/hud_zone(src, coords, alias, dirvalues["[horizontal_edge]"], dirvalues["[vertical_edge]"], ignore_overlap)
	src.hud_zones[alias] = zone
	return zone

/// Deletes a hud zone and all elements inside of it
/datum/hud/proc/delete_hud_zone(alias)
	var/datum/hud_zone/hud_zone = src.get_hudzone(alias)

	// remove elements
	var/list/elements = hud_zone.elements
	for (var/element_alias in elements)
		var/datum/hud_element/to_delete = elements[element_alias] // ZEWAKA TODO: does this work with assoc lists
		elements.Remove(to_delete)
		qdel(to_delete)

	src.hud_zones.Remove(hud_zone)
	qdel(hud_zone)


// -- Elements --

/// Returns the `/datum/hud_element` with alias `elem_alias`, `null` if passed improper args
/datum/hud_zone/proc/get_element(elem_alias)
	RETURN_TYPE(/datum/hud_element)
	if (!elem_alias)
		return null
	return src.elements[elem_alias]

/**
 * ### Registers a hud element, associated with elem_alias
 *
 * Returns `null` if passed improper args, `FALSE` if there was an error, `TRUE` otherwise
 */
/datum/hud_zone/proc/register_element(datum/hud_element/element, elem_alias)
	if (!element || !elem_alias)
		return null

	// Check unsupported behaivor
	if (element.height != 1)
		logTheThing(LOG_DEBUG, src, "<B>ZeWaka/Hudzones:</B> Couldn't add element [elem_alias] to zone [src] because height was not 1 (height: [element.height]).")
		return FALSE

	if (!src.add_element(element, elem_alias, ignore_area = FALSE))
		return FALSE

	src.adjust_offset(element) // sets it correctly (and automatically) on screen
	return TRUE

/**
 * ### Deregisters a hud element associated with `elem_alias`
 *
 * Returns `null` if passed improper args, `TRUE` otherwise
 */
/datum/hud_zone/proc/deregister_element(elem_alias)
	if (!elem_alias)
		return null

	// Remove and recalculate
	src.remove_element(elem_alias)
	src.recalculate_offsets()
	return TRUE
