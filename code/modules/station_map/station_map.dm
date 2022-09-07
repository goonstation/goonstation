/obj/map_icon
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = TRUE
	mouse_opacity = 0
	var/obj/station_map/map = null

	//the world coordinates where the map icon is rendered
	var/pos_x = 100
	var/pos_y = 100

	New(var/atom/location, var/obj/station_map/map)
		..()
		src.map = map
		src.map.map_icons |= src
		src.layer = map.layer + 0.1

	///Sets the icon's position on the map from world coordinates
	proc/set_position(var/x, var/y)
		src.pos_x = x
		src.pos_y = y
		//if we're zoomed in then use the zoomed center coordinates
		var/center_x = src.map.zoom_level == 1 ? src.map.center_x : src.map.zoom_x
		var/center_y = src.map.zoom_level == 1 ? src.map.center_y : src.map.zoom_y
		var/icon/dummy_icon = new(src.icon)
		var/offset_x = 0
		var/offset_y = 0
		//if the map isn't centered on the real turf then add an offset to center it
		if (!src.map.centered)
			offset_x = world.maxx/2 + src.map.pixel_x - dummy_icon.Width()/2
			offset_y = world.maxy/2 + src.map.pixel_y - dummy_icon.Height()/2
		src.pixel_x = (x - center_x) * src.map.scale + offset_x
		src.pixel_y = (y - center_y) * src.map.scale + offset_y

	disposing()
		src.map.map_icons -= src
		. = ..()

/obj/map_icon/tracking
	New(var/atom/location, var/obj/station_map/map, var/atom/movable/target)
		..()
		src.icon = target.icon
		src.icon_state = target.icon_state
		src.RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, .proc/handle_move)
		src.RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/handle_move)
		src.handle_move(target)

	proc/handle_move(var/atom/movable/target)
		var/turf/T = get_turf(target)
		src.set_position(T.x, T.y)
/obj/station_map
	name = "Station map"
	layer = TURF_LAYER
	anchored = TRUE
	//The generated map render, stored to avoid having to recalculate it
	var/static/icon/map_render

	var/list/obj/map_icon/map_icons = new()

	///The actual size the map should be clipped to (multiple of original icon size)
	var/clip_scale = 1

	///Is the map centered on the actual turf it sits on?
	var/centered = FALSE

	//temporary zoom vars
	var/zoom_level = 1
	var/zoom_x = 0
	var/zoom_y = 0

	//the extents of the station in world coordinates
	var/x_max = 1
	var/x_min = null
	var/y_max = 1
	var/y_min = null

	///The width in pixels between the edge of the station and the edge of the map
	var/border_width = 20

	//the actual scale of the map object, equivalent to transform.a
	var/scale = 1

	//the world coordinates of the center of the station
	var/center_x = 0
	var/center_y = 0

	New()
		..()
		x_min = world.maxx
		y_min = world.maxy
		src.find_center()
		if (!map_render)
			map_render = icon('icons/obj/station_map.dmi', "blank")
			#ifdef UPSCALED_MAP
			map_render.Scale(world.maxx, world.maxy)
			#endif
			src.render_map()
		src.auto_zoom_map()
		src.Scale(src.clip_scale, src.clip_scale)
		src.scale *= src.clip_scale
		icon = map_render
		src.clip_area(src.center_x,src.center_y)
		if (src.centered)
			//center it on the tile it was spawned from
			src.pixel_x -= world.maxx * clip_scale - 16
			src.pixel_y -= world.maxy * clip_scale - 16

	proc/update_map_icons()
		for (var/obj/map_icon/map_icon in src.map_icons)
			map_icon.set_position(map_icon.pos_x, map_icon.pos_y)

	///Zoom the map to a world coordinate
	proc/manual_zoom(var/x, var/y, var/zoom)
		src.zoom_level = zoom
		src.zoom_x = x
		src.zoom_y = y
		src.scale *= zoom
		src.Scale(zoom, zoom)
		src.pixel_x -= ceil((x - src.center_x) * src.scale)
		src.pixel_y -= ceil((y - src.center_y) * src.scale)
		src.clip_area(x,y, zoom)
		src.update_map_icons()

	///Stupid naive unzoom
	proc/unzoom()
		src.pixel_x += ceil((src.zoom_x - src.center_x) * src.scale)
		src.pixel_y += ceil((src.zoom_y - src.center_y) * src.scale)
		src.Scale(1/src.zoom_level, 1/src.zoom_level)
		src.scale /= src.zoom_level
		src.zoom_level = 1
		src.clip_area(src.center_x, src.center_y)
		src.update_map_icons()

	///Clip the map to size around a world coordinate
	proc/clip_area(var/x,var/y)
		var/icon/mask_icon = icon('icons/obj/station_map.dmi', "blank")
		//scale by the physical icon scale and scale factor of the map
		var/mask_scale = (src.clip_scale / src.scale) * mask_icon.Width()
		mask_icon.Scale(mask_scale, mask_scale)
		src.add_filter("map_cutoff", 1, alpha_mask_filter(x - src.center_x, y - src.center_y, mask_icon))

	///Should a turf be rendered on the map
	proc/valid_turf(var/turf/turf)
		if (!turf.loc || !(istype(turf.loc, /area/station) || istype(turf.loc, /area/research_outpost)))
			return FALSE
		//the Kondaru off station owlry and abandoned research outpost are both considered part of the station but have no AI cams
		if ((map_settings.name in list("KONDARU", "DONUT3")) && (istype(turf.loc, /area/station/garden/owlery) || istype(turf.loc, /area/research_outpost/indigo_rye)))
			return FALSE
		return TRUE

	///Locate the center of the map by using the furthest valid turf in each direction
	proc/find_center()
		for (var/y in world.maxy to 1 step -1)
			for (var/x in 1 to world.maxx)
				var/turf/turf = locate(x, y, Z_LEVEL_STATION)
				if (!src.valid_turf(turf))
					continue
				//keep track of the outer bounds of the station
				x_max = max(x_max, x)
				x_min = min(x_min, x)
				y_max = max(y_max, y)
				y_min = min(y_min, y)

		src.center_x = (x_max + x_min)/2
		src.center_y = (y_max + y_min)/2

	///Renders the map in the center of the icon
	proc/render_map()
		var/x_offset = src.center_x - world.maxx/2
		var/y_offset = src.center_y - world.maxy/2
		for (var/y in world.maxy to 1 step -1)
			for (var/x in 1 to world.maxx)
				var/turf/turf = locate(x, y, Z_LEVEL_STATION)
				if (!src.valid_turf(turf))
					continue
				//offset the pixels so the station is always in the center of the icon
				map_render.DrawBox(turf_color(turf), x - x_offset, y - y_offset)

	///Zooms the map on the station
	proc/auto_zoom_map()
		var/scale_x = world.maxx / ((x_max - x_min) + border_width)
		var/scale_y = world.maxy / ((y_max - y_min) + border_width)
		src.scale = min(scale_x, scale_y)
		//scale the whole thing to the largest axis
		src.Scale(src.scale, src.scale)

	proc/turf_color(turf/turf)
		if (istype(turf.loc, /area/station/hydroponics) || istype(turf.loc, /area/station/ranch))
			return "#0da70d"
		else if (istype(turf.loc, /area/station/medical) && !istype(turf.loc, /area/station/medical/morgue))
			return "#1ba7e9"
		else if (istype(turf.loc, /area/station/science) || istype(turf.loc, /area/research_outpost))
			return "#8e0bc2"
		else if (istype(turf.loc, /area/station/security) || istype(turf.loc, /area/station/hos) || istype(turf.loc, /area/station/ai_monitored/armory))
			return "#b10202"
		else if (istype(turf.loc, /area/station/engine) || istype(turf.loc, /area/station/quartermaster) || istype(turf.loc, /area/station/mining) || istype(turf.loc, /area/station/construction))
			return "#e4d835"
		else if (istype(turf.loc, /area/station/chapel))
			return "#75602d"
		else if (istype(turf.loc, /area/station/bridge) || istype(turf.loc, /area/station/turret_protected) || istype(turf.loc, /area/station/teleporter) || istype(turf.loc, /area/station/ai_monitored))
			return "#1e2861"
		else if (istype(turf.loc, /area/station/maintenance))
			return "#474747"
		else if (istype(turf.loc, /area/station/hallway))
			return "#ffffff"
		else
			return "#808080"
/obj/station_map/ai
	name = "AI station map"
	New()
		..()
		pixel_y += 20 //magic numbers because ByondUI mis-aligns by a few pixels
		pixel_x += 8

	Click(location, control, params)
		if (!isAI(usr)) //only for AI use
			return
		var/list/param_list = params2list(params)
		if ("left" in param_list)
			var/x = text2num(param_list["icon-x"]) + (src.center_x - world.maxx/2)
			var/y = text2num(param_list["icon-y"]) + (src.center_y - world.maxy/2)
			var/turf/clicked = locate(x, y, Z_LEVEL_STATION)
			if (isAIeye(usr))
				usr.loc = clicked
			else
				var/mob/living/silicon/ai/mainframe = usr
				mainframe.eye_view() //pop out to eye first
				mainframe.eyecam.loc = clicked //then tele it, not our core
		if ("right" in param_list)
			return TRUE

/obj/station_map/nukie
	//too many things break with a big scaled object so we just pass all the clicks through
	//to the turfs underneath
	mouse_opacity = 0
	clip_scale = 0.5
	centered = TRUE
	var/obj/map_icon/plant_site
	New()
		START_TRACKING
		..()

	///Add a map icon on the nuke plant location
	proc/set_marker()
		var/datum/game_mode/nuclear/gamemode = ticker?.mode
		//find the center of the plant site
		var/x_max = 0
		var/y_max = 0
		var/x_min = world.maxx
		var/y_min = world.maxy
		if (istype(gamemode))
			for (var/area_type in gamemode.target_location_type)
				var/list/area/areas = get_areas(area_type)
				for (var/area/area in areas)
					for (var/turf/turf in area)
						x_max = max(turf.x, x_max)
						y_max = max(turf.y, y_max)
						x_min = min(turf.x, x_min)
						y_min = min(turf.y, y_min)
		var/target_x = (x_max + x_min) / 2
		var/target_y = (y_max + y_min) / 2
		//add an icon for it
		src.plant_site = new(src.loc, src)
		src.plant_site.set_position(target_x,target_y)

	proc/toggle_zoom()
		if (src.zoom_level == 1)
			src.manual_zoom(src.plant_site.pos_x, src.plant_site.pos_y, 2)
		else
			src.unzoom()

	disposing()
		STOP_TRACKING
		. = ..()

/obj/map_button
	name = "Button"
	desc = "Press to toggle the station map zoom level."
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_button"
	density = 1
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"
	var/obj/station_map/nukie/map = null

	New()
		..()
		for_by_tcl(nukie_map, /obj/station_map/nukie)
			src.map = nukie_map
			return

	attack_hand(mob/user)
		. = ..()
		if (src.icon_state == src.icon_up)
			flick(src.icon_down, src)
			map.toggle_zoom()
