/obj/item/device/prox_sensor
	name = "Proximity Sensor"
	icon_state = "motion0"
	var/armed = 0.0
	var/timing = 0.0
	var/time = null
	flags = FPRINT | TABLEPASS| CONDUCT
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	w_class = 2.0
	item_state = "electronic"
	m_amt = 300
	mats = 2
	desc = "A device which transmits a signal when it detects movement nearby."
	module_research = list("science" = 2, "devices" = 1, "miniaturization" = 4)

/obj/item/device/prox_sensor/dropped()
	..()
	SPAWN_DBG(0)
		src.sense()

/obj/item/device/prox_sensor/proc/update_icon()
	var/n = 0
	if(armed) n = 1
	else if(timing) n = 2

	icon_state = "motion[n]"

	if(src.master)
		src.master:c_state(n)

	return

/obj/item/device/prox_sensor/proc/sense()
	if (src.armed == 1)
		if (src.master)
			SPAWN_DBG(0)
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["message"] = "ACTIVATE"
				src.master.receive_signal(signal)
				return
		else
			for(var/mob/O in hearers(null, null))
				O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	return

/obj/item/device/prox_sensor/process()
	if (src.timing)
		if (src.time > 0)
			if(src.armed != 1)
				src.update_icon()
				src.time = round(src.time) - 1
			else src.timing = 0
		else
			src.armed = 1
			src.time = 0
			src.timing = 0
			src.update_icon()


		if (!src.master)
			src.updateDialog()
		else
			src.master.updateDialog()

	else
		processing_items.Remove(src)
		return
	return

/obj/item/device/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (isobserver(AM) || iswraith(AM) || isintangible(AM) || istype(AM, /obj/projectile) || AM.invisibility > 2)
		return
	if (AM.move_speed < 12)
		src.sense()
	return

/obj/item/device/prox_sensor/attackby(obj/item/device/radio/signaler/S as obj, mob/user as mob)
	if ((!( istype(S, /obj/item/device/radio/signaler) ) || !( S.b_stat )))
		return
	var/obj/item/assembly/rad_prox/R = new /obj/item/assembly/rad_prox( user )
	S.set_loc(R)
	R.part1 = S
	S.layer = initial(S.layer)
	user.u_equip(S)
	user.put_in_hand_or_drop(R)
	S.master = R
	src.master = R
	src.layer = initial(src.layer)
	user.u_equip(src)
	src.set_loc(R)
	R.part2 = src
	R.set_dir(src.dir)
	src.add_fingerprint(user)
	return

/obj/item/device/prox_sensor/attack_self(mob/user as mob)
	if (user.stat || user.restrained() || user.lying)
		return
	if ((src in user) || (src.master && (src.master in user)) || get_dist(src, user) <= 1 && istype(src.loc, /turf))
		src.add_dialog(user)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<TT><B>Proximity Sensor</B><br>[] []:[]<br><A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A><br></TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><A href='?src=\ref[src];arm=1'>[src.armed ? "Armed":"Not Armed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user.Browse(dat, "window=prox")
		onclose(user, "prox")
	else
		user.Browse(null, "window=prox")
		src.remove_dialog(user)
		return

/obj/item/device/prox_sensor/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	if ((src in usr) || (src.master && (src.master in usr)) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["arm"])
			src.armed = !src.armed
			src.update_icon()
			if(timing || armed) processing_items |= src

			var/turf/T = get_turf(src)
			if (master && istype(master, /obj/item/device/transfer_valve))
				logTheThing("bombing", usr, null, "[armed ? "armed" : "disarmed"] a proximity device on a transfer valve at [showCoords(T.x, T.y, T.z)].")
				message_admins("[key_name(usr)] [armed ? "armed" : "disarmed"] a proximity device on a transfer valve at [showCoords(T.x, T.y, T.z)].")
			else if (src.master && istype(src.master, /obj/item/assembly/prox_ignite)) //Prox-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing("bombing", usr, null, "[armed ? "armed" : "disarmed"] a proximity device on a radio-igniter assembly at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")

			else if(src.master && istype(src.master, /obj/item/assembly/proximity_bomb))	//Prox-detonated single-tank bombs
				logTheThing("bombing", usr, null, "[armed ? "armed" : "disarmed"] a proximity device on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")
				message_admins("[key_name(usr)] [armed ? "armed" : "disarmed"] a proximity device on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")

		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			src.update_icon()
			if(timing || armed) processing_items |= src

			var/turf/T = get_turf(src)
			if (master && istype(master, /obj/item/device/transfer_valve))
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a prox-arming timer on a transfer valve at [showCoords(T.x, T.y, T.z)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a prox-arming timer on a transfer valve at [showCoords(T.x, T.y, T.z)].")
			else if (src.master && istype(src.master, /obj/item/assembly/prox_ignite)) //Proximity-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a prox-arming timer on a radio-igniter assembly at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")

			else if(src.master && istype(src.master, /obj/item/assembly/proximity_bomb))	//Radio-detonated single-tank bombs
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a prox-arming timer on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a prox-arming timer on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")

		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 600)

		if (href_list["close"])
			usr.Browse(null, "window=prox")
			src.remove_dialog(usr)
			return

		if (!src.master)
			src.updateSelfDialog()
		else
			src.master.updateSelfDialog()

	else
		usr.Browse(null, "window=prox")
		return
	return

/obj/item/device/prox_sensor/Move()
	. = ..()
	src.sense()
	return
