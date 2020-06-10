/obj/machinery/atmospherics/unary/vent_pump
	icon = 'icons/obj/atmospherics/vent_pump.dmi'
	icon_state = "out"
	name = "Air Vent"
	desc = "Has a valve and pump attached to it"
	level = 1
	plane = PLANE_FLOOR
	var/on = 1
	var/pump_direction = 1 //0 = siphoning, 1 = releasing
	var/external_pressure_bound = ONE_ATMOSPHERE + 20
	var/internal_pressure_bound = 0
	var/pressure_checks = 1
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	security
		name = "Air Vent (Security)"
		frequency = 1274

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	toxlab_chamber_to_tank
		name = "Toxlab Chamber Siphon"
		icon_state = "in"
		pump_direction = 0
		external_pressure_bound = 0
		internal_pressure_bound = 4000
		pressure_checks = 2

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	high_volume
		name = "High-Volume Air Vent"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

		security
			name = "High-Volume Air Vent (Security)"
			frequency = 1274

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST

		New()
			..()

			air_contents.volume = 1000

	update_icon()
		if(on&&node)
			if(pump_direction)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0

		return

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

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, "[frequency]")

		broadcast_status()
			if(!radio_connection || !id)
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

			radio_connection.post_signal(src, signal)

			return 1

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)
		update_icon()

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id))
			return 0

		switch(signal.data["command"])
			if("power_on")
				on = 1

			if("power_off")
				on = 0

			if("power_toggle")
				on = !on

			if("set_direction")
				var/number = text2num(signal.data["parameter"])
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
				var/number = round(text2num(signal.data["parameter"]),1)
				pressure_checks = number

			if("set_internal_pressure")
				var/number = text2num(signal.data["parameter"])
				number = min(max(number, 0), ONE_ATMOSPHERE*50)

				internal_pressure_bound = number

			if("set_external_pressure")
				var/number = text2num(signal.data["parameter"])
				number = min(max(number, 0), ONE_ATMOSPHERE*50)

				external_pressure_bound = number

			if("refresh")
				SPAWN_DBG(0.5 SECONDS) broadcast_status()


	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(pump_direction)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]out"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return
