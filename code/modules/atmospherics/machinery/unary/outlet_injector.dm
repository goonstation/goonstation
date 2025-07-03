/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/obj/atmospherics/outlet_injector.dmi'
	icon_state = "off-map"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW //They're supposed to be embedded in the floor.
	name = "Air Injector"
	desc = "Has a valve and pump attached to it"

	/// Are we doing anything?
	var/on = FALSE
	/// Are we injecting air at this current moment?
	var/injecting = FALSE
	/// Volume of air to output.
	var/volume_rate = 50
	/// Radio frequency to operate on.
	var/frequency = FREQ_FREE
	/// Radio ID we respond to for multicast.
	var/id = null
	/// Radio ID that refers to specifically us.
	var/net_id = null

	level = UNDERFLOOR

/obj/machinery/atmospherics/unary/outlet_injector/New()
	..()
	if (src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)

/obj/machinery/atmospherics/unary/outlet_injector/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/outlet_injector/process()
	..()
	injecting = FALSE

	if(!on)
		return FALSE

	if(air_contents.temperature > 0)
		var/transfer_moles = (MIXTURE_PRESSURE(air_contents))*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		network?.update = TRUE

	return TRUE

/// Injects gas into the environment once.
/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return FALSE

	injecting = TRUE

	if(air_contents.temperature > 0)
		var/transfer_moles = (MIXTURE_PRESSURE(air_contents))*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		network?.update = TRUE

	FLICK("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["sender"] = src.net_id
	signal.data["device"] = "AO"
	signal.data["power"] = src.on
	signal.data["volume_rate"] = src.volume_rate

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!((signal.data["tag"] && (signal.data["tag"] == src.id)) || (signal.data["address_1"] == src.net_id)))
		if(signal.data["command"] != "broadcast_status")
			return FALSE

	switch(signal.data["command"])
		if("power_on")
			src.on = TRUE
			. = TRUE

		if("power_off")
			src.on = FALSE
			. = TRUE

		if("power_toggle")
			src.on = !on
			. = TRUE

		if("inject")
			SPAWN(0)
				src.inject()
			. = TRUE

		if("set_volume_rate")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, air_contents.volume)

			src.volume_rate = number
			. = TRUE

		if("broadcast_status")
			SPAWN(0.5 SECONDS)
				broadcast_status()

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									broadcast_status - Broadcasts info about self. \
									power_on - Turns on injector. \
									power_off - Turns off injector. \
									power_toggle - Toggles injector. \
									inject - Injects gas into environment. \
									set_volume_rate (parameter: Number) - Sets rate in liters to parameter. Max at [src.air_contents.volume] L."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)

	if(.)
		src.UpdateIcon()
		FLICK("alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)

/obj/machinery/atmospherics/unary/outlet_injector/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	if (!node)
		src.on = FALSE
	src.icon_state = src.on ? "on" : "off"
	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, hide_pipe)

/obj/machinery/atmospherics/unary/outlet_injector/active
	icon_state = "on-map"
	on = TRUE

/obj/machinery/atmospherics/unary/outlet_injector/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/outlet_injector/overfloor/active
	icon_state = "on-map"
	on = TRUE
