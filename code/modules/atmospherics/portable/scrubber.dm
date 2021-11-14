/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = FALSE
	var/inlet_flow = 100 // percentage
	mats = 12
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	volume = 750
	desc = "A device which filters out harmful air from an area."
	p_class = 1.5


	//for smoke
	var/drain_min = 5
	var/drain_max = 12

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
			src.update_icon()
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
				F.group.queued_drains += inlet_flow / 8
				F.group.last_drain = my_turf
				if (!F.group.draining)
					F.group.add_drain_process()

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
	src.update_icon()

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attackby(obj/item/W as obj, mob/user as mob)
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
	if(!src.connected_port && get_dist(src, user) > 7)
		return
	return src.Attackhand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)

	src.add_dialog(user)
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [MIXTURE_PRESSURE(holding.air_contents)] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [MIXTURE_PRESSURE(air_contents)] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Inlet flow: <A href='?src=\ref[src];volume_adj=-10'>-</A> <A href='?src=\ref[src];volume_adj=-1'>-</A> <A href='?src=\ref[src];volume_set=1'>[inlet_flow]</A>% <A href='?src=\ref[src];volume_adj=1'>+</A> <A href='?src=\ref[src];volume_adj=10'>+</A><BR>
<HR>
<A href='?action=mach_close&window=scrubber'>Close</A><BR>
"}

	user.Browse(output_text, "window=scrubber;size=600x300")
	onclose(user, "scrubber")
	return

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	if(..())
		return
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		src.add_dialog(usr)

		if(href_list["power"])
			on = !on

		if (href_list["remove_tank"])
			if(holding)
				holding.set_loc(loc)
				usr.put_in_hand_or_eject(holding) // try to eject it into the users hand, if we can
				holding = null

		if (href_list["volume_adj"])
			var/diff = text2num(href_list["volume_adj"])
			inlet_flow = min(100, max(0, inlet_flow+diff))

		else if (href_list["volume_set"])
			var/change = input(usr,"Target inlet flow (0-[100]):","Enter target inlet flow",inlet_flow) as num
			if(!isnum(change)) return
			inlet_flow = min(100, max(0, change))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr.Browse(null, "window=scrubber")
		return
	return
