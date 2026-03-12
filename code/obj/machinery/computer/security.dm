#define CANCEL_CAMERA_VIEW "(stop viewing)"

/// ALlows you to see a minimap of the station's cameras and open them from an associated list.
/obj/machinery/computer/camera_viewer
	name = "security camera viewer"
	desc = "A computer that allows one to connect to a camera network and view camera images."
	icon_state = "security"

	circuit_type = /obj/item/circuitboard/security
	light_r = 1
	light_g = 0.7
	light_b = 0.74

	var/obj/minimap_controller/camera_viewer_controller
	var/atom/movable/minimap_ui_handler/minimap_controller/camera_viewer/camera_minimap_ui
	var/list/camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_RANCH, CAMERA_NETWORK_CARGO, CAMERA_NETWORK_SCIENCE)

	// TODO: CHUI camera viewer feature: Favorite cameras (max: 8)
	// TODO: CHUI camera viewer feature: Set viewporrt
	// TODO: Feature: Clicking a camera in the minimap opens the camera
	// TODO: Feature: Indicate the currently viewed camera on the minimap

/obj/machinery/computer/camera_viewer/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras1"

/obj/machinery/computer/camera_viewer/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras2"

/obj/machinery/computer/camera_viewer/telescreen
	name = "Telescreen"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	density = 0

	power_change()
		return

/obj/machinery/computer/camera_viewer/New()
	src.connect_to_minimap()
	. = ..()

/obj/machinery/computer/camera_viewer/disposing()
	. = ..()
	qdel(src.camera_viewer_controller)
	src.camera_viewer_controller = null
	qdel(src.camera_minimap_ui)
	src.camera_minimap_ui = null

/obj/machinery/computer/camera_viewer/attack_hand(mob/user)
	if(..())
		return

	if (!src.camera_viewer_controller || !src.camera_minimap_ui)
		src.connect_to_minimap()

	src.camera_minimap_ui.ui_interact(user)

/obj/machinery/computer/camera_viewer/proc/connect_to_minimap()
	var/obj/minimap/camera_network/camera_viewer = get_singleton(/obj/minimap/camera_network)
	if (!src.camera_viewer_controller)
		src.camera_viewer_controller = new(camera_viewer)
	if (!src.camera_minimap_ui)
		src.camera_minimap_ui = new(src, "camera_viewer", src.camera_viewer_controller, "Camera Viewer", "nanotrasen")

/obj/minimap/camera_network
	name = "Station Cameras"
	map_path = /datum/minimap/area_map
	map_type = MAP_CAMERA_STATION

/// Allows you to select from a list of cameras, no minimap
/obj/machinery/computer/television
	name = "security television"
	desc = "Allows you to view cameras on connected networks to mollify your inner couch potato."
	icon_state = "security_det"
	circuit_type = /obj/item/circuitboard/security_tv
	/// Camera networks this TV can view
	var/list/camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_RANCH, CAMERA_NETWORK_CARGO, CAMERA_NETWORK_SCIENCE)
	/// The currently connected camera
	var/obj/machinery/camera/current = null
	/// List of current viewers
	var/list/mob/viewers

/obj/machinery/computer/television/disposing()
	src.disconnect_all_users()
	src.current = null
	..()

/obj/machinery/computer/television/attack_hand(mob/user)
	if (..())
		return

	if (!user.sight_check(TRUE))
		return

	var/camera_selection = src.select_camera(user)

	if (camera_selection == CANCEL_CAMERA_VIEW || camera_selection == FALSE)
		src.disconnect_user(user)

	var/obj/machinery/camera/camera_to_view = camera_selection

	if(!istype(camera_to_view))
		src.current = null
		src.disconnect_all_users()
		return

	if (!camera_to_view.camera_status)
		src.disconnect_all_users()
		return FALSE

	LAZYLISTADDUNIQUE(src.viewers, user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(user_moved), override = TRUE)

	if (src.current)
		for (var/mob/M as anything in src.viewers)
			src.current.move_viewer_to(M, camera_to_view)
	else
		for (var/mob/M as anything in src.viewers)
			camera_to_view.connect_viewer(M)

	src.current = camera_to_view
	src.Attackhand(user)
	return TRUE

/obj/machinery/computer/television/proc/user_moved(mob/user, atom/previous_loc, direction)
	if (BOUNDS_DIST(user, src) > 0)
		src.disconnect_user(user)

/obj/machinery/computer/television/proc/disconnect_user(mob/user)
	src.current?.disconnect_viewer(user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	LAZYLISTREMOVE(src.viewers, user)

/obj/machinery/computer/television/proc/disconnect_all_users()
	for (var/mob/M as anything in src.viewers)
		src.disconnect_user(M)

/obj/machinery/computer/television/proc/select_camera(mob/user)
	var/list/cameras = list()
	for_by_tcl(C, /obj/machinery/camera)
		if (C.network in src.camera_networks)
			cameras.Add(C)

	cameras = camera_sort(cameras)

	var/list/displayed_cameras = list()

	for (var/obj/machinery/camera/camera as anything in cameras)
		displayed_cameras[text("[][]", camera.c_tag, (camera.camera_status ? null : " (Deactivated)"))] = camera

	if (length(displayed_cameras) == 0)
		boutput(user, SPAN_ALERT("There are no cameras connected to this television!"))
		return FALSE

	displayed_cameras[CANCEL_CAMERA_VIEW] = CANCEL_CAMERA_VIEW

	var/selected_camera = tgui_input_list(user, "Which camera should you change to?", "Camera Selection", sortList(displayed_cameras, /proc/cmp_text_asc))

	if (!selected_camera)
		boutput(user, SPAN_ALERT("Unable to connect with selected camera!"))
		return FALSE

	return displayed_cameras[selected_camera]

/obj/machinery/computer/television/public
	name = "television"
	desc = "These channels seem to mostly be about robuddies. What is this, some kind of reality show?"
	camera_networks = list(CAMERA_NETWORK_PUBLIC, CAMERA_NETWORK_VSPACE)
	circuit_type = /obj/item/circuitboard/public_tv

/obj/machinery/computer/television/cargo
	name = "routing depot monitor"
	desc = "A monitor connected to the cargo routing depot camera network."
	camera_networks = list(CAMERA_NETWORK_CARGO)
	circuit_type = /obj/item/circuitboard/cargo_tv

/obj/machinery/computer/television/small
	name = "small television"
	desc = "These channels seem to mostly be about robuddies. What is this, some kind of reality show?"
	camera_networks = list(CAMERA_NETWORK_PUBLIC, CAMERA_NETWORK_VSPACE)
	icon_state = "security_tv"
	circuit_type = /obj/item/circuitboard/small_tv
	density = FALSE

	power_change()
		return

/obj/machinery/computer/television/small/virtual
	desc = "It's making you feel kinda twitchy for some reason."
	icon = 'icons/effects/VR.dmi'
	camera_networks = list(CAMERA_NETWORK_VSPACE)

/obj/machinery/computer/television/viewer
	name = "security camera network viewer"
	desc = "A computer that allows one to connect to a camera network and view camera images."
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "cameras1"

#undef CANCEL_CAMERA_VIEW
