/datum/minimap_renderer
	var/list/icon/minimap_type_renders
	var/list/list/atom/movable/dynamic_area_overlays

/datum/minimap_renderer/New()
	. = ..()

	src.minimap_type_renders = list()
	src.dynamic_area_overlays = list()
	src.render_minimaps(Z_LEVEL_STATION)

/// Set up all `/obj/minimap` and `/obj/minimap_controller` types.
/datum/minimap_renderer/proc/initialise_minimaps()
	for_by_tcl(minimap, /obj/minimap)
		minimap.initialise_minimap()

	for_by_tcl(controller, /obj/minimap_controller)
		controller.initialise_minimap_controller()

/// Renders a minimap portion for each map flag, and renders dynamic area overlays, storing them in `minimap_type_renders` and `dynamic_area_overlays` respectively.
/datum/minimap_renderer/proc/render_minimaps(z_level)
	if (!z_level)
		return

	// Iterates through all turfs on the map, creating a list for each minimap type required, this minimap type list itself containing lists of turfs to be drawn to an icon.
	var/list/turf/area_directory = list()
	var/list/list/turf/dynamic_area_directory = list()
	for (var/turf/T as anything in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
		if (!src.valid_turf(T))
			continue
		var/area/A = T.loc

		var/list/flags = list()
		if (A.minimaps_to_render_on == MAP_ALL)
			flags += MAP_ALL
		else
			flags = src.separate_bitflag(A.minimaps_to_render_on)

		// Sort areas with dynamic map colours into their own list, so that they may be drawn separately on an atom/movable which will be overlayed onto minimaps.
		if (A.dynamic_map_colour_group)
			// For each minimap type flag in the `minimaps_to_render_on` bitflag on the area, create a list for that minimap type in the directory, then populate that list with other lists containing turfs, organised by area type.
			for (var/flag in flags)
				dynamic_area_directory["[flag]"] ||= list()
				dynamic_area_directory["[flag]"]["[A.dynamic_map_colour_group]"] ||= list()
				dynamic_area_directory["[flag]"]["[A.dynamic_map_colour_group]"] += T

			continue

		// For each minimap type flag in the `minimaps_to_render_on` bitflag on the area, create a list for that minimap type in the directory, then populate that list with turfs belonging to that minimap type.
		for (var/flag in flags)
			area_directory["[flag]"] ||= list()
			area_directory["[flag]"] += T

	// Iterate over every minimap type in the area directory, and each turf within that minimap type's list, drawing it to an icon for that specific minimap type.
	for (var/minimap_type in area_directory)
		var/icon/minimap_type_render = icon('icons/obj/minimap/minimap.dmi', "blank")
		minimap_type_render.Scale(world.maxx, world.maxy)
		minimap_type_render.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))

		for (var/turf/turf as anything in area_directory["[minimap_type]"])
			minimap_type_render.DrawBox(turf_color(turf), turf.x, turf.y)

		src.minimap_type_renders["[minimap_type]"] = minimap_type_render

	// Iterate over every minimap type in the dynamic area directory, and create a list corresponding to that minimap type in the area minimap directory, then populate that list with renders of area groups to be overlayed onto minimaps.
	for (var/minimap_type in dynamic_area_directory)
		src.dynamic_area_overlays["[minimap_type]"] ||= list()

		for (var/area_group in dynamic_area_directory[minimap_type])
			var/icon/area_render = icon('icons/obj/minimap/minimap.dmi', "blank")
			area_render.Scale(world.maxx, world.maxy)
			area_render.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))

			for (var/turf/turf as anything in dynamic_area_directory[minimap_type][area_group])
				area_render.DrawBox(turf_color(turf), turf.x, turf.y)

			var/atom/movable/area_render_object = new
			area_render_object.icon = area_render
			area_render_object.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
			area_render_object.mouse_opacity = 0

			src.dynamic_area_overlays["[minimap_type]"]["[area_group]"] = area_render_object

/// Separates a given bitflag into a list of the separate bits composing it. Eg. 1011 -> (0001, 0010, 1000), or in base 10: 11 -> (1, 2, 8).
/datum/minimap_renderer/proc/separate_bitflag(bitflag)
	. = list()
	var/bit_length = ceil(log(2, (bitflag + 1)))

	for (var/i = 0 to bit_length)
		var/flag = 2**i
		if (flag & bitflag)
			. += flag

/// Checks whether a turf should be rendered on the minimap through the `minimaps_to_render_on` bitflag on `/area`.
/datum/minimap_renderer/proc/valid_turf(turf/T)
	if (!T.loc)
		return FALSE

	var/area/A = T.loc
	if (!A.minimaps_to_render_on)
		return FALSE

	return TRUE

/// Determine the colour of a turf on the minimap.
/datum/minimap_renderer/proc/turf_color(turf/T)
	if (!T.loc)
		return

	var/area/A = T.loc
	var/colour = A.station_map_colour

	if (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall) || (locate(/obj/mapping_helper/wingrille_spawn) in T) || (locate(/obj/window) in T))
		var/list/rgb_list = hex_to_rgb_list(colour)
		colour = rgb(rgb_list[1] * 0.7, rgb_list[2] * 0.7, rgb_list[3] * 0.7)
	else if (locate(/obj/machinery/door) in T)
		var/list/rgb_list = hex_to_rgb_list(colour)
		colour = rgb(rgb_list[1] * 0.85, rgb_list[2] * 0.85, rgb_list[3] * 0.85)

	return colour

/// Generates an `/atom/movable` for a specified minimap type.
/datum/minimap_renderer/proc/generate_minimap_render(minimap_type)
	var/atom/movable/minimap_render_object = new()
	var/icon/minimap_render = icon('icons/obj/minimap/minimap.dmi', "blank")
	minimap_render.Scale(world.maxx, world.maxy)

	var/list/flags = list()
	flags += MAP_ALL
	flags += src.separate_bitflag(minimap_type)

	for (var/flag in flags)
		for (var/area in src.dynamic_area_overlays["[flag]"])
			minimap_render_object.vis_contents += src.dynamic_area_overlays["[flag]"][area]

		if (!src.minimap_type_renders["[flag]"])
			continue

		var/icon/minimap_type_render = src.minimap_type_renders["[flag]"]
		minimap_render.Blend(minimap_type_render, ICON_OVERLAY)

	minimap_render_object.icon = minimap_render
	minimap_render_object.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
	minimap_render_object.mouse_opacity = 0

	return minimap_render_object

/// Recolours a specified dynamic area group to a given colour.
/datum/minimap_renderer/proc/recolor_area(area_group, colour)
	for (var/map_type in src.dynamic_area_overlays)
		if (!src.dynamic_area_overlays[map_type]["[area_group]"])
			continue

		var/atom/movable/area_render = src.dynamic_area_overlays[map_type]["[area_group]"]
		var/icon/area_render_icon = icon(area_render.icon)

		area_render_icon.SetIntensity(0)
		area_render_icon.SwapColor(rgb(0, 0, 0, 255), colour)
		area_render.icon = icon(area_render_icon)
