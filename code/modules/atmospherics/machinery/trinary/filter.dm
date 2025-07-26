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

/obj/machinery/atmospherics/trinary/filter/New()
	..()
	if(src.gaslist) return
	src.gaslist = list()
	#define _CREATE_FILTER_LIST(_, _, GASNAME, ...) src.gaslist += GASNAME;
	APPLY_TO_GASES(_CREATE_FILTER_LIST)
	#undef _CREATE_FILTER_LIST

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

	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, -180), "long", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.flipped ? turn(src.dir, 90) : turn(src.dir, -90), "long", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node3, src.dir, "long", issimplepipe(src.node3) ?  src.node3.color : null, FALSE)

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

/obj/machinery/atmospherics/trinary/filter/active
	icon_state = "on-map"
	on = TRUE

#define MIN_VOLUME 1
#define MAX_VOLUME 200
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
				var/value = input(usr, "Transfer Rate ([MIN_VOLUME] - [MAX_VOLUME] L):", "Enter new value", src.our_filter.transfer_rate) as num
				if(isnum_safe(value))
					src.our_filter.transfer_rate = clamp(value, MIN_VOLUME, MAX_VOLUME)
					logTheThing(LOG_STATION, usr, "has set [src.our_filter] transfer rate to [value] at [log_loc(src.our_filter)]")

			if("toggle_power")
				src.our_filter.on = !src.our_filter.on
				logTheThing(LOG_STATION, usr, "has set [src.our_filter] to [src.our_filter.on ?  "On" : "Off"] at [log_loc(src.our_filter)]")
				src.our_filter.UpdateIcon()

			if("bump_transfer")
				src.our_filter.transfer_rate = clamp(src.our_filter.transfer_rate + text2num_safe(href_list["bump_transfer"]), MIN_VOLUME, MAX_VOLUME)
				logTheThing(LOG_STATION, usr, "has set [src.our_filter] transfer rate to [src.our_filter.transfer_rate] at [log_loc(src.our_filter)]")

			if("change_gas")
				var/value = input(usr, "Select Gas", "Filtered Gas Selection", src.our_filter.filter_type) in src.our_filter.gaslist
				if(value in src.our_filter.gaslist)
					src.our_filter.filter_type = value
					logTheThing(LOG_STATION, usr, "has set [src.our_filter] gas to [value] at [log_loc(src.our_filter)]")

	src.show_ui(usr)

/datum/filter_ui/proc/show_ui(mob/user)
	if (user.client?.tooltipHolder) // Monke!
		user.client.tooltipHolder.showClickTip(src.our_filter, list("title" = src.our_filter, "content" = render()))

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

#undef MIN_VOLUME
#undef MAX_VOLUME
