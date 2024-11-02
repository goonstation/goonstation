/obj/info_map
	name = "Information Map"
	icon = 'icons/obj/decals/posters.dmi'
	icon_state = "pw_map"
	var/atom/movable/minimap_ui_handler/minimap_ui
	var/obj/minimap/info/infomap

/obj/info_map/New()
	. = ..()
	src.infomap = new()
	src.infomap.initialise_minimap()
	src.infomap.map.create_minimap_marker(src, 'icons/obj/minimap/minimap_markers.dmi', "pin")

/obj/info_map/attack_hand(mob/user)
	. = ..()
	if(!minimap_ui)
		minimap_ui = new(src, minimap=src.infomap, tgui_title="Information Map")
	minimap_ui.ui_interact(user)

/obj/minimap/info
	name = "Information Map"
	map_path = /datum/minimap/area_map
	map_type = MAP_INFO
