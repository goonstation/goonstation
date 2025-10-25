/obj/machinery/atmospherics/binary/passive_gate
	//Tries to achieve target pressure at output (like a normal pump) except
	//Uses no power but can not transfer gases from a low pressure area to a high pressure area
	icon = 'icons/obj/atmospherics/passive_gate.dmi'
	icon_state = "off-map"
	name = "Passive gate"
	desc = "A one-way air valve that does not require power"

	var/on = FALSE
	var/target_pressure = ONE_ATMOSPHERE
	var/datum/pump_ui/ui
	HELP_MESSAGE_OVERRIDE({"You can click it with a <b>multitool</b> to open the menu and turn it on or off or change the pressure."})

/obj/machinery/atmospherics/binary/passive_gate/initialize()
	..()
	src.ui = new/datum/pump_ui/passive_gate_ui(src)

/obj/machinery/atmospherics/binary/passive_gate/get_desc(dist, mob/user)
	. = ..()
	if(src.on)
		. += "\nIt is currently set to release pressure at [src.target_pressure] kPa."
	else
		. += "\nIt is currently turned off."

/obj/machinery/atmospherics/binary/passive_gate/update_icon()
	if(!(node1&&node2))
		src.on = FALSE

	src.icon_state = src.on ? "on" : "off"
	update_pipe_underlay(src.node1, turn(src.dir, 180), "long", FALSE)
	update_pipe_underlay(src.node2, src.dir, "long", FALSE)

/obj/machinery/atmospherics/binary/passive_gate/process()
	..()
	if(!on)
		return FALSE

	var/output_starting_pressure = MIXTURE_PRESSURE(air2)
	var/input_starting_pressure = MIXTURE_PRESSURE(air1)

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return TRUE

	ASSERT(src.air1.temperature >= 0)
	ASSERT(src.air2.temperature >= 0)
	//Calculate necessary moles to transfer using PV = nRT
	if(TOTAL_MOLES(air1))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		network1?.update = TRUE
		network2?.update = TRUE

/obj/machinery/atmospherics/binary/passive_gate/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		src.ui.show_ui(user)

/obj/machinery/atmospherics/binary/passive_gate/opened
	icon_state = "on-map"
	on = TRUE

/datum/pump_ui/passive_gate_ui
	value_name = "Release Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 1e31
	incr_sm = 100
	incr_lg = 1000
	var/obj/machinery/atmospherics/binary/passive_gate/our_gate

/datum/pump_ui/passive_gate_ui/New(obj/machinery/atmospherics/binary/passive_gate/our_gate)
	..()
	src.our_gate = our_gate
	pump_name = our_gate.name

/datum/pump_ui/passive_gate_ui/set_value(val)
	our_gate.target_pressure = val

/datum/pump_ui/passive_gate_ui/toggle_power()
	our_gate.on = !our_gate.on
	our_gate.UpdateIcon()

/datum/pump_ui/passive_gate_ui/is_on()
	return our_gate.on

/datum/pump_ui/passive_gate_ui/get_value()
	return our_gate.target_pressure

/datum/pump_ui/passive_gate_ui/get_atom()
	return our_gate
