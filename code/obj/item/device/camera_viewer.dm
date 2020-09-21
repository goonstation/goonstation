/obj/item/device/camera_viewer
	name = "Camera monitor"
	desc = "A portable video monitor connected to a security camera network."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = 2.0
	var/network = "SS13"
	var/obj/machinery/camera/current = null
	mats = 6

	attack_self(mob/user as mob)
		src.add_dialog(user)
		user.unlock_medal("Peeping Tom", 1)

		var/list/L = list()
		for (var/obj/machinery/camera/C in by_type[/obj/machinery/camera])
			L.Add(C)
			LAGCHECK(LAG_LOW)

		L = camera_sort(L)

		var/list/D = list()
		D["Cancel"] = "Cancel"
		for (var/obj/machinery/camera/C in L)
			if (C.network == src.network)
				D[text("[][]", C.c_tag, (C.camera_status ? null : " (Deactivated)"))] = C
			LAGCHECK(LAG_LOW)

		var/t = input(user, "Which camera should you change to?") as null|anything in D

		if(!t || t == "Cancel")
			user.set_eye(null)
			return 0

		var/obj/machinery/camera/C = D[t]

		if ((!user.contents.Find(src) || !( user.canmove ) || !user.sight_check(1) || !( C.camera_status )) && (!issilicon(user)))
			user.set_eye(null)
			return 0
		else
			user.set_eye(C)

			SPAWN_DBG(0.5 SECONDS)
				attack_self(user)
