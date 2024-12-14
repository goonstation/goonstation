/// Shoves transfer_rate volume of gas from air1 to air2
/// Max volume flow rate.
#define MAX_VOLUME 1000

/obj/machinery/atmospherics/binary/volume_pump
	name = "Gas pump"
	desc = "A pump"
	icon = 'icons/obj/atmospherics/volume_pump.dmi'
	icon_state = "off-map"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = FALSE
	var/transfer_rate = 200

	/// Radio frequency to operate on.
	var/frequency = null
	/// Radio ID we respond to for multicast.
	var/id = null
	/// Radio ID that refers to specifically us.
	var/net_id = null

	var/datum/pump_ui/volume_pump_ui/ui

/obj/machinery/atmospherics/binary/volume_pump/New()
	..()
	if(src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)

/obj/machinery/atmospherics/binary/volume_pump/update_icon()
	if(!(node1&&node2))
		src.on = FALSE

	icon_state = src.on ? "on" : "off"
	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, 180), "long", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.dir, "long", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)

/obj/machinery/atmospherics/binary/volume_pump/process()
	..()
	if(!on)
		return FALSE

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)

	network1?.update = TRUE
	network2?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/binary/volume_pump/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["sender"] = src.net_id
	signal.data["device"] = "APV"
	signal.data["power"] = src.on
	signal.data["transfer_rate"] = src.transfer_rate

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/binary/volume_pump/initialize()
	..()
	src.ui = new/datum/pump_ui/volume_pump_ui(src)

/obj/machinery/atmospherics/binary/volume_pump/receive_signal(datum/signal/signal)
	if(!((signal.data["tag"] && (signal.data["tag"] == src.id)) || (signal.data["address_1"] == src.net_id)))
		if(signal.data["command"] != "broadcast_status")
			return FALSE

	switch(signal.data["command"])
		if("broadcast_status")
			SPAWN(0.5 SECONDS)
				broadcast_status()

		if("power_on")
			src.on = TRUE
			. = TRUE

		if("power_off")
			src.on = FALSE
			. = TRUE

		if("power_toggle")
			src.on = !on
			. = TRUE

		if("set_transfer_rate")
			var/number = text2num_safe(signal.data["parameter"])

			src.transfer_rate = clamp(number, 0, MAX_VOLUME)
			. = TRUE

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									power_on - Turns on pump. \
									power_off - Turns off pump. \
									power_toggle - Toggles pump. \
									set_transfer_rate (parameter: Number) - Sets transfer rate in liters to parameter. Max at [MAX_VOLUME] L."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)

	if(.)
		src.UpdateIcon()
		flick("alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)

/obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		ui.show_ui(user)

/obj/machinery/atmospherics/binary/volume_pump/active
	icon_state = "on-map"
	on = TRUE

/datum/pump_ui/volume_pump_ui
	value_name = "Flow Rate"
	value_units = "L/s"
	min_value = 0
	max_value = MAX_VOLUME
	incr_sm = 10
	incr_lg = 100
	var/obj/machinery/atmospherics/binary/volume_pump/our_pump

/datum/pump_ui/volume_pump_ui/New(obj/machinery/atmospherics/binary/volume_pump/our_pump)
	..()
	src.our_pump = our_pump
	src.pump_name = our_pump.name

/datum/pump_ui/volume_pump_ui/set_value(val)
	our_pump.transfer_rate = val
	our_pump.UpdateIcon()

/datum/pump_ui/volume_pump_ui/toggle_power()
	our_pump.on = !our_pump.on
	our_pump.UpdateIcon()

/datum/pump_ui/volume_pump_ui/is_on()
	return our_pump.on

/datum/pump_ui/volume_pump_ui/get_value()
	return our_pump.transfer_rate

/datum/pump_ui/volume_pump_ui/get_atom()
	return our_pump

#undef MAX_VOLUME
