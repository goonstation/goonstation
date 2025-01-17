/// We are taking in all gases indiscriminately.
#define SIPHONING 0
/// We are selectively choosing gases to suck.
#define SCRUBBING 1

/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "on-map"
	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = UNDERFLOOR
	/// ID we respond to for multicast.
	var/id = null
	/// ID that refers specifically to us.
	var/net_id = null
	/// Frequency we communicate on, usually with air alarms.
	var/frequency = FREQ_AIR_ALARM_CONTROL
	/// Are we doing anything at all?
	var/on = TRUE
	/// Are we sucking in all gas or only some?
	var/scrubbing = SCRUBBING
	// Sets up vars to scrub gases
	#define _DEF_SCRUBBER_VAR(GAS, ...) var/scrub_##GAS = 0;
	APPLY_TO_GASES(_DEF_SCRUBBER_VAR)
	#undef _DEF_SCRUBBER_VAR
	/// Volume of gas to take from turf.
	var/volume_rate = 120

/obj/machinery/atmospherics/unary/vent_scrubber/New()
	..()
	if(src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)

/obj/machinery/atmospherics/unary/vent_scrubber/initialize()
	..()
	UpdateIcon()

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon()
	var/turf/T = get_turf(src)
	src.hide(T.intact)

/obj/machinery/atmospherics/unary/vent_scrubber/process()
	..()
	if(!on)
		return FALSE

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

			//Remix the resulting gases
			air_contents.merge(filtered_out)

			loc.assume_air(removed)

			network?.update = TRUE

	else //Just siphoning all air
		var/transfer_moles = TOTAL_MOLES(environment)*(volume_rate/environment.volume)

		var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

		air_contents.merge(removed)

		network?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/intact) //to make the little pipe section invisible, the icon changes.
	var/hide_pipe = CHECKHIDEPIPE(src)
	if(on&&node)
		if(scrubbing)
			icon_state = "[hide_pipe ? "h" : "" ]on"
		else
			icon_state = "[hide_pipe ? "h" : "" ]in"
	else
		icon_state = "[hide_pipe ? "h" : "" ]off"
		on = FALSE

	SET_PIPE_UNDERLAY(src.node, src.dir, "long", issimplepipe(src.node) ?  src.node.color : null, hide_pipe)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["tag"] = src.id
	signal.data["sender"] = src.net_id
	signal.data["power"] = src.on ? "on": "off"
	signal.data["mode"] = src.scrubbing ? "scrubbing" : "siphoning"
	#define GET_GAS_SCUB_STATUS(GAS, ...) signal.data[#GAS] = scrub_##GAS;
	APPLY_TO_GASES(GET_GAS_SCUB_STATUS)
	#undef GET_GAS_SCUB_STATUS

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(!((signal.data["tag"] && (signal.data["tag"] == src.id)) || (signal.data["address_1"] == src.net_id)))
		if(signal.data["command"] != "broadcast_status")
			return FALSE

	switch(signal.data["command"])
		if("power_on")
			src.on = TRUE
			. = TRUE

		if("power_off")
			src.on = FALSE
			. = TRUE

		if("power_toggle")
			src.on = !on
			. = TRUE

		if("set_siphon")
			src.scrubbing = SIPHONING
			. = TRUE

		if("set_scrubbing")
			src.scrubbing = SCRUBBING
			. = TRUE

		if("toggle_scrub_gas")
			switch(signal.data["parameter"])
				#define _FILTER_OUT_GAS(GAS, ...) \
				if(#GAS) { \
					scrub_##GAS = !scrub_##GAS; \
				}
				APPLY_TO_GASES(_FILTER_OUT_GAS)
				#undef _FILTER_OUT_GAS
			. = TRUE

		if("broadcast_status")
			SPAWN(0.5 SECONDS) broadcast_status()

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									power_on - Turns on scrubber. \
									power_off - Turns off scrubber. \
									power_toggle - Toggles scrubber. \
									set_siphon - Begins siphoning all gas. \
									set_scrubbing - Begins scrubbing select gases. \
									toggle_scrub_gas (parameter: String) - Toggles filtering for a specific gas. Uses the shortform name for a gas."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)


	if(.)
		src.UpdateIcon()
		var/turf/intact = get_turf(src)
		intact = intact.intact
		var/hide_pipe = CHECKHIDEPIPE(src)
		flick("[hide_pipe ? "h" : "" ]alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)

/obj/machinery/atmospherics/unary/vent_scrubber/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_scrubber/overfloor
	level = OVERFLOOR

/obj/machinery/atmospherics/unary/vent_scrubber/overfloor/inactive
	icon_state = "off-map"
	on = FALSE

/obj/machinery/atmospherics/unary/vent_scrubber/breathable
	scrub_oxygen = FALSE
	scrub_nitrogen = FALSE

/obj/machinery/atmospherics/unary/vent_scrubber/breathable/overfloor
	level = OVERFLOOR

#undef SIPHONING
#undef SCRUBBING
