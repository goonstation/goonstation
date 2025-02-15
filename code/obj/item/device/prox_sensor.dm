TYPEINFO(/obj/item/device/prox_sensor)
	mats = 2

/obj/item/device/prox_sensor
	name = "proximity sensor"
	icon_state = "motion0"
	var/armed = FALSE
	var/timing = FALSE
	var/time = 0
	var/last_tick = null
	var/const/max_time = 600 SECONDS
	var/const/min_time = 0
	flags = TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	m_amt = 300
	desc = "A device which transmits a signal when it detects movement nearby."

/obj/item/device/prox_sensor/New()
	..()
	src.AddComponent(/datum/component/proximity, FALSE)
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION, PROC_REF(assembly_manipulation))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ACTIVATION, PROC_REF(assembly_activation))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(signal_dropped))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE, PROC_REF(assembly_get_state))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT, PROC_REF(assembly_get_time_left))
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_SET_TRIGGER_TIME, PROC_REF(assembly_set_time))
	// Prox-Sensor + assembly-applier -> timer/Applier-Assembly
	src.AddComponent(/datum/component/assembly/trigger_applier_assembly)

/obj/item/device/prox_sensor/disposing()
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ACTIVATION)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_STATE)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_GET_TRIGGER_TIME_LEFT)
	UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_SET_TRIGGER_TIME)
	..()


/// ----------- Assembly-Related Procs -----------

/obj/item/device/prox_sensor/proc/assembly_manipulation(var/manipulated_sensor, var/obj/item/assembly/complete/parent_assembly, var/mob/user)
	src.attack_self(user)

/obj/item/device/prox_sensor/proc/assembly_activation(var/manipulated_sensor, var/obj/item/assembly/complete/parent_assembly, var/mob/user)
	//Activating a secured assembly sets it off -without- the UI. Good luck
	if(!src.timing)
		src.timing = TRUE
		src.UpdateIcon()
		if(timing || armed) processing_items |= src
		logTheThing(LOG_BOMBING, usr, "initiated a proximity's sensor's timer on a [src.master.name] at [log_loc(src.master)].")
		//missing log about contents of beakers
		return TRUE

/obj/item/device/prox_sensor/proc/assembly_get_state(var/manipulated_sensor, var/obj/item/assembly/complete/parent_assembly)
	if(src.armed)
		return ASSEMBLY_TRIGGER_ARMED
	else
		if(src.timing)
			return ASSEMBLY_TRIGGER_PREPARING
		else
			return ASSEMBLY_TRIGGER_NOT_ACTIVATED

/obj/item/device/prox_sensor/proc/assembly_get_time_left(var/manipulated_sensor, var/obj/item/assembly/complete/parent_assembly)
	return src.time

/obj/item/device/prox_sensor/proc/assembly_set_time(var/manipulated_sensor, var/obj/item/assembly/complete/parent_assembly, var/time_to_set)
	src.time = max(src.min_time, time_to_set)
	return src.time

/// ----------------------------------------------

/obj/item/device/prox_sensor/proc/signal_dropped()
	SPAWN(0)
		src.sense()

/obj/item/device/prox_sensor/update_icon()
	var/n = 0
	if(armed) n = 1
	else if(timing) n = 2

	icon_state = "motion[n]"

	if(src.master)
		if(istype(src.master,/obj/item/assembly/complete))
			var/obj/item/assembly/complete/checked_assembly = src.master
			if(checked_assembly.trigger == src) //in case a sensor is used for something else than a trigger
				checked_assembly.trigger_icon_prefix = icon_state
				checked_assembly.UpdateIcon()
		else
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
			src.GetComponent(/datum/component/proximity).set_detection(TRUE)
			src.UpdateIcon()

		src.last_tick = TIME

	else
		src.last_tick = 0
		processing_items.Remove(src)
	src.time = max(src.time, 0)

/obj/item/device/prox_sensor/EnteredProximity(atom/movable/AM)
	if (isobserver(AM) || iswraith(AM) || isintangible(AM) || istype(AM, /obj/projectile) || AM.invisibility > INVIS_CLOAK)
		return
	if (AM.move_speed < 12)
		src.sense()

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
	. = ..()
	switch (action)
		if ("set-time")
			var/time = text2num_safe(params["value"])
			src.time = clamp(round(time), src.min_time, src.max_time)
			. = TRUE
		if ("toggle-armed")
			src.armed = !src.armed
			if (src.armed)
				src.GetComponent(/datum/component/proximity).set_detection(TRUE)
			else
				src.GetComponent(/datum/component/proximity).set_detection(FALSE)
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
