//
// Firealarm
//
ADMIN_INTERACT_PROCS(/obj/machinery/firealarm, proc/alarm, proc/reset)
/obj/machinery/firealarm
	name = "Fire Alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "firep"
	plane = PLANE_NOSHADOW_ABOVE
	deconstruct_flags = DECON_WIRECUTTERS | DECON_MULTITOOL
	machine_registry_idx = MACHINES_FIREALARMS
	power_usage = 10
	power_channel = ENVIRON
	var/alarm_frequency = FREQ_ALARM
	var/detecting = 1
	var/working = 1
	var/lockdownbyai = 0
	anchored = ANCHORED
	var/alarm_zone
	var/net_id
	var/ringlimiter = 0
	var/dont_spam = 0
	var/static/manual_off_reactivate_idle = 4 //! how many machine loop ticks to idle after being manually switched off
	var/idle_count = 0
	/// specifies if the alarm is currently going off
	var/alarm_active = FALSE
	var/image/alarm_base_overlay
	var/image/alarm_overlay
	text = ""

	desc = "A fire sensor and alarm system. When it detects fire or is manually activated, it closes all firelocks in the area to minimize the spread of fire."

/obj/machinery/firealarm/New()
	..()
	START_TRACKING
	if(!alarm_zone)
		var/area/A = get_area(loc)
		alarm_zone = A.name

	if(!net_id)
		net_id = generate_net_id(src)

	alarm_base_overlay = image(src.icon, src, "fireoff")
	alarm_overlay = image(src.icon, src, "fireoff")
	alarm_overlay.plane = PLANE_LIGHTING
	alarm_overlay.blend_mode = BLEND_ADD
	alarm_overlay.layer = LIGHTING_LAYER_BASE
	alarm_overlay.alpha = 80
	UpdateIcon()

	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggleinput))
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, alarm_frequency)

/obj/machinery/firealarm/disposing()
	STOP_TRACKING
	..()

/obj/machinery/firealarm/update_icon()
	if (status & NOPOWER)
		icon_state = "firep"
		ClearSpecificOverlays("alarm_base_overlay")
		ClearSpecificOverlays("alarm_overlay")
	else
		if (alarm_active)
			alarm_base_overlay.icon_state = "fireon"
			alarm_overlay.icon_state = "fireon"
		else
			alarm_base_overlay.icon_state = "fireoff"
			alarm_overlay.icon_state = "fireoff"
		UpdateOverlays(alarm_base_overlay, "alarm_base_overlay")
		UpdateOverlays(alarm_overlay, "alarm_overlay")

/obj/machinery/firealarm/set_loc(var/newloc)
	..()
	var/area/A = get_area(loc)
	if (A)
		alarm_zone = A.name
		net_id = generate_net_id(src)

/obj/machinery/firealarm/proc/toggleinput(var/datum/mechanicsMessage/inp)
	if(!alarm_active)
		alarm()
	else
		reset()
	return

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			src.alarm(triggered_automatically=TRUE)			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/emp_act()
	..()
	if(prob(50))
		src.alarm()
	return

/obj/machinery/firealarm/attackby(obj/item/W, mob/user)
	if (issnippingtool(W))
		src.detecting = !( src.detecting )
		if (src.detecting)
			user.visible_message(SPAN_ALERT("[user] has reconnected [src]'s detecting unit!"), "You have reconnected [src]'s detecting unit.")
			src.icon_state = "firep"
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			logTheThing(LOG_STATION, null, "[key_name(user)] fixed a fire alarm at ([log_loc(src.loc)])")
		else
			user.visible_message(SPAN_ALERT("[user] has disconnected [src]'s detecting unit!"), "You have disconnected [src]'s detecting unit.")
			src.icon_state = "firep-cut"
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			logTheThing(LOG_STATION, null, "[key_name(user)] deactivated a fire alarm at ([log_loc(src.loc)])")
	else if (!alarm_active)
		src.alarm()
	else
		src.reset()
	src.add_fingerprint(user)
	return

/obj/machinery/firealarm/process()
	if(status & (NOPOWER|BROKEN))
		return
	if(idle_count > 0)
		idle_count--
	..()

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		if (status & NOPOWER)
			var/area/A = get_area(src)
			A.firereset()
		status &= ~NOPOWER
		UpdateIcon()
	else
		SPAWN(rand(0,15))
			status |= NOPOWER
			UpdateIcon()

/obj/machinery/firealarm/attack_hand(mob/user)
	if(user.stat || status & (NOPOWER|BROKEN) || ON_COOLDOWN(src, "toggle", 1 SECOND))
		return

	interact_particle(user,src)

	if (!alarm_active)
		src.alarm()
	else
		idle_count = manual_off_reactivate_idle
		src.reset()

/obj/machinery/firealarm/proc/reset()
	if(!working)
		return

	post_alert(0)
	var/area/A = get_area(loc)
	if(!isarea(A))
		return
	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"alertReset")
	A.firereset()

	if (src.ringlimiter)
		src.ringlimiter = 0

	post_alert(0)
	return

/obj/machinery/firealarm/proc/alarm(triggered_automatically=FALSE)
	if(triggered_automatically && idle_count > 0)
		return

	if(!working)
		return

	if(dont_spam)
		return

	var/area/A = get_area(loc)
	if(!isarea(A))
		return
	if (A.fire) // maybe we should trigger an alarm when there already is one, goddamn
		return

	alarm_active = TRUE

	src.AddComponent(/datum/component/minimap_marker/minimap, MAP_ALERTS, "alarm_fire", name="[get_area(src)] Fire Alarm")
	A.firealert()	//Icon state is set to "fire1" in A.firealert()
	post_alert(1)

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"alertTriggered")
	if (!src.ringlimiter)
		src.ringlimiter = 1
		playsound(src.loc, 'sound/machines/firealarm.ogg', 50, 1)



	src.dont_spam = 1
	SPAWN(5 SECONDS)
		src.dont_spam = 0

	return


/obj/machinery/firealarm/proc/post_alert(var/alarm, var/specific_target)
	var/datum/signal/alert_signal = get_free_signal()
	alert_signal.source = src
	alert_signal.data["address_tag"] = alarm_zone
	alert_signal.data["type"] = "Fire"
	alert_signal.data["netid"] = net_id
	alert_signal.data["sender"] = net_id
	if (specific_target)
		alert_signal.data["address_1"] = specific_target

	if(alarm)
		alert_signal.data["alert"] = "fire"
	else
		alert_signal.data["alert"] = "reset"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, alert_signal)

/// Reply with current status
/obj/machinery/firealarm/proc/reply_status(sender, command)
	var/datum/signal/reply = new
	reply.source = src
	reply.data["address_1"] = sender
	reply.data["command"] = command
	reply.data["device"] = "WNET_FIREALARM"
	reply.data["netid"] = src.net_id
	reply.data["alert"] = src.alarm_active ? "fire" : "reset"
	reply.data["zone"] = src.alarm_zone
	reply.data["type"] = "Fire"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply)

/obj/machinery/firealarm/receive_signal(datum/signal/signal)
	if(status & NOPOWER)
		return

	var/sender = signal.data["sender"]
	if(!signal || signal.encryption || !sender)
		return

	if (signal.data["address_1"] == src.net_id)
		switch (lowertext(signal.data["command"]))
			if ("status")
				src.reply_status(sender, "status_reply")
			if ("trigger")
				src.alarm()
			if ("reset")
				src.reset()

	else if(signal.data["address_1"] == "ping")
		SPAWN(0.5 SECONDS)
			src.reply_status(sender, "ping_reply")

SET_UP_DIRECTIONALS(/obj/machinery/firealarm, OFFSETS_FIREALARM)
