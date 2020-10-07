/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output
//
Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

obj/machinery/atmospherics/binary/pump
	icon = 'icons/obj/atmospherics/pump.dmi'
	icon_state = "intact_off"

	name = "Gas pump"
	desc = "A pump"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE

	var/datum/pump_ui/ui

	attack_hand(mob/user)
		//on = !on
		update_icon()

	update_icon()
		if(node1&&node2)
			icon_state = "intact_[on?("on"):("off")]"
		else
			if(node1)
				icon_state = "exposed_1_off"
			else if(node2)
				icon_state = "exposed_2_off"
			else
				icon_state = "exposed_3_off"
			on = 0

		return

	process()
		..()
		if(!on)
			return 0

		var/output_starting_pressure = MIXTURE_PRESSURE(air2)

		if(output_starting_pressure >= target_pressure)
			//No need to pump gas if target is already reached!
			return 1

		//Calculate necessary moles to transfer using PV=nRT
		if((TOTAL_MOLES(air1) > 0) && (air1.temperature>0))
			var/pressure_delta = target_pressure - output_starting_pressure
			var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)
			air2.merge(removed)

			if(network1)
				network1.update = 1

			if(network2)
				network2.update = 1

			use_power((target_pressure) * (0.10)) // cogwerks: adjust the multiplier if needed

		return 1

	//Radio remote control

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			if(frequency)
				radio_connection = radio_controller.add_object(src, "[frequency]")

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.source = src

			signal.data["tag"] = id
			signal.data["device"] = "AGP"
			signal.data["power"] = on ? "on" : "off"
			signal.data["target_output"] = target_pressure

			radio_connection.post_signal(src, signal)

			return 1

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	initialize()
		..()
		if(frequency)
			set_frequency(frequency)
		ui = new/datum/pump_ui/basic_pump_ui(src)

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id))
			return 0

		switch(signal.data["command"])
			if("broadcast_status")
				SPAWN_DBG(0.5 SECONDS) broadcast_status()

			if("power_on")
				on = 1

			if("power_off")
				on = 0

			if("power_toggle")
				on = !on

			if("set_output_pressure")
				var/number = text2num(signal.data["parameter"])
				number = min(max(number, 0), ONE_ATMOSPHERE*50)

				target_pressure = number

		if(signal.data["tag"])
			SPAWN_DBG(0.5 SECONDS) broadcast_status()

		update_icon()

obj/machinery/atmospherics/binary/pump/attackby(obj/item/W as obj, mob/user as mob)
	if(ispulsingtool(W))
		ui.show_ui(user)

datum/pump_ui/basic_pump_ui
	value_name = "Target Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 15000
	incr_sm = 50
	incr_lg = 100
	var/obj/machinery/atmospherics/binary/pump/our_pump

datum/pump_ui/basic_pump_ui/New(obj/machinery/atmospherics/binary/pump/our_pump)
	..()
	src.our_pump = our_pump
	pump_name = our_pump.name

datum/pump_ui/basic_pump_ui/set_value(val_to_set)
	our_pump.target_pressure = val_to_set
	our_pump.update_icon()

datum/pump_ui/basic_pump_ui/toggle_power()
	our_pump.on = !our_pump.on
	our_pump.update_icon()

datum/pump_ui/basic_pump_ui/is_on()
	return our_pump.on

datum/pump_ui/basic_pump_ui/get_value()
	return our_pump.target_pressure

datum/pump_ui/basic_pump_ui/get_atom()
	return our_pump
