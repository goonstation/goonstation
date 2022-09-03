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
	icon = 'icons/turf/floors.dmi'
	icon_state = "arcade"
	var/obj/station_map/map = null

	New(var/obj/station_map/map)
		..(map.loc)
		src.map = map

	proc/set_position(var/x, var/y)
		//the first term is the scaled location of 0,0 on the map
		//then add the actual position scaled by the map scale
		//add the pixel offset of the parent map
		//subtract 18 because ???
		src.pixel_x = round(-(world.maxx * src.map.scale - world.maxx)/2.0 + x * src.map.scale + src.map.pixel_x, 1) - 18
		src.pixel_y = round(-(world.maxy * src.map.scale - world.maxy)/2.0 + y * src.map.scale + src.map.pixel_y, 1) - 18

/obj/map_icon/tracking
	New(var/obj/station_map/map, var/atom/movable/target)
		..()
		// src.Scale(0.25,0.25)
		src.icon = target.icon
		src.icon_state = target.icon_state
		// target.render_target = ref(target)
		// src.render_source = target.render_target
		src.RegisterSignal(target, COMSIG_MOVABLE_SET_LOC, .proc/handle_move)
		src.RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/handle_move)
		src.handle_move(target)

	proc/handle_move(var/atom/movable/target)
		var/turf/T = get_turf(target)
		src.set_position(T.x, T.y)
/obj/station_map
	name = "Station map"
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
			render_map()
			zoom_map()
		icon = map_icon

	//generates the map from the current station layout
	proc/render_map()
		for (var/y in world.maxy to 1 step -1)
			for (var/x in 1 to world.maxx)
				var/turf/turf = locate(x, y, Z_LEVEL_STATION)
				if (!turf.loc || !(istype(turf.loc, /area/station) || istype(turf.loc, /area/research_outpost)))
					continue
				//the Kondaru off station owlry and abandoned research outpost are both considered part of the station but have no AI cams
				if (map_settings.name == "KONDARU" && (istype(turf.loc, /area/station/garden/owlery) || istype(turf.loc, /area/research_outpost/indigo_rye)))
					continue
				//keep track of the outer bounds of the station
				x_max = max(x_max, x)
				x_min = min(x_min, x)
				y_max = max(y_max, y)
				y_min = min(y_min, y)
				map_icon.DrawBox(turf_color(turf), x,y)

	//zooms and centers the map on the station
	proc/zoom_map()
		var/scale_x = world.maxx / ((x_max - x_min) + border_width)
		var/scale_y = world.maxy / ((y_max - y_min) + border_width)
		src.scale = min(scale_x, scale_y)
		//scale the whole thing to the largest axis
		src.Scale(src.scale, src.scale)

		//work out the center of the station
		src.center_x = (x_max + x_min)/2
		src.center_y = (y_max + y_min)/2
		//adjust by distance to real center
		src.pixel_x = -(center_x - (world.maxx/2)) * src.scale
		src.pixel_y = -(center_y - (world.maxy/2)) * src.scale

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
			var/x = text2num(param_list["icon-x"])
			var/y = text2num(param_list["icon-y"])
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
		src.plant_site = new(src)
		src.plant_site.set_position(100,100)
