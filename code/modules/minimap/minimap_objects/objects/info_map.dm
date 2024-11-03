TYPEINFO(/obj/machinery/info_map)
	mats = list("metal" = 2,
				"conductive" = 5,
				"crystal" = 4)

/obj/machinery/info_map
	name = "Information Map"
	desc = "You are here."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "info_on"
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	power_usage = 5 WATTS
	var/atom/movable/minimap_ui_handler/minimap_ui
	var/obj/minimap/info/infomap

/obj/machinery/info_map/New()
	. = ..()
	src.infomap = new()
	src.infomap.initialise_minimap()
	src.infomap.map.create_minimap_marker(src, 'icons/obj/minimap/minimap_markers.dmi', "pin")

	// reposition onto wall
	if(pixel_y == 0 && pixel_x == 0)
		if (map_settings.walls ==/turf/simulated/wall/auto/jen)
			pixel_y = 32
		else
			pixel_y = 29

/obj/machinery/info_map/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!src.minimap_ui)
		src.minimap_ui = new(src, minimap=src.infomap, tgui_title="Information Map")
	src.minimap_ui.ui_interact(user)

/obj/machinery/info_map/power_change()
	. = ..()
	if (src.powered())
		src.icon_state = "info_on"
	else
		src.icon_state = "info_off"

/obj/machinery/info_map/disposing()
	. = ..()
	qdel(src.minimap_ui)
	src.minimap_ui = null
	qdel(src.infomap)
	src.infomap = null

/obj/minimap/info
	name = "Information Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_INFO
