/datum/minimap_render_modifier/space
	priority = -100

/datum/minimap_render_modifier/space/is_compatible(turf/T)
	if (istype(T, /turf/space))
		return TRUE

	return FALSE

/datum/minimap_render_modifier/space/process(list/hsl_colour)
	return list(0, 0, 0)
