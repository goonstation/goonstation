/obj/item/htr_minimap_controller
	name = "station map controller"
	desc = "A remote used to control a station map display, permitting the user to change zoom levels, pan the map, and manage map markers."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "minimap_controller"
	flags = TABLEPASS | CONDUCT | ONBELT
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
		var/obj/minimap/map_computer/htr_team/minimap
		for_by_tcl(map, /obj/minimap/map_computer/htr_team)
			minimap = map

		if (minimap)
			src.minimap_controller = new(minimap)
			src.minimap_ui = new(src, "nukeop_map", src.minimap_controller, "Station Map Controller", "ntos")
