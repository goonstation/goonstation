/datum/minimap_render_modifier/doors
	priority = 1

/datum/minimap_render_modifier/doors/is_compatible(turf/T)
	if (locate(/obj/machinery/door) in T)
		return TRUE

	return FALSE

/datum/minimap_render_modifier/doors/process(list/hsl_colour)
	hsl_colour[3] *= 0.85
	return hsl_colour


/obj/machinery/door/New()
	. = ..()

	global.minimap_renderer?.update_radar_map(get_turf(src))

/obj/machinery/door/disposing()
	var/turf/T = get_turf(src)
	. = ..()

	global.minimap_renderer?.update_radar_map(T)
