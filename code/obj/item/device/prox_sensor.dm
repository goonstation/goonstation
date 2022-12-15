TYPEINFO(/obj/item/device/prox_sensor)
	mats = 2

/obj/item/device/prox_sensor
	name = "Proximity Sensor"
	icon_state = "motion0"
	var/armed = FALSE
	var/timing = FALSE
	var/time = 0
	var/last_tick = null
	var/const/max_time = 600 SECONDS
	var/const/min_time = 0
	flags = FPRINT | TABLEPASS| CONDUCT
	event_handler_flags = USE_FLUID_ENTER
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	m_amt = 300
	desc = "A device which transmits a signal when it detects movement nearby."

/obj/item/device/prox_sensor/dropped()
	..()
	SPAWN(0)
		src.sense()

/obj/item/device/prox_sensor/update_icon()
	var/n = 0
	if(armed) n = 1
	else if(timing) n = 2

	icon_state = "motion[n]"

	if(src.master)
		src.master:c_state(n)

/obj/item/device/prox_sensor/proc/sense()
	if (src.armed == 1)
		if (src.master)
			SPAWN(0)
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.data["message"] = "ACTIVATE"
				src.master.receive_signal(signal)
				return
		else
			for(var/mob/O in hearers(null, null))
				O.show_message("[bicon(src)] *beep* *beep*", 3, "*beep* *beep*", 2)

/obj/item/device/prox_sensor/process()
	if (src.timing)
		if (!src.last_tick)
			src.last_tick = TIME
		var/passed_time = TIME - src.last_tick

		if (src.time > 0)
			if(!src.armed)
				src.UpdateIcon()
				src.time -= passed_time
			else src.timing = FALSE
		else
			src.armed = TRUE
			src.time = 0
			src.timing = FALSE
			src.last_tick = 0
			setup_use_proximity()
			src.UpdateIcon()

		src.last_tick = TIME

	else
		src.last_tick = 0
		processing_items.Remove(src)
	src.time = max(src.time, 0)

/obj/item/device/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (isobserver(AM) || iswraith(AM) || isintangible(AM) || istype(AM, /obj/projectile) || AM.invisibility > INVIS_CLOAK)
		return
	if (AM.move_speed < 12)
		src.sense()
	return

/obj/item/device/prox_sensor/attackby(obj/item/device/radio/signaler/S, mob/user)
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

/obj/item/device/prox_sensor/attack_self(mob/user as mob)
	src.ui_interact(user)

/obj/item/device/prox_sensor/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Timer")
		ui.open()

/obj/item/device/prox_sensor/ui_data(mob/user)
	src.process() //ehhhhh
	. = list(
		"time" = round(src.time / 10),
		"timing" = src.timing,
		"armed" = src.armed,
	)

/obj/item/device/prox_sensor/ui_static_data(mob/user)
	return list(
		"minTime" = round(src.min_time / 10),
		"name" = src.name,
		"armButton" = TRUE,
	)

/obj/item/device/prox_sensor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch (action)
		if ("set-time")
			var/time = text2num_safe(params["value"])
			src.time = clamp(round(time), src.min_time, src.max_time)
			. = TRUE
		if ("toggle-armed")
			src.armed = !src.armed
			if (src.armed)
				setup_use_proximity()
			else
				remove_use_proximity()
			src.UpdateIcon()
			if(timing || armed) processing_items |= src

			var/turf/T = get_turf(src)
			if (master && istype(master, /obj/item/device/transfer_valve))
				logTheThing(LOG_BOMBING, usr, "[armed ? "armed" : "disarmed"] a proximity device on a transfer valve at [log_loc(T)].")
				message_admins("[key_name(usr)] [armed ? "armed" : "disarmed"] a proximity device on a transfer valve at [log_loc(T)].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			else if (src.master && istype(src.master, /obj/item/assembly/prox_ignite)) //Prox-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing(LOG_BOMBING, usr, "[armed ? "armed" : "disarmed"] a proximity device on a radio-igniter assembly at [T ? log_loc(T) : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")

			else if(src.master && istype(src.master, /obj/item/assembly/proximity_bomb))	//Prox-detonated single-tank bombs
				logTheThing(LOG_BOMBING, usr, "[armed ? "armed" : "disarmed"] a proximity device on a single-tank bomb at [T ? log_loc(T) : "horrible no-loc nowhere void"].")
				message_admins("[key_name(usr)] [armed ? "armed" : "disarmed"] a proximity device on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")

			. = TRUE

		if ("toggle-timing")
			src.timing = !src.timing
			src.UpdateIcon()
			if(timing || armed) processing_items |= src

			var/turf/T = get_turf(src)
			if (master && istype(master, /obj/item/device/transfer_valve))
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a prox-arming timer on a transfer valve at [log_loc(T)].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a prox-arming timer on a transfer valve at [log_loc(T)].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")
			else if (src.master && istype(src.master, /obj/item/assembly/prox_ignite)) //Proximity-detonated beaker assemblies
				var/obj/item/assembly/rad_ignite/RI = src.master
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a prox-arming timer on a radio-igniter assembly at [T ? log_loc(T) : "horrible no-loc nowhere void"]. Contents: [log_reagents(RI.part3)]")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")

			else if(src.master && istype(src.master, /obj/item/assembly/proximity_bomb))	//Radio-detonated single-tank bombs
				logTheThing(LOG_BOMBING, usr, "[timing ? "initiated" : "defused"] a prox-arming timer on a single-tank bomb at [T ? log_loc(T) : "horrible no-loc nowhere void"].")
				message_admins("[key_name(usr)] [timing ? "initiated" : "defused"] a prox-arming timer on a single-tank bomb at [T ? showCoords(T.x, T.y, T.z) : "horrible no-loc nowhere void"].")
				SEND_SIGNAL(src.master, "[timing ? COMSIG_ITEM_BOMB_SIGNAL_START : COMSIG_ITEM_BOMB_SIGNAL_CANCEL]")

			. = TRUE

	if (src.master)
		src.master.updateSelfDialog()

/obj/item/device/prox_sensor/Move()
	. = ..()
	src.sense()
