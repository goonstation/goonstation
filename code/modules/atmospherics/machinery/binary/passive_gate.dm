obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//	Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'icons/obj/atmospherics/passive_gate.dmi'
	icon_state = "intact_off"
//
	name = "Passive gate"
	desc = "A one-way air valve that does not require power"

	var/on = 0
	var/target_pressure = ONE_ATMOSPHERE
	var/datum/pump_ui/ui

	initialize()
		..()
		ui = new/datum/pump_ui/passive_gate_ui(src)

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
		var/input_starting_pressure = MIXTURE_PRESSURE(air1)

		if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
			//No need to pump gas if target is already reached or input pressure is too low
			//Need at least 10 KPa difference to overcome friction in the mechanism
			return 1

		//Calculate necessary moles to transfer using PV = nRT
		if((TOTAL_MOLES(air1) > 0) && (air1.temperature>0))
			var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
			//Can not have a pressure delta that would cause output_pressure > input_pressure

			var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)
			air2.merge(removed)

			network1?.update = 1

			if(network2)
				network2.update = 1

obj/machinery/atmospherics/binary/passive_gate/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		ui.show_ui(user)

datum/pump_ui/passive_gate_ui
	value_name = "Release Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 1e31
	incr_sm = 100
	incr_lg = 1000
	var/obj/machinery/atmospherics/binary/passive_gate/our_gate

datum/pump_ui/passive_gate_ui/New(obj/machinery/atmospherics/binary/passive_gate/our_gate)
	..()
	src.our_gate = our_gate
	pump_name = our_gate.name

datum/pump_ui/passive_gate_ui/set_value(val)
	our_gate.target_pressure = val

datum/pump_ui/passive_gate_ui/toggle_power()
	our_gate.on = !our_gate.on
	our_gate.UpdateIcon()

datum/pump_ui/passive_gate_ui/is_on()
	return our_gate.on

datum/pump_ui/passive_gate_ui/get_value()
	return our_gate.target_pressure

datum/pump_ui/passive_gate_ui/get_atom()
	return our_gate
