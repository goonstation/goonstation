var/list/minimap_z_levels = list(Z_LEVEL_STATION, Z_LEVEL_DEBRIS, Z_LEVEL_MINING)


/**
 *	The minimap renderer is responsible for generating partial renders of area minimaps for each minimap type flag and generating
 *	full renders of radar minimaps, alongside updating radar minimaps and dynamic area overlays. In the case of querying for area
 *	minimaps, a minimap type bitflag may be passed to the renderer, which will then return a full render of the map comprised of
 *	the aforementioned partial renders. In the case of querying for radar minimaps, a minimap `atom/movable` will be returned,
 *	containing both the radar map icon and the radar map markers.
 */
/datum/minimap_renderer
	/// A list of partial minimap renders for each minimap type flag. Icons are indexed by z-level and type.
	var/list/list/icon/minimap_type_renders
	/// A list of dynamic area overlays for minimaps. Are overlays are indexed by z-level, type, and dynamic area group.
	var/list/list/list/atom/movable/dynamic_area_overlays
	/// A list of radar minimap renders. Indexed by z-level.
	var/list/icon/radar_minimaps_by_z_level
	/// A list of radar minimap objects. Indexed by z-level.
	var/list/atom/movable/radar_minimap_objects_by_z_level
	/// A list of minimap render modifiers, sorted by priority.
	var/list/datum/minimap_render_modifier/minimap_modifiers
	/// Does this minimap render space, if so - what color? Null if it renders space as black.
	var/render_space_color = null

/datum/minimap_renderer/New()
	. = ..()

	src.minimap_type_renders = list()
	src.dynamic_area_overlays = list()
	src.radar_minimaps_by_z_level = list()
	src.radar_minimap_objects_by_z_level = list()

	src.minimap_modifiers = list()
	for (var/T in concrete_typesof(/datum/minimap_render_modifier))
		src.minimap_modifiers += new T()

	sortList(src.minimap_modifiers, GLOBAL_PROC_REF(cmp_minimap_modifiers))

	src.render_minimaps()
	src.render_radar_minimap()

/// Set up all `/obj/minimap`, `/obj/minimap_controller`, and `/datum/minimap_marker/render` types.
/datum/minimap_renderer/proc/initialise_minimaps()
	for_by_tcl(minimap, /obj/minimap)
		minimap.initialise_minimap()

	for_by_tcl(controller, /obj/minimap_controller)
		controller.initialise_minimap_controller()

	for_by_tcl(render_marker, /datum/minimap_marker/render)
		render_marker.handle_move(null, null, get_turf(render_marker.target))

/// Renders a minimap portion for each map flag, and renders dynamic area overlays, storing them in `minimap_type_renders` and `dynamic_area_overlays` respectively.
/datum/minimap_renderer/proc/render_minimaps()
	for (var/z_level in global.minimap_z_levels)
		src.minimap_type_renders["[z_level]"] ||= list()
		src.dynamic_area_overlays["[z_level]"] ||= list()

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

			src.minimap_type_renders["[z_level]"]["[minimap_type]"] = minimap_type_render

		// Iterate over every minimap type in the dynamic area directory, and create a list corresponding to that minimap type in the area minimap directory, then populate that list with renders of area groups to be overlayed onto minimaps.
		for (var/minimap_type in dynamic_area_directory)
			src.dynamic_area_overlays["[z_level]"]["[minimap_type]"] ||= list()

			for (var/area_group in dynamic_area_directory[minimap_type])
				var/icon/area_render = icon('icons/obj/minimap/minimap.dmi', "blank")
				area_render.Scale(world.maxx, world.maxy)
				area_render.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))

				for (var/turf/turf as anything in dynamic_area_directory[minimap_type][area_group])
					area_render.DrawBox(src.turf_color(turf), turf.x, turf.y)

				var/atom/movable/area_render_object = new
				area_render_object.icon = area_render
				area_render_object.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
				area_render_object.mouse_opacity = 0

				src.dynamic_area_overlays["[z_level]"]["[minimap_type]"]["[area_group]"] = area_render_object

/// Initialises the radar minimap.
/datum/minimap_renderer/proc/render_radar_minimap()
	for (var/z_level as anything in global.minimap_z_levels)
		src.radar_minimaps_by_z_level["[z_level]"] = icon('icons/obj/minimap/minimap.dmi', "blank")
		src.radar_minimaps_by_z_level["[z_level]"].Scale(world.maxx, world.maxy)

		var/atom/movable/radar_minimap = new()
		radar_minimap.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		radar_minimap.mouse_opacity = 0

		src.radar_minimap_objects_by_z_level["[z_level]"] = radar_minimap

		// Iterates through all turfs on the map, creating a list for each minimap type required, this minimap type list itself containing lists of turfs to be drawn to an icon.
		for (var/turf/T as anything in block(locate(1, 1, z_level), locate(world.maxx, world.maxy, z_level)))
			src.update_radar_map(T, FALSE)

		src.radar_minimap_objects_by_z_level["[z_level]"].icon = icon(src.radar_minimaps_by_z_level["[z_level]"])

/// Updates the pixel on a radar minimap render corresponding to the specified turf.
/datum/minimap_renderer/proc/update_radar_map(turf/T, update_icon = TRUE)
	if (!src.radar_minimaps_by_z_level["[T.z]"])
		return

	var/colour = src.turf_color(T)
	if (colour != "#000000")
		var/list/turf_hsl = hex_to_hsl_list(colour)
		colour = hsl2rgb(110, 33, turf_hsl[3])

	src.radar_minimaps_by_z_level["[T.z]"].DrawBox(colour, T.x, T.y)

	/*
	Disable dynamic radar map updates until explosions and other large turf
	updates can be better supported by the RSC updates

	if (update_icon)
		src.radar_minimap_objects_by_z_level["[T.z]"].icon = icon(src.radar_minimaps_by_z_level["[T.z]"])
	*/

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

	// Not a modifier to cut down on proccalls
	if (istype(T, /turf/space))
		return src.render_space_color || "#000000"

	var/area/A = T.loc
	var/list/turf_hsl = hex_to_hsl_list(A.station_map_colour)
	for (var/datum/minimap_render_modifier/modifier as anything in src.minimap_modifiers)
		if (modifier.is_compatible(T))
			turf_hsl = modifier.process(turf_hsl)
			break

	return hsl2rgb(turf_hsl[1], turf_hsl[2], turf_hsl[3])

/// Generates a list of `/atom/movable` objects for each z-level for a specified minimap type.
/datum/minimap_renderer/proc/generate_minimap_icons(minimap_type)
	. = list()

	var/list/flags = src.separate_bitflag(minimap_type) + MAP_ALL
	for (var/z_level in global.minimap_z_levels)
		var/icon/minimap_render = icon('icons/obj/minimap/minimap.dmi', "blank")
		minimap_render.Scale(world.maxx, world.maxy)

		for (var/flag in flags)
			if (!src.minimap_type_renders["[z_level]"]["[flag]"])
				continue

			var/icon/minimap_type_render = src.minimap_type_renders["[z_level]"]["[flag]"]
			minimap_render.Blend(minimap_type_render, ICON_OVERLAY)

		.["[z_level]"] = minimap_render

/// Returns a dynamic area overlay `atom/movable` for a specified minimap type.
/datum/minimap_renderer/proc/get_minimap_dynamic_area_overlays(minimap_type)
	. = list()

	var/list/flags = src.separate_bitflag(minimap_type) + MAP_ALL
	for (var/z_level in global.minimap_z_levels)
		.["[z_level]"] ||= list()

		for (var/flag in flags)
			for (var/area in src.dynamic_area_overlays["[z_level]"]["[flag]"])
				.["[z_level]"] += src.dynamic_area_overlays["[z_level]"]["[flag]"][area]

/// Recolours a specified dynamic area group to a given colour.
/datum/minimap_renderer/proc/recolor_area(area_group, colour)
	for (var/z_level in src.dynamic_area_overlays)
		for (var/map_type in src.dynamic_area_overlays)
			if (!src.dynamic_area_overlays[z_level][map_type]["[area_group]"])
				continue

			var/atom/movable/area_render = src.dynamic_area_overlays[z_level][map_type]["[area_group]"]
			var/icon/area_render_icon = icon(area_render.icon)

			area_render_icon.SetIntensity(0)
			area_render_icon.SwapColor(rgb(0, 0, 0, 255), colour)
			area_render.icon = icon(area_render_icon)

/// Compare the priority of two minimap render modifiers.
/proc/cmp_minimap_modifiers(datum/minimap_render_modifier/a, datum/minimap_render_modifier/b)
	return b.priority - a.priority

