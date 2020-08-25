/obj/item/device/timer
	name = "timer"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = 0.0
	var/time = null
	var/last_tick = 0
	var/const/max_time = 600
	var/const/min_time = 0
	var/const/min_detonator_time = 90
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	m_amt = 100
	mats = 2
	desc = "A device that emits a signal when the time reaches 0."
	module_research = list("devices" = 1, "miniaturization" = 4)

/obj/item/device/timer/proc/time()
	src.c_state(0)

	if (src.master)
		SPAWN_DBG( 0 )
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
			//qdel(signal)
			return
	else
		for(var/mob/O in hearers(null, null))
			O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)
	return

//*****RM


/obj/item/device/timer/proc/c_state(n)
	//src.icon_state = text("timer[]", n)

	if(src.master)
		src.master:c_state(n)

	return

//*****

/obj/item/device/timer/process()
	if (src.timing)
		if (!last_tick) last_tick = TIME
		var/passed_time = round(max(round(TIME - last_tick),10) / 10)

		if (src.time > 0)
			src.time -= passed_time
			if(time<5)
				src.c_state(2)
			else
				// they might increase the time while it is timing
				src.c_state(1)
		else
			time()
			src.time = 0
			src.timing = 0
			last_tick = 0

		last_tick = TIME

		if (!src.master)
			src.updateDialog()
		else
			src.master.updateDialog()

	else
		// If it's not timing, reset the icon so it doesn't look like it's still about to go off.
		src.c_state(0)
		processing_items.Remove(src)
		last_tick = 0

	return

/obj/item/device/timer/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/radio/signaler) )
		var/obj/item/device/radio/signaler/S = W
		if(!S.b_stat)
			return

		var/obj/item/assembly/rad_time/R = new /obj/item/assembly/rad_time( user )
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
		R.dir = src.dir
		src.add_fingerprint(user)
		return

/obj/item/device/timer/attack_self(mob/user as mob)
	..()
	if (user.stat || user.restrained() || user.lying)
		return

	if ((src in user) || (src.master && (src.master in user)) || (get_dist(src, user) <= 1 && istype(src.loc, /turf)) || src.is_detonator_trigger())
		src.add_dialog(user)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/detonator_trigger = src.is_detonator_trigger()
		var/timing_links = (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src))
		var/timing_text = (src.timing ? "Timing - controls locked" : "Not timing - controls unlocked")
		var/dat = text("<TT><B>Timing Unit</B><br>[] []:[]<br><A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A><br></TT>", detonator_trigger ? timing_text : timing_links, minute, second, src, src, src, src)
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user.Browse(dat, "window=timer")
		onclose(user, "timer")
	else
		user.Browse(null, "window=timer")
		src.remove_dialog(user)

	return

/obj/item/device/timer/proc/is_detonator_trigger()
	if (src.master)
		if (istype(src.master, /obj/item/assembly/detonator/) && src.master.master)
			if (istype(src.master.master, /obj/machinery/portable_atmospherics/canister/) && in_range(src.master.master, usr))
				return 1
	return 0

/obj/item/device/timer/proc/set_time(var/new_time as num)
	var/min_time = src.is_detonator_trigger() ? src.min_detonator_time : src.min_time
	src.time = clamp(new_time, min_time, src.max_time)

/obj/item/device/timer/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	var/can_use_detonator = src.is_detonator_trigger() && !src.timing
	if (can_use_detonator || (src in usr) || (src.master && (src.master in usr)) || in_range(src, usr) && istype(src.loc, /turf))
		src.add_dialog(usr)
		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			if(timing)
				src.c_state(1)
				if (!(src in processing_items))
					processing_items.Add(src)

			if (src.master && istype(master, /obj/item/device/transfer_valve))
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
			else if (src.master && istype(src.master, /obj/item/assembly/time_ignite)) //Timer-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a timer-igniter assembly at [log_loc(src.master)]. Contents: [log_reagents(RI.part3)]")

			else if(src.master && istype(src.master, /obj/item/assembly/time_bomb))	//Timer-detonated single-tank bombs
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")

			else if (src.master && istype(src.master, /obj/item/mine)) // Land mine.
				logTheThing("bombing", usr, null, "[timing ? "initiated" : "defused"] a timer on a [src.master.name] at [log_loc(src.master)].")

		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), src.min_time), src.max_time)
			if (can_use_detonator && src.time < src.min_detonator_time)
				src.time = src.min_detonator_time

		if (href_list["close"])
			usr.Browse(null, "window=timer")
			src.remove_dialog(usr)
			return

		if (!src.master)
			src.updateDialog()
		else
			src.master.updateDialog()

		src.add_fingerprint(usr)
	else
		usr.Browse(null, "window=timer")
		return
	return
