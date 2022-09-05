///This is exclusively for the AI map right now

//TODO: remove this
/atom
	proc/make_icon_clone()
		var/obj/clone = new(get_turf(usr))
		clone.icon = src.icon
		clone.icon_state = src.icon_state
		src.render_target = ref(src)
		clone.render_source = src.render_target
		usr.vis_contents += clone
/obj/map_icon
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	mouse_opacity = 0
	var/obj/station_map/map = null

	New(var/atom/location, var/obj/station_map/map)
		..()
		src.map = map
		src.layer = map.layer + 0.1

	proc/set_position(var/x, var/y)
		var/icon/dummy_icon = new(src.icon)
		//the first term is the scaled distance to the map's center
		//then add the position of the true center
		//add the pixel offset of the parent map
		//subtract half the icon size
		src.pixel_x = (x - src.map.center_x) * src.map.scale + world.maxx/2 + src.map.pixel_x - dummy_icon.Width()/2
		src.pixel_y = (y - src.map.center_y) * src.map.scale + world.maxy/2 + src.map.pixel_y - dummy_icon.Height()/2

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
	var/static/icon/map_icon

	var/x_max = 1
	var/x_min = null
	var/y_max = 1
	var/y_min = null

	var/border_width = 20

	var/scale = 1
	var/center_x = 0
	var/center_y = 0

	New()
		..()
		x_min = world.maxx
		y_min = world.maxy
		if (!map_icon)
			map_icon = icon('icons/obj/station_map.dmi', "blank")
			#ifdef UPSCALED_MAP
			map_icon.Scale(world.maxx, world.maxy)
			#endif
		find_center()
		render_map()
		zoom_map()
		icon = map_icon
		var/icon/mask_icon = icon('icons/obj/station_map.dmi', "blank")
		mask_icon.Scale((1/src.scale) * 300, (1/src.scale) * 300)
		src.add_filter("map_cutoff", 1, alpha_mask_filter(0,0, mask_icon))

	proc/valid_turf(var/turf/turf)
		if (!turf.loc || !(istype(turf.loc, /area/station) || istype(turf.loc, /area/research_outpost)))
			return FALSE
		//the Kondaru off station owlry and abandoned research outpost are both considered part of the station but have no AI cams
		if ((map_settings.name in list("KONDARU", "DONUT3")) && (istype(turf.loc, /area/station/garden/owlery) || istype(turf.loc, /area/research_outpost/indigo_rye)))
			return FALSE
		return TRUE

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

	//generates the map from the current station layout
	proc/render_map()
		var/x_offset = src.center_x - world.maxx/2
		var/y_offset = src.center_y - world.maxy/2
		for (var/y in world.maxy to 1 step -1)
			for (var/x in 1 to world.maxx)
				var/turf/turf = locate(x, y, Z_LEVEL_STATION)
				if (!src.valid_turf(turf))
					continue
				map_icon.DrawBox(turf_color(turf), x - x_offset, y - y_offset)

	//zooms and centers the map on the station
	proc/zoom_map()
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
	var/obj/map_icon/plant_site
	New()
		..()
		src.Scale(0.5,0.5)
		src.scale *= 0.5
		//center it on the tile it was spawned from
		src.pixel_x -= 135
		src.pixel_y -= 133

		var/datum/game_mode/nuclear/gamemode = ticker?.mode
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
		src.plant_site = new(src.loc, src)
		src.plant_site.set_position(target_x,target_y)
