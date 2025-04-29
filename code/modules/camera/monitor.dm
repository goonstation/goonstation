TYPEINFO(/obj/item/device/camera_viewer)
	mats = 6

/obj/item/device/camera_viewer
	name = "camera monitor"
	desc = "A portable video monitor, connected to a security camera network."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	abilities = list(/obj/ability_button/reset_view)
	var/list/camera_networks = list(CAMERA_NETWORK_STATION)
	var/obj/machinery/camera/current = null
	// Sin but we need to know for disposing to clear viewer list on current
	var/mob/last_viewer = null

	disposing()
		src.disconnect_user(src.last_viewer)
		..()

	attack_self(mob/user)
		user.unlock_medal("I Spy", 1)

		var/obj/machinery/camera/C = src.select_camera(user)
		if(!istype(C))
			src.disconnect_user(user)
			return FALSE

		if ((!(user.contains(src)) || !can_act(user) || !user.sight_check(1) || !(C.camera_status)) && (!issilicon(user)))
			src.disconnect_user(user)
			return FALSE
		else if (src.current)
			src.current.move_viewer_to(user, C)
		else
			C.connect_viewer(user)
		src.current = C
		src.last_viewer = user
		return TRUE

	dropped(mob/user)
		..()
		src.disconnect_user(user)

	proc/disconnect_user(mob/user)
		src.current?.disconnect_viewer(user)
		src.last_viewer = null
		src.current = null

	proc/select_camera(mob/user)
		var/list/cameras = list()
		for_by_tcl(C, /obj/machinery/camera)
			cameras.Add(C)

		cameras = camera_sort(cameras)

		var/list/displayed_cameras = list()

		for (var/obj/machinery/camera/camera as anything in cameras)
			if (camera.network in src.camera_networks)
				displayed_cameras[text("[][]", camera.c_tag, (camera.camera_status ? null : " (Deactivated)"))] = camera

		var/selected_camera = tgui_input_list(user, "Which camera should you change to?", "Camera Selection", sortList(displayed_cameras, /proc/cmp_text_asc))

		if (!selected_camera)
			return FALSE

		return displayed_cameras[selected_camera]

/obj/item/device/camera_viewer/public
	desc = "A portable video monitor, connected to the public camera network."
	camera_networks = list(CAMERA_NETWORK_PUBLIC)

/obj/item/device/camera_viewer/security
	name = "security monitor"
	desc = "A portable video monitor, connected to the security camera network."
	camera_networks = list(CAMERA_NETWORK_STATION, CAMERA_NETWORK_SCIENCE, CAMERA_NETWORK_MINING)
	color = "#e49191"

/obj/item/device/camera_viewer/ranch
	name = "baby monitor"
	desc = "A portable video monitor, connected to the ranch camera network."
	camera_networks = list(CAMERA_NETWORK_RANCH)
	color = "#AAFF99"

/obj/item/device/camera_viewer/telesci
	name = "expedition monitor"
	desc = "A portable video monitor, connected to multiple expedition cameras."
	camera_networks = list(CAMERA_NETWORK_TELESCI)
	color = "#efb4e5"

/obj/item/device/camera_viewer/robot
	name = "robot monitor"
	desc = "A portable video monitor, connected to multiple internal machine cameras."
	camera_networks = list(CAMERA_NETWORK_ROBOTS)
	color = "#899a95"

/obj/item/device/camera_viewer/outpost/science
	name = "science outpost monitor"
	desc = "A portable video monitor, connected to the science outpost camera network."
	camera_networks = list(CAMERA_NETWORK_SCIENCE)
	color = "#efb4e5"

/obj/item/device/camera_viewer/outpost/mining
	name = "mining outpost monitor"
	desc = "A portable video monitor, connected to the mining outpost camera network."
	camera_networks = list(CAMERA_NETWORK_MINING)
	color = "#daa85c"

/obj/item/device/camera_viewer/sticker
	name = "camera monitor"
	desc = "A portable video monitor connected to a network of spy cameras."
	camera_networks = list(CAMERA_NETWORK_STICKERS)

/obj/item/device/camera_viewer/omniview
	name = "ADMIN CRIMES MONITOR"
	desc = "A portable video monitor, connected to EVERY NETWORK!"
	camera_networks = list(
		CAMERA_NETWORK_STATION,
		CAMERA_NETWORK_PUBLIC,
		CAMERA_NETWORK_ROBOTS,
		CAMERA_NETWORK_RANCH,
		CAMERA_NETWORK_MINING,
		CAMERA_NETWORK_SCIENCE,
		CAMERA_NETWORK_VSPACE,
		CAMERA_NETWORK_TELESCI,
		CAMERA_NETWORK_STICKERS,
		CAMERA_NETWORK_CARGO,
		CAMERA_NETWORK_AI_ONLY,
	)
	default_material = "miracle"
