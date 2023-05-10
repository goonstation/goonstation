/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/atmospherics/vent_pump.dmi'
	icon_state = "out"
	name = "Air Vent"
	desc = "A vent used for repressurization. It's probably hooked up to a canister port, somewhere."
	level = 1
	plane = PLANE_FLOOR
	var/on = TRUE
	var/pump_direction = 1 //0 = siphoning, 1 = releasing
	var/external_pressure_bound = ONE_ATMOSPHERE + 20
	var/internal_pressure_bound = 0
	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	security
		name = "Air Vent (Security)"
		frequency = 1274

	toxlab_chamber_to_tank
		name = "Toxlab Chamber Siphon"
		icon_state = "in"
		pump_direction = 0
		external_pressure_bound = 0
		internal_pressure_bound = 4000
		pressure_checks = 2

	high_volume
		name = "High-Volume Air Vent"

		security
			name = "High-Volume Air Vent (Security)"
			frequency = 1274

		New()
			..()

			air_contents.volume = 1000

	New()
		..()
		if(frequency)
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

	update_icon()
		var/turf/T = get_turf(src)
		src.hide(T.intact)

	process()
		..()
		if(!loc || !on)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()
		var/environment_pressure = MIXTURE_PRESSURE(environment)

		if(pump_direction) //internal -> external
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure)) //Do not go above environment_pressure
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (MIXTURE_PRESSURE(air_contents) - internal_pressure_bound))

			if(pressure_delta > 0)
				if(air_contents.temperature > 0)
					var/transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

					loc.assume_air(removed)

					if(network)
						network.update = 1

		else //external -> internal
			var/pressure_delta = 10000

			if(pressure_checks&1)
				pressure_delta = min(pressure_delta, (environment_pressure-external_pressure_bound)) //Do not go below environment_pressure
			if(pressure_checks&2)
				pressure_delta = min(pressure_delta, (internal_pressure_bound - MIXTURE_PRESSURE(air_contents)))

			if(pressure_delta > 0)
				if(environment.temperature > 0)
					var/transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

					var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

					air_contents.merge(removed)

					if(network)
						network.update = 1

		return 1

	proc/broadcast_status()
		if(!id)
			return 0

		var/datum/signal/signal = get_free_signal()
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data["tag"] = id
		signal.data["device"] = "AVP"
		signal.data["power"] = on?("on"):("off")
		signal.data["direction"] = pump_direction?("release"):("siphon")
		signal.data["checks"] = pressure_checks
		signal.data["internal"] = internal_pressure_bound
		signal.data["external"] = external_pressure_bound

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

		return 1

	var/frequency = 0
	var/id = null

	initialize()
		..()
		UpdateIcon()

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id))
			return 0

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
					pump_direction = 1
				else
					pump_direction = 0

			if("purge")
				pressure_checks &= ~1
				pump_direction = 0

			if("end_purge")
				pressure_checks |= 1
				pump_direction = 0

			if("stabalize")
				pressure_checks |= 1
				pump_direction = 1

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


	hide(var/intact) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(pump_direction)
				icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]out"
			else
				icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]in"
		else
			icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]off"
			on = FALSE
