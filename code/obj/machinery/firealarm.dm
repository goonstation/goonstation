//
// Firealarm
//

/obj/machinery/firealarm
	name = "Fire Alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	plane = PLANE_NOSHADOW_ABOVE
	deconstruct_flags = DECON_WIRECUTTERS | DECON_MULTITOOL
	machine_registry_idx = MACHINES_FIREALARMS
	var/alarm_frequency = "1437"
	var/detecting = 1.0
	var/working = 1.0
	var/lockdownbyai = 0
	anchored = 1.0
	var/alarm_zone
	var/net_id
	var/ringlimiter = 0
	var/dont_spam = 0
	var/datum/radio_frequency/frequency
	var/static/manual_off_reactivate_idle = 8 //how many machine loop ticks to idle after being manually switched off
	var/idle_count = 0
	text = ""

	desc = "A fire sensor and alarm system. When it detects fire or is manually activated, it closes all firelocks in the area to minimize the spread of fire."

/obj/machinery/firealarm/New()
	..()
	if(!alarm_zone)
		var/area/A = get_area(loc)
		alarm_zone = A.name

	if(!net_id)
		net_id = generate_net_id(src)

	AddComponent(/datum/component/mechanics_holder)
	SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggleinput")
	SPAWN_DBG (10)
		frequency = radio_controller.return_frequency(alarm_frequency)

/obj/machinery/firealarm/disposing()
		radio_controller.remove_object(src, alarm_frequency)
		..()

/obj/machinery/firealarm/set_loc(var/newloc)
	..()
	var/area/A = get_area(loc)
	if (A)
		alarm_zone = A.name
		net_id = generate_net_id(src)

/obj/machinery/firealarm/proc/toggleinput(var/datum/mechanicsMessage/inp)
	if(src.icon_state == "fire0")
		alarm()
	else
		reset()
	return

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/emp_act()
	..()
	if(prob(50))
		src.alarm()
	return

/obj/machinery/firealarm/attackby(obj/item/W as obj, mob/user as mob)
	if (issnippingtool(W))
		src.detecting = !( src.detecting )
		if (src.detecting)
			user.visible_message("<span class='alert'>[user] has reconnected [src]'s detecting unit!</span>", "You have reconnected [src]'s detecting unit.")
		else
			user.visible_message("<span class='alert'>[user] has disconnected [src]'s detecting unit!</span>", "You have disconnected [src]'s detecting unit.")
	else if (src.icon_state == "fire0")
		src.alarm()
	else
		src.reset()
	src.add_fingerprint(user)
	return

/obj/machinery/firealarm/process()
	if(status & (NOPOWER|BROKEN))
		return

	use_power(10, ENVIRON)


/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
		icon_state = "fire0"
	else
		SPAWN_DBG(rand(0,15))
			status |= NOPOWER
			icon_state = "firep"

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || status & (NOPOWER|BROKEN))
		return

	interact_particle(user,src)

	if (src.icon_state == "fire0")
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
	A.firereset()	//Icon state is set to "fire0" in A.firereset()

	if (src.ringlimiter)
		src.ringlimiter = 0

	post_alert(0)
	return

/obj/machinery/firealarm/proc/alarm()
	if(!working)
		return

	if(dont_spam)
		return

	var/area/A = get_area(loc)
	if(!isarea(A))
		return
	if (A.fire) // maybe we should trigger an alarm when there already is one, goddamn
		return

	A.firealert()	//Icon state is set to "fire1" in A.firealert()
	post_alert(1)

	SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"alertTriggered")
	if (!src.ringlimiter)
		src.ringlimiter = 1
		playsound(src.loc, "sound/machines/firealarm.ogg", 50, 1)



	src.dont_spam = 1
	SPAWN_DBG(5 SECONDS)
	if(src)
		src.dont_spam = 0

	return


/obj/machinery/firealarm/proc/post_alert(var/alarm, var/specific_target)
//	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)

	LAGCHECK(LAG_LOW)

	if(!frequency) return

	var/datum/signal/alert_signal = get_free_signal()
	alert_signal.source = src
	alert_signal.transmission_method = TRANSMISSION_RADIO
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Fire"
	alert_signal.data["netid"] = net_id
	alert_signal.data["sender"] = net_id
	if (specific_target)
		alert_signal.data["address_1"] = specific_target

	if(alarm)
		alert_signal.data["alert"] = "fire"
	else
		alert_signal.data["alert"] = "reset"

	frequency.post_signal(src, alert_signal)

/obj/machinery/firealarm/receive_signal(datum/signal/signal)
	if(status & NOPOWER || !src.frequency)
		return

	var/sender = signal.data["sender"]
	if(!signal || signal.encryption || !sender)
		return

	if (signal.data["address_1"] == src.net_id)
		switch (lowertext(signal.data["command"]))
			if ("status")
				post_alert(src.icon_state == "fire0", sender)
			if ("trigger")
				src.alarm()
			if ("reset")
				src.reset()


	else if(signal.data["address_1"] == "ping")
		var/datum/signal/reply = new
		reply.source = src
		reply.transmission_method = TRANSMISSION_RADIO
		reply.data["address_1"] = sender
		reply.data["command"] = "ping_reply"
		reply.data["device"] = "PNET_FIREALARM"
		reply.data["netid"] = src.net_id
		reply.data["alert"] = src.icon_state == "fire0" ? "reset" : "fire"
		reply.data["zone"] = alarm_zone
		reply.data["type"] = "Fire"
		SPAWN_DBG(0.5 SECONDS)
			src.frequency.post_signal(src, reply)
		return

	return
