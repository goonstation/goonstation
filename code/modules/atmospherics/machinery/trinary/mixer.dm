
#define _SET_SIGNAL_GAS(GAS, _, _, MIXTURE, ID, ...) signal.data[ID + #GAS] = round(100*##MIXTURE.GAS/MIXTURE##_total_moles);
#define _RESET_SIGNAL_GAS(GAS, _, _, ID, ...) signal.data[ID + #GAS] = 0;
#define SET_SIGNAL_MIXTURE(MIXTURE, ID) APPLY_TO_GASES(_SET_SIGNAL_GAS, MIXTURE, ID)
#define RESET_SIGNAL_MIXTURE(ID) APPLY_TO_GASES(_RESET_SIGNAL_GAS, ID)
/// Max mixer pressure.
#define MAX_PRESSURE 20 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/trinary/mixer
	name = "Gas mixer"
	icon = 'icons/obj/atmospherics/mixer.dmi'
	icon_state = "normal_off-map"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW
	/// ID tag used to refer to us.
	var/id_tag
	/// Who controls us?
	var/master_id
	var/on = FALSE
	/// Pressure we output at.
	var/target_pressure = ONE_ATMOSPHERE
	/// Ratio of gas from node1.
	var/node1_ratio = 0.5
	/// Ratio of gas from node2.
	var/node2_ratio = 0.5
	/// What frequency we listening on.
	var/frequency

/obj/machinery/atmospherics/trinary/mixer/New()
		..()
		air3.volume = 300

/obj/machinery/atmospherics/trinary/mixer/initialize()
		..()
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, null, src.frequency)

/obj/machinery/atmospherics/trinary/mixer/update_icon()
	if(!(src.node1 && src.node2 && src.node3))
		src.on = FALSE

	icon_state = "[src.flipped ? "flipped" : "normal"]_[src.on ? "on" : "off"]"

	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, -180), "long", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.flipped ? turn(src.dir, 90) : turn(src.dir, -90), "long", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node3, src.dir, "long", issimplepipe(src.node3) ?  src.node3.color : null, FALSE)

/obj/machinery/atmospherics/trinary/mixer/process()
	..()

	src.report_status()

	if(!src.on)
		return FALSE

	var/output_starting_pressure = MIXTURE_PRESSURE(src.air3)

	if(output_starting_pressure >= src.target_pressure)
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT
	var/pressure_delta = src.target_pressure - output_starting_pressure
	var/transfer_moles1 = 0
	var/transfer_moles2 = 0

	if(src.air1.temperature > 0)
		transfer_moles1 = (src.node1_ratio*pressure_delta)*src.air3.volume/(src.air1.temperature * R_IDEAL_GAS_EQUATION)

	if(src.air2.temperature > 0)
		transfer_moles2 = (src.node2_ratio*pressure_delta)*src.air3.volume/(src.air2.temperature * R_IDEAL_GAS_EQUATION)

	var/air1_moles = TOTAL_MOLES(src.air1)
	var/air2_moles = TOTAL_MOLES(src.air2)

	if((air1_moles < transfer_moles1) || (air2_moles < transfer_moles2))
		if(transfer_moles1 != 0 && transfer_moles2 != 0)
			var/ratio = min(air1_moles/transfer_moles1, air2_moles/transfer_moles2)

			transfer_moles1 *= ratio
			transfer_moles2 *= ratio

	//Actually transfer the gas
	if(transfer_moles1 > 0)
		var/datum/gas_mixture/removed1 = src.air1.remove(transfer_moles1)
		src.air3.merge(removed1)

	if(transfer_moles2 > 0)
		var/datum/gas_mixture/removed2 = src.air2.remove(transfer_moles2)
		src.air3.merge(removed2)

	if(transfer_moles1)
		src.network1?.update = TRUE

	if(transfer_moles2)
		src.network2?.update = TRUE

	network3?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/mixer/receive_signal(datum/signal/signal)
	if (signal.data["tag"] && (signal.data["tag"] != src.master_id))
		return FALSE

	switch (signal.data["command"])
		if ("toggle_pump")
			if (signal.data["parameter"] == "power_on")
				src.on = TRUE
			else if (signal.data["parameter"] == "power_off")
				src.on = FALSE

		if ("set_ratio")
			var/number = text2num(signal.data["parameter"])
			if (number && isnum(number))
				number = clamp(number, 0, 100)
				src.node1_ratio = number/100
				src.node2_ratio = (100-number)/100

		if ("set_pressure")
			var/number = text2num(signal.data["parameter"])
			if (isnum_safe(number))
				src.target_pressure = clamp(number, 0, MAX_PRESSURE)
			else
				src.target_pressure = 0

	if (signal.data["tag"])
		SPAWN(0.5 SECONDS)
			if (src) src.report_status()

	UpdateIcon()

/obj/machinery/atmospherics/trinary/mixer/proc/report_status() // Report the status of this mixer over the radio.
	if (status & (NOPOWER | BROKEN))
		return

	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.data["tag"] = src.id_tag
	signal.data["timestamp"] = air_master.current_cycle
	signal.data["target_pressure"] = src.target_pressure
	signal.data["pump_status"] = src.on ? "Online" : "Offline"

	//Report gas concentration of in1
	var/air1_total_moles = TOTAL_MOLES(src.air1)
	if(air1_total_moles > 0)
		SET_SIGNAL_MIXTURE(air1, "In1")
		signal.data["in1kpa"] = round(MIXTURE_PRESSURE(src.air1), 0.1)
		signal.data["in1temp"] = round(TO_CELSIUS(src.air1.temperature))
	else
		RESET_SIGNAL_MIXTURE("In1")
		signal.data["in1tg"] = 0

	//Report gas concentration of in2
	var/air2_total_moles = TOTAL_MOLES(src.air2)
	if(air2_total_moles > 0)
		SET_SIGNAL_MIXTURE(air2, "In2")
		signal.data["in2kpa"] = round(MIXTURE_PRESSURE(src.air2), 0.1)
		signal.data["in2temp"] = round(TO_CELSIUS(src.air2.temperature))
	else
		RESET_SIGNAL_MIXTURE("In2")
		signal.data["in2tg"] = 0

	//Report transferred concentrations
	signal.data["i1trans"] = src.node1_ratio*100
	signal.data["i2trans"] = src.node2_ratio*100

	//Report gas concentration of out
	var/air3_total_moles = TOTAL_MOLES(src.air3)
	if(air3_total_moles > 0)
		SET_SIGNAL_MIXTURE(air3, "Out")
		signal.data["outkpa"] = round(MIXTURE_PRESSURE(src.air3), 0.1)
		signal.data["outtemp"] = round(TO_CELSIUS(src.air3.temperature))
	else
		RESET_SIGNAL_MIXTURE("Out")
		signal.data["outtg"] = 0

	signal.data["address_tag"] = "mixercontrol"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

/obj/machinery/atmospherics/trinary/mixer/active
	icon_state = "normal_on-map"
	on = TRUE

/obj/machinery/atmospherics/trinary/mixer/flipped
	icon_state = "flipped_off-map"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/mixer/flipped/active
	icon_state = "flipped_on-map"
	on = TRUE

#undef _SET_SIGNAL_GAS
#undef _RESET_SIGNAL_GAS
#undef SET_SIGNAL_MIXTURE
#undef RESET_SIGNAL_MIXTURE
#undef MAX_PRESSURE
