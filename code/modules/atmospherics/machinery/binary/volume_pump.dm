/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, a//ir2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/volume_pump
	name = "Gas pump"
	desc = "A pump"
	icon = 'icons/obj/atmospherics/volume_pump.dmi'
	icon_state = "intact_off"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = 0
	var/transfer_rate = 200

	var/frequency = 0
	var/id = null

	var/datum/pump_ui/volume_pump_ui/ui

	New()
		..()
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

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

		var/transfer_ratio = max(1, transfer_rate/air1.volume)

		var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

		air2.merge(removed)

		network1?.update = 1

		network2?.update = 1

		return 1

	proc/broadcast_status()
		var/datum/signal/signal = get_free_signal()
		signal.transmission_method = 1 //radio signal
		signal.source = src

		signal.data["tag"] = id
		signal.data["device"] = "APV"
		signal.data["power"] = on
		signal.data["transfer_rate"] = transfer_rate

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

		return 1

	initialize()
		..()
		ui = new/datum/pump_ui/volume_pump_ui(src)

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

			if("set_transfer_rate")
				var/number = text2num_safe(signal.data["parameter"])
				number = clamp(number, 0, air1.volume)

				transfer_rate = number

		if(signal.data["tag"])
			SPAWN(0.5 SECONDS) broadcast_status()
		UpdateIcon()

obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		ui.show_ui(user)

datum/pump_ui/volume_pump_ui
	value_name = "Flow Rate"
	value_units = "L/s"
	min_value = 0
	max_value = 1000
	incr_sm = 10
	incr_lg = 100
	var/obj/machinery/atmospherics/binary/volume_pump/our_pump

datum/pump_ui/volume_pump_ui/New(obj/machinery/atmospherics/binary/volume_pump/our_pump)
	..()
	src.our_pump = our_pump
	src.pump_name = our_pump.name

datum/pump_ui/volume_pump_ui/set_value(val)
	our_pump.transfer_rate = val
	our_pump.UpdateIcon()

datum/pump_ui/volume_pump_ui/toggle_power()
	our_pump.on = !our_pump.on
	our_pump.UpdateIcon()

datum/pump_ui/volume_pump_ui/is_on()
	return our_pump.on

datum/pump_ui/volume_pump_ui/get_value()
	return our_pump.transfer_rate

datum/pump_ui/volume_pump_ui/get_atom()
	return our_pump
