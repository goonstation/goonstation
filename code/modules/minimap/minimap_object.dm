/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = ANCHORED

	///The minimap datum for this minimap object, containing data on the appearance and scale of the minimap, handling resizes, and managing markers.
	var/datum/minimap/map
	///The minimap type path that `map` should use.
	var/map_path = /datum/minimap
	///A bitflag that will be passed to the datum and determines which areas and minimap markers are to be rendered on the minimap. For available flags, see `_std/defines/minimap.dm`.
	var/map_type
	///The desired scale of the physical map, as a multiple of the original size (300x300px).
	var/map_scale = 1

	New()
		. = ..()
		START_TRACKING
		src.map = new map_path(src.map_type, src.map_scale)
		src.vis_contents += src.map.minimap_holder

		for (var/atom/marker_target in minimap_marker_targets)
			SEND_SIGNAL(marker_target, COMSIG_NEW_MINIMAP_MARKER, src.map)

		// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
		if (!src.icon || !src.icon_state)
			var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
			click_overlay_icon.Scale(src.map.x_max * map_scale, src.map.y_max * map_scale)
			click_overlay_icon.ChangeOpacity(0)
			src.icon = click_overlay_icon
			src.mouse_opacity = 2

	disposing()
		STOP_TRACKING
		. = ..()

/obj/minimap/ai
	name = "AI Station Map"
	map_path = /datum/minimap/z_level/ai
	map_type = MAP_AI

	Click(location, control, params)
		if (!isAI(usr))
			return
		var/list/param_list = params2list(params)
		var/datum/minimap/z_level/ai_map = map
		if ("left" in param_list)
			// Convert from screen (x, y) to map (x, y) coordinates.
			var/x = round((text2num(param_list["icon-x"]) - ai_map.minimap_render.pixel_x) / (ai_map.zoom_coefficient * ai_map.map_scale))
			var/y = round((text2num(param_list["icon-y"]) - ai_map.minimap_render.pixel_y) / (ai_map.zoom_coefficient * ai_map.map_scale))
			var/turf/clicked = locate(x, y, map.z_level)
			if (isAIeye(usr))
				usr.set_loc(clicked)
			else
				var/mob/living/silicon/ai/mainframe = usr
				mainframe.eye_view()
				mainframe.eyecam.set_loc(clicked)
		if ("right" in param_list)
			return TRUE

/obj/minimap/map_computer
	bound_width = 160
	bound_height = 160

	map_path = /datum/minimap/z_level

	icon = 'icons/obj/minimap/map_computer.dmi'
	icon_state = "frame"

	pixel_point = TRUE

	map_scale = 0.5

	var/light_r = 1
	var/light_g = 1
	var/light_b = 1

	New()
		. = ..()
		// Magic numbers to align the minimap with the physical frame of the map.
		src.map.minimap_holder.pixel_x += 5
		src.map.minimap_holder.pixel_y += 4

		src.create_overlays()

	proc/create_overlays()
		// Computer scanlines overlay.
		var/atom/movable/overlay/scanlines = new /atom/movable/overlay
		var/icon/scanlines_icon = icon('icons/obj/minimap/map_computer.dmi', "scanlines")
		scanlines_icon.ChangeOpacity(0.2)
		scanlines.icon = scanlines_icon
		scanlines.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		scanlines.mouse_opacity = 0
		scanlines.color = "#303030" // The scanlines are by default white, allowing them to be recoloured.

		// Glass screen overlay.
		var/atom/movable/overlay/glass = new /atom/movable/overlay
		var/icon/glass_icon = icon('icons/obj/minimap/map_computer.dmi', "glass")
		glass_icon.ChangeOpacity(0.2)
		glass.icon = glass_icon
		glass.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
		glass.mouse_opacity = 0

		// Computer screen glow overlay.
		var/atom/movable/overlay/screen_light = new /atom/movable/overlay
		screen_light.icon = icon('icons/obj/minimap/map_computer.dmi', "screen_light")
		screen_light.vis_flags = VIS_INHERIT_ID
		screen_light.mouse_opacity = 0
		screen_light.plane = PLANE_LIGHTING
		screen_light.blend_mode = BLEND_ADD
		screen_light.layer = LIGHTING_LAYER_BASE
		screen_light.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)

		vis_contents += scanlines
		vis_contents += glass
		vis_contents += screen_light

		var/datum/light/light = new/datum/light/point
		light.set_brightness(1.3)
		light.set_color(light_r, light_g, light_b)
		light.set_height(2)
		light.attach(src, 2.5 + (src.pixel_x / 32), 2.5 + (src.pixel_y / 32))
		light.enable()

/obj/minimap/map_computer/nukeop
	name = "Atrium Station Map"
	desc = "A cutting-edge cathode ray tube monitor, actively rendering many dozens of kilobytes of stolen structural data."
	map_type = MAP_SYNDICATE

	light_r = 1
	light_g = 0.3
	light_b = 0.3

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/minimap/map_computer/pod_wars
	name = "Debris Field Map"
	desc = "A cutting-edge cathode ray tube monitor, actively rendering many dozens of kilobytes of reconnaissance data on the surrounding debris field."
	map_scale = 0.3

	nanotrasen
		map_type = MAP_POD_WARS_NANOTRASEN
		light_r = 0.3
		light_g = 0.3
		light_b = 1

		New()
			. = ..()
			START_TRACKING

		disposing()
			STOP_TRACKING
			. = ..()

	syndicate
		map_type = MAP_POD_WARS_SYNDICATE
		light_r = 1
		light_g = 0.3
		light_b = 0.3

		New()
			. = ..()
			START_TRACKING

		disposing()
			STOP_TRACKING
			. = ..()

/obj/minimap_controller
	name = "Map Controller"
	layer = TURF_LAYER
	anchored = ANCHORED

	///The controlled minimap object.
	var/obj/minimap/controlled_minimap
	///The minimap to be displayed, mostly identical to the controlled minimap with the exception that the scale will always be 1. Used to circumvent a bug.
	var/datum/minimap/displayed_minimap

	///Whether the next click will sample coordinates at the clicked point, or toggle dragging.
	var/selecting_coordinates = FALSE
	///A semi-transparent minimap marker used to communicate where the marker will be placed on the minimap.
	var/datum/minimap_marker/marker_silhouette
	///The icon that the marker silouette should use.
	var/selected_icon = "pin"
	///The sampled x coordinate.
	var/selected_x = 1
	///The sampled y coordinate.
	var/selected_y = 1

	///Whether or not the minimap is currently being dragged/panned by the user.
	var/dragging = FALSE
	///The "starting" x position of the drag/pan, allowing for distance moved in the x axis to be calculated and applied to the minimap.
	var/start_click_pos_x = null
	///The "starting" y position of the drag/pan, allowing for distance moved in the y axis to be calculated and applied to the minimap.
	var/start_click_pos_y = null

	New(var/obj/minimap/minimap)
		if (!minimap)
			return

		. = ..()
		src.controlled_minimap = minimap

		src.displayed_minimap = new minimap.map_path(minimap.map_type, 1, (1 / minimap.map_scale))
		for (var/atom/marker_target in minimap_marker_targets)
			SEND_SIGNAL(marker_target, COMSIG_NEW_MINIMAP_MARKER, displayed_minimap)

		src.vis_contents += src.displayed_minimap.minimap_render

		// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
		if (!src.icon || !src.icon_state)
			var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
			click_overlay_icon.Scale(src.displayed_minimap.x_max, src.displayed_minimap.y_max)
			click_overlay_icon.ChangeOpacity(0)
			src.icon = click_overlay_icon
			src.mouse_opacity = 2

	MouseWheel(dx, dy, loc, ctrl, params)
		var/list/param_list = params2list(params)
		var/datum/minimap/z_level/minimap = src.displayed_minimap
		var/datum/minimap/z_level/controlled_minimap = src.controlled_minimap.map

		// Convert from screen (x, y) to map (x, y) coordinates.
		var/x = round((text2num(param_list["icon-x"]) - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
		var/y = round((text2num(param_list["icon-y"]) - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))

		if (dy > 1)
			minimap.zoom_on_point(minimap.zoom_coefficient * 1.1, x, y)
			controlled_minimap.zoom_on_point(minimap.zoom_coefficient, x, y)
		else if (dy < 1)
			minimap.zoom_on_point(minimap.zoom_coefficient * 0.9, x, y)
			controlled_minimap.zoom_on_point(minimap.zoom_coefficient, x, y)

		src.pan_map(0, 0)

	Click(location, control, params)
		var/list/param_list = params2list(params)
		var/x = text2num(param_list["icon-x"])
		var/y = text2num(param_list["icon-y"])

		if (src.selecting_coordinates)
			src.dragging = FALSE
			var/datum/minimap/minimap = src.displayed_minimap

			// Convert from screen (x, y) to map (x, y) coordinates, and save to selected x, y vars.
			src.selected_x = round((x - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
			src.selected_y = round((y - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))

			src.selecting_coordinates = FALSE
		else
			src.start_click_pos_x = x
			src.start_click_pos_y = y
			src.dragging = !src.dragging

	MouseMove(location, control, params)
		if (!src.dragging && !src.selecting_coordinates)
			return

		var/list/param_list = params2list(params)
		var/x = text2num(param_list["icon-x"])
		var/y = text2num(param_list["icon-y"])

		if (src.dragging)
			src.pan_map(x - src.start_click_pos_x, y - src.start_click_pos_y)
			src.start_click_pos_x = x
			src.start_click_pos_y = y

		if (src.selecting_coordinates)
			var/datum/minimap/z_level/minimap = src.displayed_minimap

			// Convert from screen (x, y) to map (x, y) coordinates.
			x = round((x - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
			y = round((y - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))
			var/turf/map_location = locate(x, y, src.displayed_minimap.z_level)

			if (!src.marker_silhouette)
				src.displayed_minimap.create_minimap_marker(map_location, 'icons/obj/minimap/minimap_markers.dmi', src.selected_icon)
				src.marker_silhouette = src.displayed_minimap.minimap_markers[map_location]
				src.marker_silhouette.alpha_value = 175
				src.marker_silhouette.marker.alpha = 175

			src.marker_silhouette.target = map_location
			src.displayed_minimap.set_marker_position(src.marker_silhouette, src.marker_silhouette.target.x, src.marker_silhouette.target.y, src.displayed_minimap.z_level)

	proc/pan_map(var/x, var/y)
		src.displayed_minimap.minimap_render.pixel_x += x
		src.displayed_minimap.minimap_render.pixel_y += y

		src.controlled_minimap.map.minimap_render.pixel_x = (src.displayed_minimap.minimap_render.pixel_x - 8) * src.controlled_minimap.map_scale
		src.controlled_minimap.map.minimap_render.pixel_y = (src.displayed_minimap.minimap_render.pixel_y - 8) * src.controlled_minimap.map_scale

	proc/reset_scale()
		if (istype(src.controlled_minimap.map, /datum/minimap/z_level))
			var/datum/minimap/z_level/controlled_minimap = src.controlled_minimap.map
			controlled_minimap.find_focal_point()

			var/datum/minimap/z_level/displayed_minimap = src.displayed_minimap
			displayed_minimap.find_focal_point()

	proc/toggle_visibility_all(var/visible)
		for (var/atom/target in src.controlled_minimap.map.minimap_markers)
			if (target.z != src.controlled_minimap.map.z_level)
				continue

			var/datum/minimap_marker/marker_cm = src.controlled_minimap.map.minimap_markers[target]
			var/datum/minimap_marker/marker_dm = src.displayed_minimap.minimap_markers[target]
			if (visible == FALSE)
				marker_cm.marker.alpha = 0
				marker_cm.visible = FALSE
				marker_dm.marker.alpha = 0
				marker_dm.visible = FALSE
			else
				marker_cm.marker.alpha = marker_cm.alpha_value
				marker_cm.visible = TRUE
				marker_dm.marker.alpha = marker_dm.alpha_value
				marker_dm.visible = TRUE

	proc/toggle_visibility(var/datum/minimap_marker/marker_cm)
		var/datum/minimap_marker/marker_dm = src.displayed_minimap.minimap_markers[marker_cm.target]
		if (marker_dm.marker.alpha == marker_dm.alpha_value)
			marker_cm.marker.alpha = 0
			marker_cm.visible = FALSE
			marker_dm.marker.alpha = 0
			marker_dm.visible = FALSE
		else
			marker_cm.marker.alpha = marker_cm.alpha_value
			marker_cm.visible = TRUE
			marker_dm.marker.alpha = marker_dm.alpha_value
			marker_dm.visible = TRUE

	proc/new_marker(var/location, var/icon_state, var/name)
		src.displayed_minimap.create_minimap_marker(location, 'icons/obj/minimap/minimap_markers.dmi', icon_state, name, TRUE)
		src.controlled_minimap.map.create_minimap_marker(location, 'icons/obj/minimap/minimap_markers.dmi', icon_state, name, TRUE)

	proc/delete_marker(var/datum/minimap_marker/marker)
		src.displayed_minimap.remove_minimap_marker(marker.target)
		src.controlled_minimap.map.remove_minimap_marker(marker.target)

/obj/item/nukeop_minimap_controller
	name = "atrium station map controller"
	desc = "A remote used to control a station map display, permitting the user to change zoom levels, pan the map, and manage map markers."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "minimap_controller"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	item_state = "minimap_controller"
	throw_speed = 4
	throw_range = 20

	var/obj/minimap_controller/minimap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/minimap_ui

	New()
		. = ..()
		src.connect_to_minimap()

	attack_self(mob/user)
		. = ..()
		if (!src.minimap_controller || !src.minimap_ui)
			src.connect_to_minimap()
			if (!src.minimap_controller || !src.minimap_ui)
				return
		src.minimap_ui.ui_interact(user)

	proc/connect_to_minimap()
		var/obj/minimap/map_computer/nukeop/minimap
		for_by_tcl(map, /obj/minimap/map_computer/nukeop)
			minimap = map

		if (minimap)
			src.minimap_controller = new(minimap)
			src.minimap_ui = new(src, "nukeop_map", src.minimap_controller, "Atrium Station Map Controller", "syndicate")

ABSTRACT_TYPE(/obj/machinery/computer/pod_wars_minimap_controller)
/obj/machinery/computer/pod_wars_minimap_controller
	name = "debris field map controller"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "pod_wars_minimap_controller"
	bound_width = 64
	bound_height = 32

	var/obj/minimap_controller/minimap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/minimap_ui
	var/team_num = null

	New()
		. = ..()
		src.connect_to_minimap()

		var/image/screen_light = image('icons/obj/large/64x64.dmi', "minimap_controller_lights")
		screen_light.plane = PLANE_LIGHTING
		screen_light.blend_mode = BLEND_ADD
		screen_light.layer = LIGHTING_LAYER_BASE
		screen_light.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
		src.UpdateOverlays(screen_light, "screen_light")

	attack_hand(mob/user)
		if(status & (BROKEN|NOPOWER))
			return

		add_fingerprint(user)
		if (!src.minimap_controller || !src.minimap_ui)
			src.connect_to_minimap()
			if (!src.minimap_controller || !src.minimap_ui)
				return
		src.minimap_ui.ui_interact(user)

	proc/connect_to_minimap()
		var/obj/minimap/map_computer/pod_wars/minimap
		switch(team_num)
			if (TEAM_NANOTRASEN)
				for_by_tcl(map, /obj/minimap/map_computer/pod_wars/nanotrasen)
					minimap = map

				if (minimap)
					src.minimap_controller = new(minimap)
					src.minimap_ui = new(src, "nt_debris_minimap", src.minimap_controller, "Debris Field Map Controller", "ntos")

			if (TEAM_SYNDICATE)
				for_by_tcl(map, /obj/minimap/map_computer/pod_wars/syndicate)
					minimap = map

				if (minimap)
					src.minimap_controller = new(minimap)
					src.minimap_ui = new(src, "synd_debris_minimap", src.minimap_controller, "Debris Field Map Controller", "syndicate")

	nanotrasen
		team_num = TEAM_NANOTRASEN

	syndicate
		team_num = TEAM_SYNDICATE
