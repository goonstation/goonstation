TYPEINFO(/obj/machinery/info_map)
	mats = list("metal" = 2,
				"conductive" = 5,
				"crystal" = 4)

/obj/machinery/info_map
	name = "Information Map"
	desc = "You are here."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "stationmap"
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	power_usage = 5 WATTS
	plane = PLANE_NOSHADOW_ABOVE
	var/obj/minimap/info/infomap
#ifdef IN_MAP_EDITOR
	pixel_y = 29
#endif

/obj/machinery/info_map/New()
	. = ..()
	src.infomap = new()
	src.infomap.display = src

	// reposition onto wall
	if(pixel_y == 0 && pixel_x == 0)
		if (map_settings.walls ==/turf/simulated/wall/auto/jen)
			pixel_y = 32
		else
			pixel_y = 29

/obj/machinery/info_map/initialize()
	. = ..()
	src.infomap.initialise_minimap()
	src.infomap.map.create_minimap_marker(src, 'icons/obj/minimap/minimap_markers.dmi', "pin")

/obj/machinery/info_map/was_built_from_frame(mob/user, newly_built)
	. = ..()
	src.initialize()

/obj/machinery/info_map/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/datum/hud/hud = user.get_hud()
	if (!hud)
		return
	hud.add_object(src.infomap, HUD_LAYER, "CENTER,CENTER-3")
	user.apply_color_matrix(COLOR_MATRIX_SHADE, COLOR_MATRIX_SHADE_LABEL)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(user_moved))

/obj/machinery/info_map/proc/user_moved(mob/user, atom/previous_loc, direction)
	if (BOUNDS_DIST(user, src) > 0)
		src.infomap.close(user)

/obj/machinery/info_map/disposing()
	. = ..()
	qdel(src.infomap)
	src.infomap = null

/obj/minimap/info
	name = "Information Map"
	map_path = /datum/minimap/area_map/transparent
	map_type = MAP_INFO
	plane = PLANE_HUD
	layer = HUD_LAYER
	var/obj/machinery/info_map/display = null

	New()
		. = ..()
		src.appearance_flags |= NO_CLIENT_COLOR

	initialise_minimap()
		. = ..()
		src.map.map.plane = src.plane
		src.map.map.layer = src.layer

	Click(location, control, params)
		var/list/param_list = params2list(params)
		if ("left" in param_list)
			var/turf/clicked = src.get_turf_at_screen_coords(text2num(param_list["icon-x"]), text2num(param_list["icon-y"]))
			if (!istype(clicked.loc, /area/space))
				usr.gpsToTurf(clicked, TRUE, timeout = 40 SECONDS)
			else
				usr.removeGpsPath(FALSE)
		src.close(usr)

	proc/close(mob/user)
		display.UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		user.remove_color_matrix(COLOR_MATRIX_SHADE_LABEL)
		var/datum/hud/hud = user.get_hud()
		hud.remove_object(src)

	disposing()
		src.display = null
		. = ..()

