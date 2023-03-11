#define SIPHONING 0
#define RELEASING 1

// Do not pass external_pressure_bound
#define BOUND_EXTERNAL 1
// Do not pass internal_pressure_bound
#define BOUND_INTERNAL 2
// Do not pass either
#define BOUND_BOTH 3

/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/atmospherics/vent_pump.dmi'
	icon_state = "out"
	name = "Air Vent"
	desc = "A vent used for repressurization. It's probably hooked up to a canister port, somewhere."
	level = 1
	plane = PLANE_FLOOR
	var/on = TRUE
	var/pump_direction = RELEASING
	var/external_pressure_bound = ONE_ATMOSPHERE + 20
	var/internal_pressure_bound = 0
	var/pressure_checks = BOUND_EXTERNAL
	var/frequency = 0
	var/id = null

/obj/machinery/atmospherics/unary/vent_pump/New()
	..()
	if(frequency)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/unary/vent_pump/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/vent_pump/process()
	..()
	if(!loc || !on)
		return FALSE

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = MIXTURE_PRESSURE(environment)

	if(pump_direction) //internal -> external
		var/pressure_delta = 10000

		if(pressure_checks&BOUND_EXTERNAL)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure)) //Do not go above environment_pressure
		if(pressure_checks&BOUND_INTERNAL)
			pressure_delta = min(pressure_delta, (MIXTURE_PRESSURE(air_contents) - internal_pressure_bound))

		if(pressure_delta > 0)
			if(air_contents.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				loc.assume_air(removed)

				if(network)
					network.update = TRUE

	else //external -> internal
		var/pressure_delta = 10000

		if(pressure_checks&BOUND_EXTERNAL)
			pressure_delta = min(pressure_delta, (environment_pressure-external_pressure_bound)) //Do not go below environment_pressure
		if(pressure_checks&BOUND_INTERNAL)
			pressure_delta = min(pressure_delta, (internal_pressure_bound - MIXTURE_PRESSURE(air_contents)))

		if(pressure_delta > 0)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				air_contents.merge(removed)

				if(network)
					network.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/vent_pump/proc/broadcast_status()
	if(!id)
		return FALSE

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = id
	signal.data["device"] = "AVP"
	signal.data["power"] = on?("on"):("off")
	signal.data["direction"] = pump_direction?("release"):("siphon")
	signal.data["checks"] = pressure_checks
	signal.data["internal"] = internal_pressure_bound
	signal.data["external"] = external_pressure_bound

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/unary/vent_pump/initialize()
	..()
	UpdateIcon()

/obj/machinery/atmospherics/unary/vent_pump/receive_signal(datum/signal/signal)
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

		if("purge")
			pressure_checks &= ~BOUND_EXTERNAL
			pump_direction = SIPHONING

		if("end_purge")
			pressure_checks |= BOUND_EXTERNAL
			pump_direction = SIPHONING

		if("stabalize")
			pressure_checks |= BOUND_EXTERNAL
			pump_direction = RELEASING

		if("set_checks")
			var/number = round(text2num_safe(signal.data["parameter"]),1)
			pressure_checks = number

		if("set_internal_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			internal_pressure_bound = number

		if("set_external_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			external_pressure_bound = number

		if("refresh")
			SPAWN(0.5 SECONDS) broadcast_status()


/obj/machinery/atmospherics/unary/vent_pump/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	if(on&&node)
		if(pump_direction)
			icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]out"
		else
			icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]in"
	else
		icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]off"
		on = FALSE

/obj/machinery/atmospherics/unary/vent_pump/security
	name = "Air Vent (Security)"
	frequency = 1274

/obj/machinery/atmospherics/unary/vent_pump/toxlab_chamber_to_tank
	name = "Toxlab Chamber Siphon"
	icon_state = "in"
	pump_direction = SIPHONING
	external_pressure_bound = 0
	internal_pressure_bound = 4000
	pressure_checks = BOUND_INTERNAL

/obj/machinery/atmospherics/unary/vent_pump/high_volume
	name = "High-Volume Air Vent"

/obj/machinery/atmospherics/unary/vent_pump/high_volume/New()
	..()
	air_contents.volume = 1000

/obj/machinery/atmospherics/unary/vent_pump/high_volume/security
	name = "High-Volume Air Vent (Security)"
	frequency = 1274

#undef SIPHONING
#undef RELEASING
#undef BOUND_EXTERNAL
#undef BOUND_INTERNAL
#undef BOUND_BOTH
