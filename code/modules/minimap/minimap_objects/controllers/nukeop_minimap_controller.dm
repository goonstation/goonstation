/obj/item/nukeop_minimap_controller
	name = "atrium station map controller"
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

/obj/item/nukeop_minimap_controller/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
	src.connect_to_minimap()

/obj/item/nukeop_minimap_controller/disposing()
	STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
	. = ..()

/obj/item/nukeop_minimap_controller/attack_self(mob/user)
	. = ..()
	if (!src.minimap_controller || !src.minimap_ui)
		src.connect_to_minimap()
		if (!src.minimap_controller || !src.minimap_ui)
			return
	src.minimap_ui.ui_interact(user)

/obj/item/nukeop_minimap_controller/proc/connect_to_minimap()
	var/obj/minimap/map_computer/nukeop/minimap
	for_by_tcl(map, /obj/minimap/map_computer/nukeop)
		minimap = map

	if (minimap)
		src.minimap_controller = new(minimap)
		src.minimap_ui = new(src, "nukeop_map", src.minimap_controller, "Atrium Station Map Controller", "syndicate")
