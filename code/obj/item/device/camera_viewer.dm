ABSTRACT_TYPE(/obj/item/device/camera_viewer)
TYPEINFO(/obj/item/device/camera_viewer)
	mats = 6

/obj/item/device/camera_viewer
	name = "camera monitor"
	desc = "A portable video monitor connected to a security camera network."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/list/networks
	var/obj/machinery/camera/current = null
	var/can_view_ai = FALSE

	attack_self(var/mob/user)
		user.unlock_medal("I Spy", 1)

		var/list/cameras = list()
		for_by_tcl(C, /obj/machinery/camera)
			cameras.Add(C)

		cameras = camera_sort(cameras)

		var/list/displayed_cameras = list()

		for (var/obj/machinery/camera/camera as anything in cameras)
			if (camera.network in src.networks)
				if (camera.ai_only && !src.can_view_ai)
					continue
				displayed_cameras[text("[][]", camera.c_tag, (camera.camera_status ? null : " (Deactivated)"))] = camera

		var/selected_camera = tgui_input_list(user, "Which camera should you change to?", "Camera Selection", sortList(displayed_cameras, /proc/cmp_text_asc))

		if (!selected_camera)
			user.set_eye(null)
			return 0

		var/obj/machinery/camera/C = displayed_cameras[selected_camera]

		if ((!user.contents.Find(src) || !can_act(user) || !user.sight_check(1) || !(C.camera_status)) && (!issilicon(user)))
			user.set_eye(null)
			return 0
		else
			user.set_eye(C)

	dropped(var/mob/user)
		..()
		user.set_eye(null)

/obj/item/device/camera_viewer/public
	desc = "A portable video monitor connected the public camera network."
	networks = list("public")

/obj/item/device/camera_viewer/security
	name = "security monitor"
	desc = "A portable video monitor connected the security camera network."
	networks = list("SS13", "Zeta", "Mining")
	color = "#e49191"

/obj/item/device/camera_viewer/ranch
	name = "baby monitor"
	desc = "A portable video monitor connected to the ranch camera network."
	networks = list("ranch")
	color = "#AAFF99"

/obj/item/device/camera_viewer/telesci
	name = "expedition monitor"
	desc = "A portable video monitor connected to multiple expedition cameras."
	networks = list("telesci")
	color = "#efb4e5"

/obj/item/device/camera_viewer/robot
	name = "robot monitor"
	desc = "A portable video monitor connected multiple internal machine cameras."
	networks = list("Robots")
	color = "#899a95"

/obj/item/device/camera_viewer/outpost/science
	name = "science outpost monitor"
	desc = "A portable video monitor connected the science outpost camera network."
	networks = list("Zeta")
	color = "#b88ed2"

/obj/item/device/camera_viewer/outpost/mining
	name = "mining outpost monitor"
	desc = "A portable video monitor connected the mining outpost camera network."
	networks = list("Mining")
	color = "#daa85c"

/obj/item/device/camera_viewer/omniview
	name = "ADMIN CRIMES MONITOR"
	desc = "A portable video monitor connected to EVERY NETWORK!"
	networks = list("Mining", "Zeta", "Robots", "ranch", "SS13", "public")
	can_view_ai = TRUE
	default_material = "miracle"
