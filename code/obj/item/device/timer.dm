/obj/item/device/timer
	name = "timer"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = 0
	var/time = null
	var/last_tick = 0
	var/const/max_time = 600 SECONDS
	var/const/min_time = 0
	var/const/min_detonator_time = 90 SECONDS
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_SMALL
	m_amt = 100
	mats = 2
	desc = "A device that emits a signal when the time reaches 0."

/obj/item/device/timer/proc/time()
	src.c_state(0)

	if (src.master)
		SPAWN( 0 )
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
	else
		for(var/mob/O in hearers(null, null))
			O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)

//*****RM


/obj/item/device/timer/proc/c_state(n)
	//src.icon_state = text("timer[]", n)

	if(src.master)
		src.master:c_state(n)

	return

//*****

/obj/item/device/timer/process()
	if (src.timing)
		if (!src.last_tick)
			src.last_tick = TIME
		var/passed_time = TIME - src.last_tick

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
			src.timing = FALSE
			src.last_tick = 0

		src.last_tick = TIME

	else
		// If it's not timing, reset the icon so it doesn't look like it's still about to go off.
		src.c_state(0)
		processing_items.Remove(src)
		src.last_tick = 0
	src.time = max(src.time, 0)

/obj/item/device/timer/attackby(obj/item/W, mob/user)
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
		R.set_dir(src.dir)
		src.add_fingerprint(user)
		return

/obj/item/device/timer/attack_self(mob/user as mob)
	src.ui_interact(user)

/obj/item/device/timer/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Timer")
		ui.open()

/obj/item/device/timer/ui_data(mob/user)
	src.process() //ehhhhh
	. = list(
		"time" = round(src.time / 10),
		"timing" = src.timing,
		"minTime" = round(src.get_min_time() / 10),
	)

/obj/item/device/timer/ui_static_data(mob/user)
	return list("name" = src.name)

/obj/item/device/timer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch (action)
		if ("set-time")
			var/time = text2num_safe(params["value"])
			src.set_time(round(time))
			. = TRUE
		if ("toggle-timing")
			src.timing = !src.timing
			if(src.timing)
				src.c_state(1)
				processing_items |= src

			if (istype(master, /obj/item/device/transfer_valve))
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a transfer valve at [log_loc(src.master)].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			else if (istype(src.master, /obj/item/assembly/time_ignite)) //Timer-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a timer on a timer-igniter assembly at [log_loc(src.master)]. Contents: [log_reagents(RI.part3)]")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			else if(istype(src.master, /obj/item/assembly/time_bomb))	//Timer-detonated single-tank bombs
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a timer on a single-tank bomb at [log_loc(src.master)].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			else if (istype(src.master, /obj/item/mine)) // Land mine.
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a timer on a [src.master.name] at [log_loc(src.master)].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			. = TRUE

/obj/item/device/timer/proc/is_detonator_trigger()
	if (src.master)
		if (istype(src.master, /obj/item/assembly/detonator/) && src.master.master)
			if (istype(src.master.master, /obj/machinery/portable_atmospherics/canister/) && in_interact_range(src.master.master, usr))
				return TRUE

///When attached to a detonator we can't be set to detonate immediately
/obj/item/device/timer/proc/get_min_time()
	return src.is_detonator_trigger() ? src.min_detonator_time : src.min_time

/obj/item/device/timer/proc/set_time(var/new_time as num)
	src.time = clamp(new_time, src.get_min_time(), src.max_time)
