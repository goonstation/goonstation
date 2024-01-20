/*
 * File is mainly for `/datum/hud_element`-related functions
 */

/// Represents a hud element within a hud zone
/datum/hud_element
	/// How many tiles wide the element is (can be fractional)
	var/width = 1
	/// How many tiles tall the element is (can be fractional)
	var/height = 1
	/// The actual screen object
	var/atom/movable/screen/hud/screen_obj = null

/datum/hud_element/New(screen_obj, width, height)
	. = ..()
	src.screen_obj = screen_obj
	src.width = width
	src.height = height

/datum/hud_element/disposing()
	. = ..()
	qdel(src.screen_obj)
	src.screen_obj = null

/**
 * Adds the `element` to `zone_alias` with alias `elem_alias`
 *
 * Pass `ignore_area` if you want to ignore bounds checks._is_abstract
 *
 * Returns: `null` if passed bad arguments, `FALSE` if there was an error, `TRUE` otherwise
 */
/datum/hud/proc/add_element(datum/hud_element/element, zone_alias, elem_alias, ignore_area = FALSE)
	PRIVATE_PROC(TRUE)
	if (!element || !zone_alias || !elem_alias)
		return null

	var/datum/hud_zone/zone = src.hud_zones[zone_alias]
	if (!ignore_area)
		if ((length(zone.elements) >= HUD_ZONE_AREA(zone.coords))) // if the amount of hud elements in the zone is greater than its max
			logTheThing(LOG_DEBUG, src, "<B>ZeWaka/Hudzones:</B> Couldn't add element [elem_alias] to zone [zone_alias] because [zone_alias] was full.")
			return FALSE

	zone.elements[elem_alias] = element // adds element to internal list
	src.objects += element.screen_obj // adds element to the tracked object list (for adding to clients)
	return TRUE

/**
 * Removes the element in `zone_alias` with alias `elem_alias`
 *
 * Returns: `null` if passed bad arguments, `TRUE` otherwise
 */
/datum/hud/proc/remove_element(zone_alias, elem_alias)
	PRIVATE_PROC(TRUE)
	if (!zone_alias || !elem_alias)
		return null

	var/datum/hud_zone/zone = src.hud_zones[zone_alias]
	var/datum/hud_element/to_remove = zone.elements[elem_alias]

	zone.elements.Remove(elem_alias)
	src.objects.Remove(to_remove.screen_obj)
	qdel(to_remove)
	return TRUE
