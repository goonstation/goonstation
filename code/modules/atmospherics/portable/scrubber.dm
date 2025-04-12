TYPEINFO(/obj/machinery/portable_atmospherics/scrubber)
	mats = 12

/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = FALSE
	var/inlet_flow = 100 // percentage
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	volume = 1000
	desc = "A device which filters out harmful air from an area."
	p_class = 1.5


	//for smoke
	var/drain_min = 5
	var/drain_max = 12
	///Temporary reagent buffer, reagents are stored in src.reagents
	var/obj/item/reagent_containers/glass/buffer = null

	New()
		..()
		src.buffer = new(src)
		src.buffer.reagents.maximum_volume = 500

		src.create_reagents(500)

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

/obj/machinery/portable_atmospherics/scrubber/proc/scrub(datum/gas_mixture/removed)
	//Filter it
	var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
	if (filtered_out && removed)
		filtered_out.temperature = removed.temperature
		#define _FILTER_OUT_GAS(GAS, ...) \
			filtered_out.GAS = removed.GAS; \
			removed.GAS = 0;
		APPLY_TO_GASES(_FILTER_OUT_GAS)
		#undef _FILTER_OUT_GAS

		// revert for breathable
		removed.oxygen = filtered_out.oxygen
		filtered_out.oxygen = 0
		removed.nitrogen = filtered_out.nitrogen
		filtered_out.nitrogen = 0

		//Remix the resulting gases
		air_contents.merge(filtered_out)
	return removed

/obj/machinery/portable_atmospherics/scrubber/proc/scrub_turf(turf/simulated/T, flow)
	var/datum/gas_mixture/environment = T.return_air()
	var/datum/gas_mixture/removed = T.remove_air(min(TOTAL_MOLES(environment) * flow / 100, 100))
	T.assume_air(src.scrub(removed))

/obj/machinery/portable_atmospherics/scrubber/proc/scrub_mixture(datum/gas_mixture/environment, flow)
	var/datum/gas_mixture/removed = environment.remove(TOTAL_MOLES(environment) * flow / 100)
	environment.merge(src.scrub(removed))

/obj/machinery/portable_atmospherics/scrubber/process(mult)
	..()
	if (!loc) return
	if (src.contained) return
	var/area/A = get_area(src)
	if (!isarea(A))
		return
	if(!A.powered(ENVIRON))
		if(src.on)
			src.on = FALSE
			src.updateDialog()
			src.UpdateIcon()
			src.visible_message(SPAN_ALERT("[src] shuts down due to lack of APC power."))
		return

	if(on)
		var/active_power_usage = 1 KILO WATT + src.inlet_flow * 10 WATTS // up to 2 Kilowatts just to run it
		//smoke/fluid :
		var/turf/my_turf = get_turf(src)
		if (my_turf)
			var/obj/fluid/airborne/F = my_turf.active_airborne_liquid
			if (F?.group)
				var/pre_drain_fluid_volume = src.buffer.reagents.total_volume
				F.group.drain(F, src.inlet_flow / 8, src.buffer, remove_reagent = FALSE)
				var/butt = src.buffer.reagents.total_volume - pre_drain_fluid_volume
				active_power_usage += (butt) * 50 WATTS // max 500 reagents * 50 = 25 Kilowatts
				var/amount_to_transfer = src.reagents.maximum_volume - src.reagents.total_volume
				src.buffer.reagents.trans_to(src, amount_to_transfer)
				if (src.buffer.reagents.total_volume) // whatever's left, dump it on the ground
					src.buffer.reagents.reaction(get_turf(src), TOUCH, src.buffer.reagents.total_volume)
				src.buffer.reagents.clear_reagents()

		var/original_my_moles = TOTAL_MOLES(src.air_contents)
		if(src.holding)
			src.scrub_mixture(src.holding.air_contents, src.inlet_flow)
		else
			for(var/turf/T in range(1, src))
				if(issimulatedturf(T) && isfloor(T))
					src.scrub_turf(T, T == src.loc ? src.inlet_flow : src.inlet_flow / 2)
		var/filtered_out_moles = TOTAL_MOLES(src.air_contents) - original_my_moles
		active_power_usage += filtered_out_moles * 20 WATTS
		src.use_power(active_power_usage, ENVIRON)
		src.updateDialog()
	src.UpdateIcon()

/obj/machinery/portable_atmospherics/scrubber/return_air(direct = FALSE)
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (length(porter.contents) >= porter.capacity) boutput(user, SPAN_ALERT("Your [W] is full!"))
		else if (src.anchored) boutput(user, SPAN_ALERT("\The [src] is attached!"))
		else
			user.visible_message(SPAN_NOTICE("[user] collects the [src]."), SPAN_NOTICE("You collect the [src]."))
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	else if(iswrenchingtool(W))
		if(!connected_port)//checks for whether the scrubber is connected to a port, if it is calls parent.
			var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector) in loc
			if(!possible_port)//checks for whether there's something that could be connected to on the scrubber's loc, if there is it calls parent.
				if(src.anchored)
					src.anchored = UNANCHORED
					boutput(user, SPAN_NOTICE("You unanchor [name] from the floor."))
				else
					src.anchored = ANCHORED
					boutput(user, SPAN_NOTICE("You anchor [name] to the floor."))
			else ..()
		else ..()
	else ..()


/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	if(!src.connected_port && GET_DIST(src, user) > 7)
		return
	return src.Attackhand(user)

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, datum/tgui/ui)
	if (src.holding)
		SEND_SIGNAL(src.holding.reagents, COMSIG_REAGENTS_ANALYZED, user)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PortableScrubber", name)
		ui.open()

/obj/machinery/portable_atmospherics/scrubber/ui_data(mob/user)
	. = list(
		"pressure" = MIXTURE_PRESSURE(src.air_contents),
		"on" = src.on,
		"connected" = !!src.connected_port,
		"inletFlow" = src.inlet_flow
	)

	.["holding"] = src.holding?.ui_describe()
	.["reagent_container"] = ui_describe_reagents(src)

/obj/machinery/portable_atmospherics/scrubber/ui_static_data(mob/user)
	. = list(
		"minFlow" = 0,
		"maxFlow" = 100,
		"maxPressure" = src.maximum_pressure
	)

/obj/machinery/portable_atmospherics/scrubber/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle-power")
			src.on = !src.on
			src.UpdateIcon()
			. = TRUE
		if("set-inlet-flow")
			var/new_inlet_flow = params["inletFlow"]
			if(isnum(new_inlet_flow))
				src.inlet_flow = clamp(new_inlet_flow, 0, 100)
				. = TRUE
		if("eject-tank")
			src.eject_tank()
			. = TRUE
