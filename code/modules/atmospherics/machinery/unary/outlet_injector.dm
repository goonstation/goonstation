/obj/machinery/atmospherics/unary/outlet_injector
	icon = 'icons/obj/atmospherics/outlet_injector.dmi'
	icon_state = "off"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW //They're supposed to be embedded in the floor.

	name = "Air Injector"
	desc = "Has a valve and pump attached to it"

	var/on = FALSE
	var/injecting = FALSE

	var/volume_rate = 50

	var/frequency = 0
	var/id = null

	level = 1

/obj/machinery/atmospherics/unary/outlet_injector/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/unary/outlet_injector/update_icon()
	if(node)
		if(on)
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
	else
		icon_state = "exposed"
		on = FALSE

/obj/machinery/atmospherics/unary/outlet_injector/process()
	..()
	injecting = FALSE

	if(!on)
		return FALSE

	if(air_contents.temperature > 0)
		var/transfer_moles = (MIXTURE_PRESSURE(air_contents))*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		if(network)
			network.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return FALSE

	injecting = TRUE

	if(air_contents.temperature > 0)
		var/transfer_moles = (MIXTURE_PRESSURE(air_contents))*volume_rate/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		loc.assume_air(removed)

		if(network)
			network.update = TRUE

	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = id
	signal.data["device"] = "AO"
	signal.data["power"] = on
	signal.data["volume_rate"] = volume_rate

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("power_on")
			on = TRUE

		if("power_off")
			on = FALSE

		if("power_toggle")
			on = !on

		if("inject")
			SPAWN(0) inject()

		if("set_volume_rate")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, air_contents.volume)

			volume_rate = number

	if(signal.data["tag"])
		SPAWN(0.5 SECONDS) broadcast_status()
	UpdateIcon()

/obj/machinery/atmospherics/unary/outlet_injector/hide(var/i) //to make the little pipe section invisible, the icon changes.
	if(node)
		if(on)
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
	else
		icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]exposed"
		on = FALSE
