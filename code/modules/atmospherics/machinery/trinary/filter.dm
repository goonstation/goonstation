#define MAX_VOLUME 200
/obj/machinery/atmospherics/trinary/filter
	name = "Gas filter"
	icon = 'icons/obj/atmospherics/filter.dmi'
	icon_state = "off-map"
	layer = PIPE_MACHINE_LAYER
	plane = PLANE_NOSHADOW_BELOW

	var/on = FALSE
	/// Transfer rate in liters.
	var/transfer_rate = 50
	/// ID of the gas you wish to filter
	var/filter_type = "Plasma"
	var/static/list/gaslist
	var/datum/filter_ui/ui
	/// Radio frequency to operate on.
	var/frequency = FREQ_FREE
	/// Radio ID that refers to specifically us.
	var/net_id = null
	HELP_MESSAGE_OVERRIDE("Can be configured with a <b>multitool</b>.")

/obj/machinery/atmospherics/trinary/filter/New()
	..()
	if(src.gaslist) return
	src.gaslist = list()
	#define _CREATE_FILTER_LIST(_, _, GASNAME, ...) src.gaslist += GASNAME;
	APPLY_TO_GASES(_CREATE_FILTER_LIST)
	#undef _CREATE_FILTER_LIST
	if(src.frequency)
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, src.frequency)

/obj/machinery/atmospherics/trinary/filter/initialize()
	..()
	src.ui = new /datum/filter_ui(src)

/obj/machinery/atmospherics/trinary/filter/attackby(obj/item/W, mob/user)
	if(ispulsingtool(W))
		ui.show_ui(user)

/obj/machinery/atmospherics/trinary/filter/update_icon()
	if(!(src.node1 && src.node2 && src.node3))
		src.on = FALSE

	icon_state = src.on ? "on" : "off"

	update_pipe_underlay(src.node1, turn(src.dir, -180), "long", FALSE)
	update_pipe_underlay(src.node2, src.flipped ? turn(src.dir, 90) : turn(src.dir, -90), "long", FALSE)
	update_pipe_underlay(src.node3, src.dir, "long", FALSE)

/obj/machinery/atmospherics/trinary/filter/process()
	..()
	if(!src.on)
		return FALSE

	var/datum/gas_mixture/removed = src.air1.remove_ratio(src.transfer_rate/src.air1.volume)

	var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
	filtered_out.temperature = removed.temperature

	switch(src.filter_type)
		#define _CREATE_FILTER_TYPES(GAS, _, GASNAME...) if(GASNAME) {filtered_out.GAS = removed.GAS ; removed.GAS = 0; }
		APPLY_TO_GASES(_CREATE_FILTER_TYPES)
		#undef _CREATE_FILTER_TYPES

	src.air2.merge(filtered_out)
	src.air3.merge(removed)

	src.network1?.update = TRUE
	src.network2?.update = TRUE
	src.network3?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/filter/proc/broadcast_status()
	var/datum/signal/signal = get_free_signal()
	signal.transmission_method = TRANSMISSION_RADIO
	signal.source = src

	signal.data["sender"] = src.net_id
	signal.data["power"] = src.on
	signal.data["transfer_rate"] = src.transfer_rate
	signal.data["filtered_gas"] = src.filter_type

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)

	return TRUE

/obj/machinery/atmospherics/trinary/filter/receive_signal(datum/signal/signal)
	if(!(signal.data["address_1"] == src.net_id))
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

		if("set_gas")
			switch(signal.data["parameter"])
				#define _FILTER_OUT_GAS(GAS, _, GASNAME, ...) \
				if(#GAS) { \
					src.filter_type = GASNAME; \
				}
				APPLY_TO_GASES(_FILTER_OUT_GAS)
				#undef _FILTER_OUT_GAS
			. = TRUE

		if("help")
			var/datum/signal/help = get_free_signal()
			help.transmission_method = TRANSMISSION_RADIO
			help.source = src

			help.data["info"] = "Command help. \
									power_on - Turns on filter \
									power_off - Turns off filter. \
									power_toggle - Toggles filter. \
									set_transfer_rate (parameter: Number) - Sets transfer rate in liters to parameter. Max at [MAX_VOLUME] L. \
									set_gas (parameter: String) - Set gas filtering to parameter. Uses the shortform name for a gas."

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, help)

	if(.)
		src.UpdateIcon()
		FLICK("alert", src)
		playsound(src, 'sound/machines/chime.ogg', 25)


/obj/machinery/atmospherics/trinary/filter/active
	icon_state = "on-map"
	on = TRUE

/datum/filter_ui
	var/incr_small = 1
	var/incr_large = 10
	var/obj/machinery/atmospherics/trinary/filter/our_filter

/datum/filter_ui/New(our_filter)
	..()
	src.our_filter = our_filter

/datum/filter_ui/Topic(href, href_list)
	if(!can_act(usr))
		return
	if(href_list["ui_target"] == "filter_ui")
		switch(href_list["ui_action"])
			if("set_transfer")
				var/value = input(usr, "Transfer Rate ([0] - [MAX_VOLUME] L):", "Enter new value", src.our_filter.transfer_rate) as num
				if(isnum_safe(value))
					src.our_filter.transfer_rate = clamp(value, 0, MAX_VOLUME)
					logTheThing(LOG_STATION, usr, "has set [src.our_filter] transfer rate to [value] at [log_loc(src.our_filter)]")

			if("toggle_power")
				src.our_filter.on = !src.our_filter.on
				logTheThing(LOG_STATION, usr, "has set [src.our_filter] to [src.our_filter.on ?  "On" : "Off"] at [log_loc(src.our_filter)]")
				src.our_filter.UpdateIcon()

			if("bump_transfer")
				src.our_filter.transfer_rate = clamp(src.our_filter.transfer_rate + text2num_safe(href_list["bump_transfer"]), 0, MAX_VOLUME)
				logTheThing(LOG_STATION, usr, "has set [src.our_filter] transfer rate to [src.our_filter.transfer_rate] at [log_loc(src.our_filter)]")

			if("change_gas")
				var/value = input(usr, "Select Gas", "Filtered Gas Selection", src.our_filter.filter_type) in src.our_filter.gaslist
				if(value in src.our_filter.gaslist)
					src.our_filter.filter_type = value
					logTheThing(LOG_STATION, usr, "has set [src.our_filter] gas to [value] at [log_loc(src.our_filter)]")

	src.show_ui(usr)

/datum/filter_ui/proc/show_ui(mob/user)
	user.client.tooltips.show(TOOLTIP_PINNED, src.our_filter, title = "[src.our_filter]", content = src.render())

/datum/filter_ui/proc/render()
	return {"
<span>[src.our_filter.on ? "Active" : "Inactive"]</span>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=toggle_power">Toggle Power</a>
<br />
<span>Flow rate: </span>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=bump_transfer&bump_transfer=[-incr_large]">-</a>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=bump_transfer&bump_transfer=[-incr_small]">-</a>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=set_transfer">[src.our_filter.transfer_rate] L</a>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=bump_transfer&bump_transfer=[incr_small]">+</a>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=bump_transfer&bump_transfer=[incr_large]">+</a>
<br />
<span>Filtered Gas: </span>
<a href="byond://?src=\ref[src]&ui_target=filter_ui&ui_action=change_gas">[src.our_filter.filter_type]</a>
"}

#undef MAX_VOLUME
