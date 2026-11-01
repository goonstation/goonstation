ABSTRACT_TYPE(/datum/minimap_render_modifier)
/**
 *	Minimap render modifiers are responsible for handling alterations to the pixel colour that represent a specific turf on
 *	a minimap. Only one modifier may apply its effects to a pixel at a time, with higher priority modifiers being considered
 *	first.
 */
/datum/minimap_render_modifier
	var/priority = 0

/// Whether this modifier can be applied to the pixel representing this turf.
/datum/minimap_render_modifier/proc/is_compatible(turf/T)
	return TRUE

/// Applies the effects of this modifier to the colour.
/datum/minimap_render_modifier/proc/process(list/hsl_colour)
	RETURN_TYPE(/list)
	return hsl_colour
