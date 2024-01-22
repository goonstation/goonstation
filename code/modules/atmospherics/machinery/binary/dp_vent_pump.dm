#define SIPHONING 0
#define RELEASING 1

// Do not pass external_pressure_bound
#define BOUND_EXTERNAL (1<<0)
// Do not pass input_pressure_min
#define BOUND_INPUT (1<<1)
// Do not pass output_pressure_max
#define BOUND_OUTPUT (1<<2)

/obj/machinery/atmospherics/binary/dp_vent_pump
	name = "Dual Port Air Vent"
	desc = "Has a valve and pump attached to it. There are two ports."
	icon = 'icons/obj/atmospherics/dp_vent_pump.dmi'
	icon_state = "off-map"

	level = 1

	var/on = FALSE
	/// Takes gas from the environment
	var/pump_direction = RELEASING
	/// Max pressure for the environment when releasing, and minimum pressure when siphoning.
	var/external_pressure_bound = ONE_ATMOSPHERE
	/// The minimum pressure to keep our input at.
	var/input_pressure_min = 0
	/// The maximum pressure to keep our output at.
	var/output_pressure_max = 0
	var/frequency = 0
	var/id = null
	/// What bounds to check for.
	var/pressure_checks = BOUND_EXTERNAL

/obj/machinery/atmospherics/binary/dp_vent_pump/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/binary/dp_vent_pump/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/binary/dp_vent_pump/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	if(src.on && src.node1 && src.node2)
		if(pump_direction)
			icon_state = "[hide_pipe ? "h" : "" ]out"
		else
			icon_state = "[hide_pipe ? "h" : "" ]in"
	else
		icon_state = "[hide_pipe ? "h" : "" ]off"
		on = FALSE

	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, 180), "medium", issimplepipe(src.node1) ?  src.node1.color : null, hide_pipe)
	SET_PIPE_UNDERLAY(src.node2, src.dir, "medium", issimplepipe(src.node2) ?  src.node2.color : null, hide_pipe)

/obj/machinery/atmospherics/binary/dp_vent_pump/process()
	..()

	if(!on)
		return FALSE

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = MIXTURE_PRESSURE(environment)
	ASSERT(src.air1.temperature >= 0)
	ASSERT(environment.temperature >= 0)

	if(pump_direction) //input -> external
		var/pressure_delta = 10000

		if(pressure_checks&BOUND_EXTERNAL)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&BOUND_INPUT)
			pressure_delta = min(pressure_delta, (MIXTURE_PRESSURE(air1) - input_pressure_min))

		if(pressure_delta > 0)
			var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = air1.remove(transfer_moles)

			loc.assume_air(removed)

			network1?.update = TRUE

	else //external -> output
		var/pressure_delta = 10000

		if(pressure_checks&BOUND_EXTERNAL)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&BOUND_OUTPUT)
			pressure_delta = min(pressure_delta, (output_pressure_max - MIXTURE_PRESSURE(air2)))

		if(pressure_delta > 0)
			var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

			air2.merge(removed)

			network2?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = id
	signal.data["device"] = "ADVP"
	signal.data["power"] = on?("on"):("off")
	signal.data["direction"] = pump_direction?("release"):("siphon")
	signal.data["checks"] = pressure_checks
	signal.data["input"] = input_pressure_min
	signal.data["output"] = output_pressure_max
	signal.data["external"] = external_pressure_bound

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("power_on")
			on = TRUE

		if("power_off")
			on = FALSE

		if("power_toggle")
			on = !on

		if("set_direction")
			var/number = text2num_safe(signal.data["parameter"])
			if(number > 0.5)
				pump_direction = RELEASING
			else
				pump_direction = SIPHONING

		if("set_checks")
			var/number = round(text2num_safe(signal.data["parameter"]),1)
			pressure_checks = number

		if("purge")
			pressure_checks &= ~BOUND_EXTERNAL
			pump_direction = SIPHONING

		if("stabalize")
			pressure_checks |= BOUND_EXTERNAL
			pump_direction = RELEASING

		if("set_input_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			input_pressure_min = number

		if("set_output_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			output_pressure_max = number

		if("set_external_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			external_pressure_bound = number

	if(signal.data["tag"])
		SPAWN(0.5 SECONDS) broadcast_status()
	UpdateIcon()

/obj/machinery/atmospherics/binary/dp_vent_pump/releasing
	icon_state = "out-map"
	on = TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/siphoning
	icon_state = "in-map"
	on = TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume
	name = "Large Dual Port Air Vent"

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/New()
	..()

	air1.volume = 1000
	air2.volume = 1000

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/releasing
	icon_state = "out-map"
	on = TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/siphoning
	icon_state = "in-map"
	on = TRUE

#undef SIPHONING
#undef RELEASING
#undef BOUND_EXTERNAL
#undef BOUND_INPUT
#undef BOUND_OUTPUT
