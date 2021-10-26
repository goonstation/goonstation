obj/machinery/air_sensor
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gsensor1"
	name = "Gas Sensor"
	desc = "A device that detects the composition of the air nearby."

	anchored = 1

	var/id_tag
	var/frequency = 1439

	var/on = 1
	var/output = 3

	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL

	//Flags:
	// 1 for pressure
	// 2 for temperature
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for CO2 concentration
	// 32 for N2 concentration
	// 64 for other shit


	var/datum/radio_frequency/radio_connection

	proc/update_icon()
		icon_state = "gsensor[on]"

	process()
		if(on)
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = air_master.current_cycle

			var/datum/gas_mixture/air_sample = return_air()

			if(output&1)
				signal.data["pressure"] = num2text(round(MIXTURE_PRESSURE(air_sample),0.1),)
			if(output&2)
				signal.data["temperature"] = round(air_sample.temperature,0.1)

			if(output&12)
				var/total_moles = TOTAL_MOLES(air_sample)
				if(total_moles == 0)
					total_moles = 1
				if(output&4)
					signal.data["oxygen"] = round(100*air_sample.oxygen/total_moles)
				if(output&8)
					signal.data["toxins"] = round(100*air_sample.toxins/total_moles)
				if(output&16)
					signal.data["carbon_dioxide"] = round(100*air_sample.carbon_dioxide/total_moles)
				if(output&32)
					signal.data["nitrogen"] = round(100*air_sample.nitrogen/total_moles)
				if(output&64)
					var/tgmoles = 0
					if(length(air_sample.trace_gases))
						for(var/datum/gas/trace_gas as anything in air_sample.trace_gases)
							tgmoles += trace_gas.moles
					signal.data["other"] = round(100*tgmoles/total_moles)



			radio_connection.post_signal(src, signal)


	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		set_frequency(frequency)

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

