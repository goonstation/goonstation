/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "on"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/id = null
	var/frequency = "1439"
	var/datum/radio_frequency/radio_connection

	var/on = 1
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	#define _DEF_SCRUBBER_VAR(GAS, ...) var/scrub_##GAS = 1;
	APPLY_TO_GASES(_DEF_SCRUBBER_VAR)
	#undef _DEF_SCRUBBER_VAR

	var/volume_rate = 120
//
	initialize()
		..()
		if(frequency)
			set_frequency(frequency)
		update_icon()

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	proc/set_frequency(new_frequency)
		radio_controller.remove_object(src, "[frequency]")
		frequency = new_frequency
		if(frequency)
			radio_connection = radio_controller.add_object(src, "[frequency]")

	update_icon()
		if(on&&node)
			if(scrubbing)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0

		return

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
				var/datum/gas_mixture/filtered_out = unpool(/datum/gas_mixture)
				filtered_out.temperature = removed.temperature

				#define _FILTER_OUT_GAS(GAS, ...) \
					if(scrub_##GAS) { \
						filtered_out.GAS = removed.GAS; \
						removed.GAS = 0; \
					}
				APPLY_TO_GASES(_FILTER_OUT_GAS)
				#undef _FILTER_OUT_GAS

				if(length(removed.trace_gases))
					for(var/G in removed.trace_gases)
						var/datum/gas/trace_gas = G
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							if(!removed.trace_gases.len)
								removed.trace_gases = null
							if(!filtered_out.trace_gases)
								filtered_out.trace_gases = list()
							filtered_out.trace_gases += trace_gas

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

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(scrubbing)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return

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

			if("set_siphon")
				scrubbing = 0

			if("set_scrubbing")
				scrubbing = 1

		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/breathable
	scrub_oxygen = 0
	scrub_nitrogen = 0
