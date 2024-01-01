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
	/// What we go by on radio communications
	var/id = null
	/// Frequency we communicate on, usually with air alarms.
	var/frequency = FREQ_AIR_ALARM_CONTROL
	/// Are we doing anything at all?
	var/on = TRUE
	/// Are we sucking in all gas or only some?
	var/scrubbing = SCRUBBING
	// Sets up vars to scrub gases
	#define _DEF_SCRUBBER_VAR(GAS, ...) var/scrub_##GAS = 1;
	APPLY_TO_GASES(_DEF_SCRUBBER_VAR)
	#undef _DEF_SCRUBBER_VAR
	/// Volume of gas to take from turf.
	var/volume_rate = 120

/obj/machinery/atmospherics/unary/vent_scrubber/New()
	..()
	if(frequency)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, frequency)

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

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(signal.data["tag"] && (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("power_on")
			on = TRUE

		if("power_off")
			on = FALSE

		if("power_toggle")
			on = !on

		if("set_siphon")
			scrubbing = SIPHONING

		if("set_scrubbing")
			scrubbing = SCRUBBING

	UpdateIcon()

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
