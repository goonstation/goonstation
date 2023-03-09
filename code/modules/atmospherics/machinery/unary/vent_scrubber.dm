/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "on"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/id = null
	var/frequency = FREQ_AIR_ALARM_CONTROL

	var/on = TRUE
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	#define _DEF_SCRUBBER_VAR(GAS, ...) var/scrub_##GAS = 1;
	APPLY_TO_GASES(_DEF_SCRUBBER_VAR)
	#undef _DEF_SCRUBBER_VAR

	var/volume_rate = 120

	New()
		..()
		if(frequency)
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

	initialize()
		..()
		UpdateIcon()

	update_icon()
		var/turf/T = get_turf(src)
		src.hide(T.intact)

	process()
		..()
		if(!on)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			var/moles = TOTAL_MOLES(environment)
			if(moles)
				var/transfer_moles = min(1, volume_rate/environment.volume) * moles

				//Take a gas sample
				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				//Filter it
				var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
				filtered_out.temperature = removed.temperature

				#define _FILTER_OUT_GAS(GAS, ...) \
					if(scrub_##GAS) { \
						filtered_out.GAS = removed.GAS; \
						removed.GAS = 0; \
					}
				APPLY_TO_GASES(_FILTER_OUT_GAS)
				#undef _FILTER_OUT_GAS

				if(length(removed.trace_gases))
					var/datum/gas/trace_gas = removed.get_trace_gas_by_type(/datum/gas/oxygen_agent_b)
					if(trace_gas)
						var/datum/gas/filtered_gas = filtered_out.get_or_add_trace_gas_by_type(/datum/gas/oxygen_agent_b)
						filtered_gas.moles = trace_gas.moles
						removed.remove_trace_gas(trace_gas)

				//Remix the resulting gases
				air_contents.merge(filtered_out)

				loc.assume_air(removed)

				if(network)
					network.update = 1

		else //Just siphoning all air
			var/transfer_moles = TOTAL_MOLES(environment)*(volume_rate/environment.volume)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

			air_contents.merge(removed)

			if(network)
				network.update = 1

		return 1

	hide(var/intact) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(scrubbing)
				icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]on"
			else
				icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]in"
		else
			icon_state = "[intact && istype(loc, /turf/simulated) && level == 1 ? "h" : "" ]off"
			on = FALSE

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

			if("set_siphon")
				scrubbing = 0

			if("set_scrubbing")
				scrubbing = 1

		UpdateIcon()

/obj/machinery/atmospherics/unary/vent_scrubber/breathable
	scrub_oxygen = 0
	scrub_nitrogen = 0
