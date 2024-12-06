#define SIPHONING 0
#define RELEASING 1

// Do not pass external_pressure_bound
#define BOUND_EXTERNAL 1
// Do not pass internal_pressure_bound
#define BOUND_INTERNAL 2
// Do not pass either bounds
#define BOUND_BOTH 3

/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/atmospherics/vent_pump.dmi'
	icon_state = "out-map"
	name = "Air Vent"
	desc = "A vent used for repressurization. It's probably hooked up to a canister port, somewhere."
	level = UNDERFLOOR
	plane = PLANE_FLOOR
	var/on = TRUE
	/// Are we pumping air in or out?
	var/pump_direction = RELEASING
	/// Max pressure outside when releasing, and min pressure outside when siphoning.
	var/external_pressure_bound = ONE_ATMOSPHERE + 20
	/// Min pressure inside when releasing, and max pressure inside when siphoning.
	var/internal_pressure_bound = 0
	/// Are we applying the external bound, internal bound, or both?
	var/pressure_checks = BOUND_EXTERNAL
	/// Radio frequency to operate on.
	var/frequency = FREQ_FREE
	/// Radio ID we respond to for multicast.
	var/id = null
	/// Radio ID that refers to us only.
	var/net_id = null

/obj/machinery/atmospherics/unary/vent_pump/New()
	..()
	if(src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

/obj/machinery/atmospherics/unary/vent_pump/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/vent_pump/process()
	..()
	if(!loc || !on)
		return FALSE

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = MIXTURE_PRESSURE(environment)

	if(pump_direction) //internal -> external, RELEASING
		var/pressure_delta = 10000

		if(HAS_FLAG(pressure_checks, BOUND_EXTERNAL))
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure)) //Do not go above environment_pressure
		if(HAS_FLAG(pressure_checks, BOUND_INTERNAL))
			pressure_delta = min(pressure_delta, (MIXTURE_PRESSURE(air_contents) - internal_pressure_bound))

		if(pressure_delta > 0)
			if(air_contents.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				loc.assume_air(removed)

				network?.update = TRUE

	else //external -> internal, SIPHONING
		var/pressure_delta = 10000

		if(HAS_FLAG(pressure_checks, BOUND_EXTERNAL))
			pressure_delta = min(pressure_delta, (environment_pressure-external_pressure_bound)) //Do not go below environment_pressure
		if(HAS_FLAG(pressure_checks, BOUND_INTERNAL))
			pressure_delta = min(pressure_delta, (internal_pressure_bound - MIXTURE_PRESSURE(air_contents)))

		if(pressure_delta > 0)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				air_contents.merge(removed)

				network?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["sender"] = src.net_id
	signal.data["device"] = "AVP"
	signal.data["power"] = src.on ? "on": "off"
	signal.data["direction"] = src.pump_direction ? "release" : "siphon"
	signal.data["checks"] = src.pressure_checks
	signal.data["internal"] = src.internal_pressure_bound
	signal.data["external"] = src.external_pressure_bound

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/unary/vent_pump/initialize()
	..()
	UpdateIcon()

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
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
			src.on = !src.on
			. = TRUE

		if("set_direction")
			var/number = text2num_safe(signal.data["parameter"])
			src.pump_direction = number > 0.5 ? RELEASING : SIPHONING
			. = TRUE

		if("purge")
			REMOVE_FLAG(pressure_checks, BOUND_EXTERNAL)
			src.pump_direction = SIPHONING
			. = TRUE

		if("end_purge")
			ADD_FLAG(pressure_checks, BOUND_EXTERNAL)
			src.pump_direction = SIPHONING
			. = TRUE

		if("stabilise")
			ADD_FLAG(pressure_checks, BOUND_EXTERNAL)
			src.pump_direction = RELEASING
			. = TRUE

		if("set_checks")
			var/number = clamp(round(text2num_safe(signal.data["parameter"]),1), 0, 3)
			src.pressure_checks = number
			. = TRUE

		if("set_internal_pressure")
			var/number = text2num_safe(signal.data["parameter"])

			src.internal_pressure_bound = clamp(number, 0, ONE_ATMOSPHERE*50)
			. = TRUE

		if("set_external_pressure")
			var/number = text2num_safe(signal.data["parameter"])

			src.external_pressure_bound = clamp(number, 0, ONE_ATMOSPHERE*50)
			. = TRUE

		if("broadcast_status")
			SPAWN(0.5 SECONDS) broadcast_status()

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									broadcast_status - Broadcasts info about self. \
									power_on - Turns on vent. \
									power_off - Turns off vent. \
									power_toggle - Toggles vent. \
									set_direction (parameter: Number) - Switches between siphoning (parameter<=0.5) and releasing (parameter>0.5). \
									purge - Switches to siphoning and removes external bounds check. \
									end_purge - Switches to siphoning and adds external bounds check. \
									stabilise - Switches to releasing and adds external bounds check. \
									set_checks (parameter: Bitflag) - Controls bounds check. [BOUND_EXTERNAL] is external bounds. [BOUND_INTERNAL] is internal bouds. \
									set_internal_pressure (parameter: Number) - Sets internal bound to parameter. Max at [ONE_ATMOSPHERE*50]. \
									set_external_pressure (parameter: Number) - Sets external bound to parameter. Max at [ONE_ATMOSPHERE*50]."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)

	if(.)
		src.UpdateIcon()
		var/turf/intact = get_turf(src)
		intact = intact.intact
		var/hide_pipe = CHECKHIDEPIPE(src)
		flick("[hide_pipe ? "h" : "" ]alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)


/obj/machinery/atmospherics/unary/vent_pump/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	if(on&&node)
		if(pump_direction)
			icon_state = "[hide_pipe ? "h" : "" ]out"
		else
			icon_state = "[hide_pipe ? "h" : "" ]in"
	else
		icon_state = "[hide_pipe ? "h" : "" ]off"
		on = FALSE

	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, hide_pipe)

/obj/machinery/atmospherics/unary/vent_pump/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_pump/siphoning
	icon_state = "in-map"
	pump_direction = SIPHONING
	external_pressure_bound = 0

/obj/machinery/atmospherics/unary/vent_pump/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/vent_pump/overfloor/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_pump/overfloor/siphoning
	icon_state = "in-map"
	pump_direction = SIPHONING
	external_pressure_bound = 0

/obj/machinery/atmospherics/unary/vent_pump/security
	name = "Air Vent (Security)"
	frequency = 1274

/obj/machinery/atmospherics/unary/vent_pump/security/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/vent_pump/toxlab_chamber_to_tank
	name = "Toxlab Chamber Siphon"
	icon_state = "in-map"
	pump_direction = 0
	external_pressure_bound = 0
	internal_pressure_bound = 4000
	pressure_checks = BOUND_INTERNAL

/obj/machinery/atmospherics/unary/vent_pump/toxlab_chamber_to_tank/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "High-Volume Air Vent"

/obj/machinery/atmospherics/unary/vent_pump/high_volume/New()
	..()

	air_contents.volume = 1000

/obj/machinery/atmospherics/unary/vent_pump/high_volume/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_pump/high_volume/siphoning
	icon_state = "in-map"
	pump_direction = SIPHONING
	external_pressure_bound = 0

/obj/machinery/atmospherics/unary/vent_pump/high_volume/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/vent_pump/high_volume/overfloor/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_pump/high_volume/overfloor/siphoning
	icon_state = "in-map"
	pump_direction = SIPHONING
	external_pressure_bound = 0

/obj/machinery/atmospherics/unary/vent_pump/high_volume/security
	name = "High-Volume Air Vent (Security)"
	frequency = 1274

/obj/machinery/atmospherics/unary/vent_pump/high_volume/security/overfloor
	level = OVERFLOOR

#undef SIPHONING
#undef RELEASING
#undef BOUND_EXTERNAL
#undef BOUND_INTERNAL
#undef BOUND_BOTH
