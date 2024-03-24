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

/datum/hud_element/New(screen_obj, width = 1, height = 1)
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
 * Pass `ignore_area = TRUE` if you want to ignore bounds checks.
 *
 * Returns: `null` if passed bad arguments, `FALSE` if there was an error, `TRUE` otherwise
 */
/datum/hud_zone/proc/add_element(datum/hud_element/element, elem_alias, ignore_area = FALSE)
	PRIVATE_PROC(TRUE)
	if (!element || !elem_alias)
		return null

	if (!ignore_area)
		if (element.height != 1)
			logTheThing(LOG_DEBUG, src, "<B>ZeWaka/Hudzones:</B> Couldn't add element [elem_alias] to zone [src] because height was not 1 (height: [element.height]).")
			return FALSE
		var/forces_wraparound = (src.horizontal_offset + element.width) > (HUD_ZONE_LENGTH(src.coords))
		if (forces_wraparound && ((src.vertical_offset + element.height) >= HUD_ZONE_HEIGHT(src.coords))) // ZEWAKA TODO: why >=
			logTheThing(LOG_DEBUG, src, "<B>ZeWaka/Hudzones:</B> Couldn't add element [elem_alias] to zone [src] it would force a wraparound while vertically full.")
			return FALSE

	src.elements[elem_alias] = element // adds element to internal list
	src.master.objects += element.screen_obj // adds element to the tracked object list (for adding to clients)
	return TRUE

/**
 * Removes the element with alias `elem_alias`
 *
 * Returns: `null` if passed bad arguments, `TRUE` otherwise
 */
/datum/hud_zone/proc/remove_element(elem_alias)
	PRIVATE_PROC(TRUE)
	if (!elem_alias)
		return null

	var/datum/hud_element/to_remove = src.elements[elem_alias]

	src.elements.Remove(elem_alias)
	src.master.objects.Remove(to_remove.screen_obj)
	qdel(to_remove)
	return TRUE
