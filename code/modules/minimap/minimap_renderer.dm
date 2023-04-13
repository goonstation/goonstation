/datum/minimap_renderer
	var/list/minimap_type_renders = list()
	var/list/dynamic_area_overlays = list()

	New()
		. = ..()
		src.render_minimaps(Z_LEVEL_STATION)

	proc/render_minimaps(var/z_level)
		if (!z_level)
			return

		var/x_max = world.maxx
		var/x_min = 1
		var/y_max = world.maxy
		var/y_min = 1

		// Iterates through all turfs on the map, creating a list for each minimap type required, this minimap type list itself containing lists of turfs to be drawn to an icon.
		var/list/area_directory = list()
		var/list/dynamic_area_directory = list()
		for (var/turf/T in block(locate(x_min, y_min, z_level), locate(x_max, y_max, z_level)))
			if (!src.valid_turf(T))
				continue
			var/area/A = T.loc

			var/flags = list()
			if (A.minimaps_to_render_on == MAP_ALL)
				flags += MAP_ALL
			else
				flags = src.separate_bitflag(A.minimaps_to_render_on)

			// Sort areas with dynamic map colours into their own list, so that they may be drawn separately on an atom/movable which will be overlayed onto minimaps.
			if (A.dynamic_map_colour_group)
				// For each minimap type flag in the `minimaps_to_render_on` bitflag on the area, create a list for that minimap type in the directory, then populate that list with other lists containing turfs, organised by area type.
				for (var/flag in flags)
					if (!("[flag]" in dynamic_area_directory))
						dynamic_area_directory["[flag]"] = list()

					var/list/area_group_list = dynamic_area_directory["[flag]"]
					if (!("[A.dynamic_map_colour_group]" in area_group_list))
						area_group_list["[A.dynamic_map_colour_group]"] = list()

					var/list/turf_list = area_group_list["[A.dynamic_map_colour_group]"]
					turf_list.Add(T)

				continue

			// For each minimap type flag in the `minimaps_to_render_on` bitflag on the area, create a list for that minimap type in the directory, then populate that list with turfs belonging to that minimap type.
			for (var/flag in flags)
				if (!("[flag]" in area_directory))
					area_directory["[flag]"] = list()

				var/list/turf_list = area_directory["[flag]"]
				turf_list.Add(T)

		// Iterate over every minimap type in the area directory, and each turf within that minimap type's list, drawing it to an icon for that specific minimap type.
		for (var/minimap_type in area_directory)
			var/icon/minimap_type_render = icon('icons/obj/minimap/minimap.dmi', "blank")
			minimap_type_render.Scale(world.maxx, world.maxy)
			minimap_type_render.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))

			var/list/minimap_type_areas = area_directory["[minimap_type]"]
			for (var/turf/turf in minimap_type_areas)
				minimap_type_render.DrawBox(turf_color(turf), turf.x, turf.y)

			src.minimap_type_renders["[minimap_type]"] = minimap_type_render

		// Iterate over every minimap type in the dynamic area directory, and create a list corresponding to that minimap type in the area minimap directory, then populate that list with renders of area groups to be overlayed onto minimaps.
		for (var/minimap_type in dynamic_area_directory)
			if (!("[minimap_type]" in dynamic_area_overlays))
				dynamic_area_overlays["[minimap_type]"] = list()
			var/list/minimap_type_render_list = dynamic_area_overlays["[minimap_type]"]

			var/list/area_groups = dynamic_area_directory[minimap_type]
			for (var/area_group in area_groups)
				var/icon/area_render = icon('icons/obj/minimap/minimap.dmi', "blank")
				area_render.Scale(x_max, y_max)
				area_render.SwapColor(rgb(0, 0, 0), rgb(0, 0, 0, 0))

				var/list/area_list = area_groups[area_group]
				for (var/turf/turf in area_list)
					area_render.DrawBox(turf_color(turf), turf.x, turf.y)

				var/atom/movable/area_render_object = new
				area_render_object.icon = area_render
				area_render_object.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
				area_render_object.mouse_opacity = 0

				minimap_type_render_list["[area_group]"] = area_render_object

	///Separates a given bitflag into a list of the separate bits composing it. Eg. 1011 -> (0001, 0010, 1000), or in base 10: 11 -> (1, 2, 8)
	proc/separate_bitflag(var/bitflag)
		var/list/flag_list = list()
		var/bit_length = ceil(log(2, (bitflag + 1)))

		for (var/i = 0 to bit_length)
			if ((2**i) & bitflag)
				flag_list.Add(2**i)

		return flag_list

	///Checks whether a turf should be rendered on the minimap through the minimaps_to_render_on bitflag on /area.
	proc/valid_turf(var/turf/T)
		if (!T.loc)
			return FALSE
		var/area/A = T.loc
		if (!A.minimaps_to_render_on)
			return FALSE
		return TRUE

	///Determine the colour of a turf on the minimap through the station_map_colour variable on /turf.
	proc/turf_color(turf/T)
		if (!T.loc)
			return
		var/area/A = T.loc
		return A.station_map_colour

	///Generates an atom/movable for a specified minimap type.
	proc/generate_minimap_render(var/minimap_type)
		var/atom/movable/minimap_render_object = new()
		var/icon/minimap_render = icon('icons/obj/minimap/minimap.dmi', "blank")
		minimap_render.Scale(world.maxx, world.maxy)

		var/flags = list()
		flags += MAP_ALL
		flags += src.separate_bitflag(minimap_type)

		for (var/flag in flags)
			var/list/area_list = src.dynamic_area_overlays["[flag]"]
			for (var/area in area_list)
				var/atom/movable/area_render = area_list[area]
				minimap_render_object.vis_contents += area_render

			if (!("[flag]" in src.minimap_type_renders))
				continue

			var/icon/minimap_type_render = src.minimap_type_renders["[flag]"]
			minimap_render.Blend(minimap_type_render, ICON_OVERLAY)

		minimap_render_object.icon = minimap_render
		minimap_render_object.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		minimap_render_object.mouse_opacity = 0

		return minimap_render_object

	///Recolours a specified area group to a specified colour.
	proc/recolor_area(var/area_group, var/colour)
		for (var/map_type in src.dynamic_area_overlays)
			var/list/area_group_list = src.dynamic_area_overlays[map_type]

			if ("[area_group]" in area_group_list)
				var/atom/movable/area_render = area_group_list["[area_group]"]
				var/icon/area_render_icon = icon(area_render.icon)

				area_render_icon.SetIntensity(0)
				area_render_icon.SwapColor(rgb(0, 0, 0, 255), colour)
				area_render.icon = icon(area_render_icon)
