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

/obj/machinery/atmospherics/binary/pump
	icon = 'icons/obj/atmospherics/pump.dmi'
	icon_state = "off-map"
	name = "Gas pump"
	desc = "A pump"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = FALSE
	var/target_pressure = ONE_ATMOSPHERE
	var/frequency = 0
	var/id = null

	var/datum/pump_ui/ui

/obj/machinery/atmospherics/binary/pump/New()
	..()
	MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/atmospherics/binary/pump/initialize()
	..()
	src.ui = new /datum/pump_ui/basic_pump_ui(src)

/obj/machinery/atmospherics/binary/pump/attack_hand(mob/user)
	UpdateIcon()

/obj/machinery/atmospherics/binary/pump/update_icon()
	if(!(node1&&node2))
		src.on = FALSE

	icon_state = src.on ? "on" : "off"
	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, 180), "medium", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.dir, "medium", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)

/obj/machinery/atmospherics/binary/pump/process()
	..()
	if(!on)
		return FALSE

	var/output_starting_pressure = MIXTURE_PRESSURE(air2)

	if(output_starting_pressure >= target_pressure)
		//No need to pump gas if target is already reached!
		return FALSE

	//Calculate necessary moles to transfer using PV=nRT
	if(TOTAL_MOLES(air1) && (air1.temperature>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		network1?.update = TRUE
		network2?.update = TRUE

		src.use_power((target_pressure) * (0.1)) // cogwerks: adjust the multiplier if needed

	return TRUE

/obj/machinery/atmospherics/binary/pump/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["device"] = "AGP"
	signal.data["power"] = src.on ? "on" : "off"
	signal.data["target_output"] = src.target_pressure
	signal.data["address_tag"] = "pumpcontrol"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE


/obj/machinery/atmospherics/binary/pump/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("broadcast_status")
			SPAWN(0.5 SECONDS)
				broadcast_status()

		if("power_on")
			on = TRUE

		if("power_off")
			on = FALSE

		if("power_toggle")
			on = !on

		if("set_output_pressure")
			var/number = text2num_safe(signal.data["parameter"])
			number = clamp(number, 0, ONE_ATMOSPHERE*50)

			target_pressure = number

	if(signal.data["tag"])
		SPAWN(0.5 SECONDS)
			broadcast_status()

	UpdateIcon()

/obj/machinery/atmospherics/binary/pump/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W) || iswrenchingtool(W))
		ui.show_ui(user)

/obj/machinery/atmospherics/binary/pump/active
	icon_state = "on-map"
	on = TRUE

/datum/pump_ui/basic_pump_ui
	value_name = "Target Pressure"
	value_units = "kPa"
	min_value = 0
	max_value = 15000
	incr_sm = 50
	incr_lg = 100
	var/obj/machinery/atmospherics/binary/pump/our_pump

/datum/pump_ui/basic_pump_ui/New(obj/machinery/atmospherics/binary/pump/our_pump)
	..()
	src.our_pump = our_pump
	src.pump_name = our_pump.name

/datum/pump_ui/basic_pump_ui/set_value(val_to_set)
	our_pump.target_pressure = val_to_set
	our_pump.UpdateIcon()

/datum/pump_ui/basic_pump_ui/toggle_power()
	our_pump.on = !our_pump.on
	our_pump.UpdateIcon()

/datum/pump_ui/basic_pump_ui/is_on()
	return our_pump.on

/datum/pump_ui/basic_pump_ui/get_value()
	return our_pump.target_pressure

/datum/pump_ui/basic_pump_ui/get_atom()
	return our_pump
