//TODO: Actually replace /obj/machinery/computer/security
//TODO: Bonus - Maybe support arrow keys...
/obj/machinery/computer/security2
	name = "security cameras"
	icon_state = "security"
	circuit_type = /obj/item/circuitboard/security
	desc = "A computer that allows one to connect to a security camera network and view camera images."
	deconstruct_flags = DECON_MULTITOOL

	light_r = 1
	light_g = 0.7
	light_b = 0.74

	var/obj/minimap_controller/camerasmap_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/cameras_minimap_ui

	disposing()
		//TODO: Disconnect current users
		..()

	process()
		..()
		//TODO: Close a user's viewport when they get too far away

	proc/get_minimap()
		return get_singleton(/obj/minimap/cameras)

/obj/machinery/computer/security2/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras1"
/obj/machinery/computer/security2/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras2"

/obj/machinery/computer/security2/wooden_tv
	icon_state = "security_det"
	circuit_type = /obj/item/circuitboard/security_tv

/obj/machinery/computer/security2/wooden_tv/small
	name = "television"
	desc = "These channels seem to mostly be about robuddies. What is this, some kind of reality show?"
	icon_state = "security_tv"
	circuit_type = /obj/item/circuitboard/small_tv
	density = FALSE

	power_change()
		return

	get_minimap()
		return get_singleton(/obj/minimap/cameras/public)

// -------------------- VR --------------------
/obj/machinery/computer/security2/wooden_tv/small/virtual
	desc = "It's making you feel kinda twitchy for some reason."
	icon = 'icons/effects/VR.dmi'
// --------------------------------------------

/obj/machinery/computer/security2/telescreen
	name = "Telescreen"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	density = 0

	power_change()
		return

	get_minimap()
		return get_singleton(/obj/minimap/cameras/thunder)

/obj/machinery/computer/security2/attack_hand(var/mob/user)
	if (status & (NOPOWER|BROKEN) || !user.client)
		return

	var/obj/minimap/cameras/cameras_map = get_minimap()

	if (!src.camerasmap_controller)
		src.camerasmap_controller = new(cameras_map)
	if (!src.cameras_minimap_ui)
		src.cameras_minimap_ui = new(src, "cameras_map", src.camerasmap_controller, src.name, "nanotrasen")
		//TODO: Set a property on minimap_controller/cameras_minimap_ui to prevent adding new markers
		//TODO: Bonus - Marker's list filter feature
		//TODO: Bonus - Marker's list favorite feature

	src.cameras_minimap_ui.ui_interact(user)

/obj/minimap/cameras
	name = "Security Cameras"
	map_path = /datum/minimap/area_map
	map_type = MAP_CAMERA_SECURITY

//TODO: Does this actually makes sense? Maybe they should work like /obj/item/device/camera_viewer instead
/obj/minimap/cameras/public
	name = "Television"
	map_type = MAP_CAMERA_PUBLIC
/obj/minimap/cameras/thunder
	name = "Thunderdome"
	map_type = MAP_CAMERA_THUNDER
