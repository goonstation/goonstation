/obj/minimap
	name = "Station Map"
	layer = TURF_LAYER
	anchored = TRUE
	var/datum/minimap/map
	var/atom/movable/minimap_holder
	var/map_path = /datum/minimap
	var/map_type
	var/map_scale = 1

	New()
		. = ..()
		START_TRACKING
		src.minimap_holder = new
		src.minimap_holder.vis_flags = VIS_INHERIT_LAYER
		src.minimap_holder.appearance_flags = KEEP_TOGETHER
		src.minimap_holder.mouse_opacity = 0
		src.map = new map_path(src.map_type, src.map_scale)

		src.vis_contents += src.minimap_holder
		src.minimap_holder.vis_contents += src.map.minimap_render

		for (var/atom/movable/marker_object in minimap_marker_targets)
			SEND_SIGNAL(marker_object, COMSIG_NEW_MINIMAP_MARKER, src)

		// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
		if (!icon || !icon_state)
			var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
			click_overlay_icon.Scale(300 * map_scale, 300 * map_scale)
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
		src.minimap_holder.pixel_x += 5
		src.minimap_holder.pixel_y += 4

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
		light.attach(src, 2.5, 2.5)
		light.enable()

/obj/minimap/map_computer/nukeop
	name = "Atrium Station Map"
	map_type = MAP_SYNDICATE

	light_r = 1
	light_g = 0.3
	light_b = 0.3

	var/static/list/plant_locations = list()

	New()
		. = ..()
		START_TRACKING
		src.create_plant_location_markers()

	disposing()
		STOP_TRACKING
		. = ..()

	proc/create_plant_location_markers()
		if (length(plant_locations) > 0)
			for (var/turf/plant_location in plant_locations)
				var/area/A = plant_location.loc
				map.create_minimap_marker(plant_location, 'icons/obj/minimap/minimap_markers.dmi', "nuclear_bomb_pin", "[capitalize(A.name)] Plant Site")
			return

		src.plant_locations = list()
		var/list/target_locations = list()
		if (istype(ticker?.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/gamemode = ticker?.mode
			target_locations = gamemode.target_location_type
		else
			return

		// Find the centres of the plant sites.
		for (var/area_type in target_locations)
			var/max_x = map.x_min
			var/min_x = map.x_max
			var/max_y = map.y_min
			var/min_y = map.y_max
			var/list/area/areas = get_areas(area_type)
			for (var/area/area in areas)
				if (area.z != Z_LEVEL_STATION)
					continue
				for (var/turf/T in area)
					max_x = max(max_x, T.x)
					min_x = min(min_x, T.x)
					max_y = max(max_y, T.y)
					min_y = min(min_y, T.y)
			var/target_x = (max_x + min_x) / 2
			var/target_y = (max_y + min_y) / 2

			var/turf/plant_location = locate(target_x, target_y, Z_LEVEL_STATION)
			src.plant_locations += plant_location
			var/area/A = plant_location.loc
			map.create_minimap_marker(plant_location, 'icons/obj/minimap/minimap_markers.dmi', "nuclear_bomb_pin", "[capitalize(A.name)] Plant Site")

/obj/minimap_controller
	name = "Map Controller"
	layer = TURF_LAYER
	anchored = TRUE
	var/obj/minimap/controlled_minimap
	var/filter
	var/marker_to_be_placed = null
	var/dragging = FALSE
	var/start_click_pos_x = null
	var/start_click_pos_y = null

	New(var/obj/minimap)
		if (!minimap)
			return

		. = ..()
		src.controlled_minimap = minimap
		src.vis_contents += src.controlled_minimap.map.minimap_render
		src.filter = src.controlled_minimap.map.minimap_render.filters[length(src.controlled_minimap.map.minimap_render.filters)]

		// As the minimap render is transparent to clicks, the minimap will require an overlay which clicks may register on.
		if (!icon || !icon_state)
			var/icon/click_overlay_icon = icon('icons/obj/minimap/minimap.dmi', "blank")
			click_overlay_icon.Scale(300 * src.controlled_minimap.map_scale, 300 * src.controlled_minimap.map_scale)
			click_overlay_icon.ChangeOpacity(0)
			src.icon = click_overlay_icon
			src.mouse_opacity = 2

	MouseWheel(dx, dy, loc, ctrl, params)
		var/list/param_list = params2list(params)
		var/datum/minimap/z_level/minimap = src.controlled_minimap.map
		var/x = round((text2num(param_list["icon-x"]) - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
		var/y = round((text2num(param_list["icon-y"]) - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))
		if (dy > 1 && minimap.zoom_coefficient < 20)
			minimap.zoom_on_point(minimap.zoom_coefficient * 1.1, x, y)
		else if (dy < 1 && minimap.zoom_coefficient > 1)
			minimap.zoom_on_point(minimap.zoom_coefficient * 0.9, x, y)

	Click(location, control, params)
		var/list/param_list = params2list(params)
		var/x = text2num(param_list["icon-x"])
		var/y = text2num(param_list["icon-y"])

		if (src.marker_to_be_placed)
			src.dragging = FALSE
			var/datum/minimap/minimap = src.controlled_minimap.map
			var/map_x = round((x - minimap.minimap_render.pixel_x) / (minimap.zoom_coefficient * minimap.map_scale))
			var/map_y = round((y - minimap.minimap_render.pixel_y) / (minimap.zoom_coefficient * minimap.map_scale))

			var/turf/T = locate(map_x, map_y, minimap.z_level)
			minimap.create_minimap_marker(T, 'icons/obj/minimap/minimap_markers.dmi', "[marker_to_be_placed]")
			src.marker_to_be_placed = null
		else
			src.start_click_pos_x = x
			src.start_click_pos_y = y
			src.dragging = !src.dragging

	MouseMove(location, control, params)
		if (!src.dragging)
			return

		var/list/param_list = params2list(params)
		var/x = text2num(param_list["icon-x"])
		var/y = text2num(param_list["icon-y"])

		src.pan_map(x - src.start_click_pos_x, y - src.start_click_pos_y)
		src.start_click_pos_x = x
		src.start_click_pos_y = y

	proc/pan_map(var/x, var/y)
		src.controlled_minimap.map.minimap_render.pixel_x += x
		src.controlled_minimap.map.minimap_render.pixel_y += y
		filter:x -= x
		filter:y -= y

/obj/item/nukeop_minimap_controller
	name = "atrium station map controller"
	desc = null
	icon = 'icons/obj/items/device.dmi'
	icon_state = "minimap_controller"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	item_state = "minimap_controller"
	throw_speed = 4
	throw_range = 20

	var/obj/minimap_controller/minimap_controller
	var/atom/movable/minimap_ui_handler/minimap_ui

	New()
		. = ..()
		src.connect_to_minimap()

	attack_self(mob/user)
		. = ..()
		if (!minimap_controller || !minimap_ui)
			src.connect_to_minimap()
			if (!minimap_controller || !minimap_ui)
				return
		minimap_ui.ui_interact(user)

	proc/connect_to_minimap()
		var/obj/minimap/map_computer/nukeop/minimap
		for_by_tcl(map, /obj/minimap/map_computer/nukeop)
			minimap = map

		if (minimap)
			src.minimap_controller = new(minimap)
			src.minimap_ui = new(src, "nukeop_map", src.minimap_controller)
