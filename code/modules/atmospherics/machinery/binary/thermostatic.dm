/obj/machinery/atmospherics/binary/thermostatic_gate
	icon = 'icons/obj/atmospherics/thermostatic.dmi'
	icon_state = "off-map"
	name = "thermostatic gate"
	desc = "A gate that automatically opens and closes when the blue side reaches the set temperatures."
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/open = FALSE
	var/open_temp = T100C
	var/close_temp = T20C
	var/inverted = FALSE
	var/datum/pump_ui/ui
	/// Radio frequency to operate on.
	var/frequency = FREQ_FREE
	/// Radio ID we respond to for multicast.
	var/id = null
	/// Radio ID that refers to specifically us.
	var/net_id = null
	HELP_MESSAGE_OVERRIDE({"Above the open temperature, the gate opens. Below the gate temperature, the gate closes. When inverted, it becomes below the open and above the close.\n
	You can click it with a <b>multitool</b> to open the menu and change the temperatures."})

/obj/machinery/atmospherics/binary/thermostatic_gate/proc/check_temperature()
	if (inverted ? (src.air1.temperature >= src.close_temp) : (src.air1.temperature <= src.close_temp))
		open = FALSE
		src.UpdateIcon()
		logTheThing(LOG_STATION, null, "[log_object(src)] just closed due to hitting [src.close_temp] Kelvin at [log_loc(src)]")

	else if (inverted ? (src.air1.temperature <= src.open_temp) : (src.air1.temperature >= src.open_temp))
		open = TRUE
		src.UpdateIcon()
		logTheThing(LOG_STATION, null, "[log_object(src)] just opened due to hitting [src.open_temp] Kelvin at [log_loc(src)]")

	return open

/obj/machinery/atmospherics/binary/thermostatic_gate/New()
	..()
	if(src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)

/obj/machinery/atmospherics/binary/thermostatic_gate/initialize()
	..()
	src.ui = new/datum/thermostatic_gate_ui(src)

/obj/machinery/atmospherics/binary/thermostatic_gate/update_icon()
	src.icon_state = src.open ? "on" : "off"
	update_pipe_underlay(src.node1, turn(src.dir, 180), "long", FALSE)
	update_pipe_underlay(src.node2, src.dir, "long", FALSE)

/obj/machinery/atmospherics/binary/thermostatic_gate/process()
	..()
	if(!node1 || !node2)
		open = FALSE
		src.UpdateIcon()
		return

	if (!check_temperature())
		return

	var/datum/gas_mixture/temp = src.air1.remove_ratio(1)
	src.air2.merge(temp)
	temp = src.air2.remove_ratio(0.5)
	src.air1.merge(temp)

	network1?.update = TRUE
	network2?.update = TRUE

/obj/machinery/atmospherics/binary/thermostatic_gate/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		src.ui.show_ui(user)


/obj/machinery/atmospherics/binary/thermostatic_gate/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["sender"] = src.net_id
	signal.data["device"] = "ATG"
	signal.data["power"] = src.open ? "open" : "closed"
	signal.data["open_temp"] = src.open_temp
	signal.data["close_temp"] = src.close_temp
	signal.data["inverted"] = src.inverted

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/binary/thermostatic_gate/receive_signal(datum/signal/signal)
	if(!((signal.data["tag"] && (signal.data["tag"] == src.id)) || (signal.data["address_1"] == src.net_id)))
		if(signal.data["command"] != "broadcast_status")
			return FALSE

	switch(signal.data["command"])
		if("broadcast_status")
			SPAWN(0.5 SECONDS)
				broadcast_status()

		if("set_open_temp")
			var/number = text2num_safe(signal.data["parameter"])

			src.open_temp = max(number, 0)
			. = TRUE

		if("set_close_temp")
			var/number = text2num_safe(signal.data["parameter"])

			src.close_temp = max(number, 0)
			. = TRUE

		if("set_inverted")
			src.inverted = TRUE
			. = TRUE

		if("remove_inverted")
			src.inverted = TRUE
			. = TRUE

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									broadcast_status - Broadcasts info about self. \
									set_open_temp (parameter: Number) - Sets opening temperature in kelvin to parameter. Minimum 0 Kelvin. \
									set_close_temp (parameter: Number) - Sets closing temperature in kelvin to parameter. Minimum 0 Kelvin. \
									set_inverted - Inverts the gate. \
									remove_inverted - Un-inverts the gate."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)


	if(.)
		src.UpdateIcon()
		var/turf/intact = get_turf(src)
		intact = intact.intact
		var/hide_pipe = CHECKHIDEPIPE(src)
		FLICK("[hide_pipe ? "h" : "" ]alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)

/datum/thermostatic_gate_ui
	var/obj/machinery/atmospherics/binary/thermostatic_gate/our_gate

/datum/thermostatic_gate_ui/New(our_gate)
	..()
	src.our_gate = our_gate

/datum/thermostatic_gate_ui/Topic(href, href_list)
	if(!can_act(usr))
		return
	if(href_list["ui_target"] == "gate_ui")
		switch(href_list["ui_action"])
			if("set_open")
				var/value_to_set = input(usr, "Opening Temperature (Minimum 0K):", "Enter new value", src.our_gate.open_temp) as num
				if(isnum_safe(value_to_set))
					src.our_gate.open_temp = max(value_to_set, 0)
					logTheThing(LOG_STATION, usr, "has set [src.our_gate] opening temperature to [src.our_gate.open_temp] at [log_loc(src.our_gate)]")

			if("set_close")
				var/value_to_set = input(usr, "Closing Temperature (Minimum 0K):", "Enter new value", src.our_gate.close_temp) as num
				if(isnum_safe(value_to_set))
					src.our_gate.close_temp = max(value_to_set, 0)
					logTheThing(LOG_STATION, usr, "has set [src.our_gate] closing temperature to [src.our_gate.close_temp] at [log_loc(src.our_gate)]")

			if("toggle_direction")
				src.our_gate.inverted = !src.our_gate.inverted
				logTheThing(LOG_STATION, usr, "has set [src.our_gate] inversion status to [src.our_gate.inverted] at [log_loc(src.our_gate)]")

	src.show_ui(usr)

/datum/thermostatic_gate_ui/proc/show_ui(mob/user)
	user.client?.tooltips?.show(
		TOOLTIP_PINNED, src.our_gate,
		title = src.our_gate.name,
		content = alist(
			"file" = "thermostatic_gate.eta",
			"data" = alist(
				"src" = "\ref[src]",
				"is_on" = src.our_gate.open,
				"close_temp" = src.our_gate.close_temp,
				"open_temp" = src.our_gate.open_temp,
				"inverted" = src.our_gate.inverted
			)
		),
	)
