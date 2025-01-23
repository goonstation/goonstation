TYPEINFO(/obj/item/device/camera_viewer)
	mats = 6

/obj/item/device/camera_viewer
	name = "camera monitor"
	desc = "A portable video monitor, connected to a security camera network."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	abilities = list(/obj/ability_button/reset_view)
	var/list/network = list("SS13")
	var/obj/machinery/camera/current = null
	// Sin but we need to know for disposing to clear viewer list on current
	var/mob/last_viewer = null
	var/can_view_ai = FALSE

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
			if (camera.network in src.network)
				if (camera.ai_only && !src.can_view_ai)
					continue
				displayed_cameras[text("[][]", camera.c_tag, (camera.camera_status ? null : " (Deactivated)"))] = camera

		var/selected_camera = tgui_input_list(user, "Which camera should you change to?", "Camera Selection", sortList(displayed_cameras, /proc/cmp_text_asc))

		if (!selected_camera)
			return FALSE

		return displayed_cameras[selected_camera]

/obj/item/device/camera_viewer/public
	desc = "A portable video monitor, connected to the public camera network."
	network = list("public")

/obj/item/device/camera_viewer/security
	name = "security monitor"
	desc = "A portable video monitor, connected to the security camera network."
	network = list("SS13", "Zeta", "Mining")
	color = "#e49191"

/obj/item/device/camera_viewer/ranch
	name = "baby monitor"
	desc = "A portable video monitor, connected to the ranch camera network."
	network = list("ranch")
	color = "#AAFF99"

/obj/item/device/camera_viewer/telesci
	name = "expedition monitor"
	desc = "A portable video monitor, connected to multiple expedition cameras."
	network = list("telesci")
	color = "#efb4e5"

/obj/item/device/camera_viewer/robot
	name = "robot monitor"
	desc = "A portable video monitor, connected to multiple internal machine cameras."
	network = list("Robots")
	color = "#899a95"

/obj/item/device/camera_viewer/outpost/science
	name = "science outpost monitor"
	desc = "A portable video monitor, connected to the science outpost camera network."
	network = list("Zeta")
	color = "#efb4e5"

/obj/item/device/camera_viewer/outpost/mining
	name = "mining outpost monitor"
	desc = "A portable video monitor, connected to the mining outpost camera network."
	network = list("Mining")
	color = "#daa85c"

/obj/item/device/camera_viewer/sticker
	name = "camera monitor"
	desc = "A portable video monitor connected to a network of spy cameras."
	network = list("stickers")

/obj/item/device/camera_viewer/omniview
	name = "ADMIN CRIMES MONITOR"
	desc = "A portable video monitor, connected to EVERY NETWORK!"
	network = list("Mining", "Zeta", "Robots", "ranch", "SS13", "public", "VR")
	can_view_ai = TRUE
	default_material = "miracle"
