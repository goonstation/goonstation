
/**
* ### Defines a hud zone within the bounds of the screen at the supplied coordinates
* Arguments:
*
* coords: assoc list with format `list(x_low = num, y_low = num, x_high = num, y_high = num)`
*
*	x_low and y_low are the x and y coordinates of the bottom left corner of the zone
*	x_high and y_high are the x and y coordinates of the top right corner of the zone
*
* alias: string, key for the hud zone
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
* ignore_overlap: Whether to ignore if this hud zone overlaps with other hud zones
*
* Returns: `null` if passed bad arguments, `FALSE` if there was an error placing it, `TRUE` otherwise
**/
/datum/hud/proc/add_hud_zone(list/coords, alias, horizontal_edge = WEST, vertical_edge = SOUTH, ignore_overlap = FALSE)
	if (!coords || !alias || !src.hud_zones || !horizontal_edge || !vertical_edge)
		return null

	if (!src.screen_boundary_check(coords) || !src.zone_overlap_check(coords, ignore_overlap))
		return FALSE

	src.hud_zones[alias] = new/datum/hud_zone(coords, alias, dirvalues["[horizontal_edge]"], dirvalues["[vertical_edge]"], ignore_overlap)
	return TRUE

/// Removes a hud zone and deletes all elements inside of it
/datum/hud/proc/remove_hud_zone(alias)
	var/datum/hud_zone/hud_zone = src.hud_zones[alias]

	// remove elements
	var/list/elements = hud_zone.elements
	for (var/element_alias in elements)
		var/atom/movable/screen/hud/to_delete = elements[element_alias]
		elements.Remove(to_delete)
		qdel(to_delete)

	src.hud_zones.Remove(hud_zone)
	qdel(hud_zone)

/**
 * ### Adds a hud element (which will be associated with elem_alias) to the elements list of the hud zone associated with zone_alias.
 *
 * Returns `null` if passed bad arguments, `FALSE` if there was an error, `TRUE` otherwise
 */
/datum/hud/proc/register_element(zone_alias, atom/movable/screen/hud/element, elem_alias)
	if (!zone_alias || !(src.hud_zones.Find(zone_alias)) || !elem_alias || !element)
		return null

	var/datum/hud_zone/hud_zone = src.hud_zones[zone_alias]
	if ((length(hud_zone.elements) >= HUD_ZONE_AREA(hud_zone.coords))) // if the amount of hud elements in the zone is greater than its max
		logTheThing(LOG_DEBUG, src, "<B>ZeWaka/Hudzones:</B> Couldn't add element [elem_alias] to zone [zone_alias] because [zone_alias] was full.")
		return FALSE

	hud_zone.elements[elem_alias] = element // adds element to internal list
	src.objects += element // adds element to the tracked object list (for adding to clients)

	src.adjust_offset(hud_zone, element) // sets it correctly (and automatically) on screen
	return TRUE

/**
 * Removes hud element "element_alias" from the hud zone "zone_alias" and deletes it
 *
 * Returns `null` if passed improper args, `TRUE` otherwise
 */
/datum/hud/proc/deregister_element(zone_alias, elem_alias)
	if (!zone_alias || !elem_alias)
		return null

	// remove target element
	var/datum/hud_zone/hud_zone = src.hud_zones[zone_alias]
	var/list/elements = hud_zone["elements"]
	var/atom/movable/screen/hud/to_remove = elements[elem_alias]

	elements.Remove(elem_alias)
	src.objects.Remove(to_remove)
	qdel(to_remove)

	src.recalculate_offsets(hud_zone)
	return TRUE
