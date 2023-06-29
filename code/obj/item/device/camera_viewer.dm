TYPEINFO(/obj/item/device/camera_viewer)
	mats = 6

/obj/item/device/camera_viewer
	name = "camera monitor"
	desc = "A portable video monitor connected to a security camera network."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	var/network = "SS13"
	var/obj/machinery/camera/current = null

	attack_self(mob/user as mob)
		src.add_dialog(user)
		user.unlock_medal("I Spy", 1)

		var/list/L = list()
		for_by_tcl(C, /obj/machinery/camera)
			L.Add(C)
			LAGCHECK(LAG_LOW)

		L = camera_sort(L)

		var/list/D = list()

		for (var/obj/machinery/camera/C in L)
			if (C.network == src.network && !C.ai_only)
				D[text("[][]", C.c_tag, (C.camera_status ? null : " (Deactivated)"))] = C
			LAGCHECK(LAG_LOW)

		var/t = tgui_input_list(user, "Which camera should you change to?", "Camera Selection", sortList(D, /proc/cmp_text_asc))

		if(!t)
			user.set_eye(null)
			return 0

		var/obj/machinery/camera/C = D[t]

		if ((!user.contents.Find(src) || !( user.canmove ) || !user.sight_check(1) || !( C.camera_status )) && (!issilicon(user)))
			user.set_eye(null)
			return 0
		else
			user.set_eye(C)

			SPAWN(0.5 SECONDS)
				attack_self(user)

/obj/item/device/camera_viewer/ranch
	network = "ranch"
	name = "baby monitor"
	color = "#AAFF99"
