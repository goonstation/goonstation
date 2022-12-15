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
	volume = 750
	desc = "A device which filters out harmful air from an area."
	p_class = 1.5


	//for smoke
	var/drain_min = 5
	var/drain_max = 12
	///Temporary reagent buffer, reagents are stored in src.reagents
	var/obj/item/reagent_containers/glass/buffer = null

	New()
		..()
		src.buffer = new(src, 500)
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

		if(length(removed.trace_gases))
			var/datum/gas/filtered_gas
			for(var/datum/gas/trace_gas as anything in removed.trace_gases)
				filtered_gas = filtered_out.get_or_add_trace_gas_by_type(trace_gas.type)
				filtered_gas.moles = trace_gas.moles
				removed.remove_trace_gas(trace_gas)

		//Remix the resulting gases
		air_contents.merge(filtered_out)
	return removed

/obj/machinery/portable_atmospherics/scrubber/proc/scrub_turf(turf/simulated/T, flow)
	var/datum/gas_mixture/environment = T.return_air()
	var/datum/gas_mixture/removed = T.remove_air(TOTAL_MOLES(environment) * flow / 100)
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
			src.visible_message("<span class='alert'>[src] shuts down due to lack of APC power.</span>")
		return

	if(on)
		var/power_usage = src.inlet_flow * 50 WATTS
		//smoke/fluid :
		var/turf/my_turf = get_turf(src)
		if (my_turf)
			var/obj/fluid/F = my_turf.active_airborne_liquid
			if (F?.group)
				power_usage += (inlet_flow / 8) * 5 KILO WATTS
				F.group.drain(F, inlet_flow / 8, src.buffer)
				// src.buffer.reagents.remove_any(src.buffer.reagents.total_volume/2)
				if (src.reagents.total_volume < src.reagents.maximum_volume)
					src.buffer.transfer_all_reagents(src)
				else
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
		power_usage += filtered_out_moles * 700 WATTS
		A.use_power(power_usage, ENVIRON)
		src.updateDialog()
	src.UpdateIcon()

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (porter.contents.len >= porter.capacity) boutput(user, "<span class='alert'>Your [W] is full!</span>")
		else if (src.anchored) boutput(user, "<span class='alert'>\The [src] is attached!</span>")
		else
			user.visible_message("<span class='notice'>[user] collects the [src].</span>", "<span class='notice'>You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	else if(iswrenchingtool(W))
		if(!connected_port)//checks for whether the scrubber is connected to a port, if it is calls parent.
			var/obj/machinery/atmospherics/portables_connector/possible_port = locate(/obj/machinery/atmospherics/portables_connector/) in loc
			if(!possible_port)//checks for whether there's something that could be connected to on the scrubber's loc, if there is it calls parent.
				if(src.anchored)
					src.anchored = 0
					boutput(user, "<span class='notice'>You unanchor [name] from the floor.</span>")
				else
					src.anchored = 1
					boutput(user, "<span class='notice'>You anchor [name] to the floor.</span>")
			else ..()
		else ..()
	else ..()


/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	if(!src.connected_port && GET_DIST(src, user) > 7)
		return
	return src.Attackhand(user)

/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, datum/tgui/ui)
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

	.["holding"] = isnull(holding) ? null : list(
		"name" = src.holding.name,
		"pressure" = MIXTURE_PRESSURE(src.holding.air_contents),
		"maxPressure" = PORTABLE_ATMOS_MAX_RELEASE_PRESSURE,
	)
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
