/datum/minimap_render_modifier/walls
	priority = 2

/datum/minimap_render_modifier/walls/is_compatible(turf/T)
	if (istype(T, /turf/simulated/wall))
		return TRUE
	if (istype(T, /turf/unsimulated/wall))
		return TRUE
	if (locate(/obj/mapping_helper/wingrille_spawn) in T)
		return TRUE
	if (locate(/obj/window) in T)
		return TRUE

	return FALSE

/datum/minimap_render_modifier/walls/process(list/hsl_colour)
	hsl_colour[3] *= 0.7
	return hsl_colour


/turf/New()
	. = ..()

	global.minimap_renderer?.update_radar_map(src)


/obj/window/New()
	. = ..()

	global.minimap_renderer?.update_radar_map(get_turf(src))

/obj/window/disposing()
	var/turf/T = get_turf(src)
	. = ..()

	global.minimap_renderer?.update_radar_map(T)
