//Ye olde filter of yore (Pre-dev adjustable filter)

//TODO: Make this more modular and use APPLY_TO_GASES

//TODO: Hacking.

#define MODE_OXYGEN (1<<0) //Let oxygen through
#define MODE_NITROGEN (1<<1) //Let nitrogen through
#define MODE_CO2 (1<<2) //Let CO2 through
#define MODE_PLASMA (1<<3) //Let plasma through.
#define MODE_TRACE (1<<4) //Let trace gases (Like N2O) through.
/obj/machinery/atmospherics/retrofilter
	icon = 'icons/obj/atmospherics/retro_filter.dmi'
	icon_state = "intact_off"
	name = "Gas filter"
	req_access = list(access_engineering_atmos)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	var/datum/gas_mixture/air_in
	var/datum/gas_mixture/air_out1
	var/datum/gas_mixture/air_out2

	var/obj/machinery/atmospherics/node_in
	var/obj/machinery/atmospherics/node_out1 //This is where filtered air comes out. It's this one.
	var/obj/machinery/atmospherics/node_out2

	var/datum/pipe_network/network_in
	var/datum/pipe_network/network_out1
	var/datum/pipe_network/network_out2

	var/target_pressure = ONE_ATMOSPHERE
	var/transfer_ratio = 0.8 //Percentage of passing gas to consider for transfer.

	var/filter_mode = 0 //Bitfield determining gases to filter.

	var/locked = TRUE
	var/open = FALSE
	var/hacked = FALSE
	var/emagged = FALSE

/obj/machinery/atmospherics/retrofilter/New()
	..()
	switch(dir)
		if(NORTH)
			initialize_directions = NORTH|EAST|SOUTH
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|WEST
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = NORTH|EAST|WEST
	if(radio_controller)
		initialize()

	air_in = new /datum/gas_mixture
	air_out1 = new /datum/gas_mixture
	air_out2 = new /datum/gas_mixture

	air_in.volume = 200
	air_out1.volume = 200
	air_out2.volume = 200

/obj/machinery/atmospherics/retrofilter/disposing()
	if(node_out1)
		node_out1.disconnect(src)
		if (network_out1)
			network_out1.dispose()

	if(node_out2)
		node_out2.disconnect(src)
		if (network_out2)
			network_out2.dispose()

	else if(node_in)
		node_in.disconnect(src)
		if (network_in)
			network_in.dispose()

	node_out1 = null
	node_out2 = null
	node_in = null
	network_out1 = null
	network_out2 = null
	network_in = null

	if(air_in)
		qdel(air_in)
	if(air_out1)
		qdel(air_out1)
	if(air_out2)
		qdel(air_out2)

	air_in = null
	air_out1 = null
	air_out2 = null

	..()

/obj/machinery/atmospherics/retrofilter/network_disposing(datum/pipe_network/reference)
	if (network_in == reference)
		network_in = null
	if (network_out1 == reference)
		network_out1 = null
	if (network_out2 == reference)
		network_out2 = null

/obj/machinery/atmospherics/retrofilter/update_icon()
	if(node_out1&&node_out2&&node_in)
		icon_state = "intact_[(status & NOPOWER)?("off"):("on")]"
	else
		var/node_out1_direction = get_dir(src, node_out1)
		var/node_out2_direction = get_dir(src, node_out2)

		var/node_in_bit = (node_in)?(1):(0)

		icon_state = "exposed_[node_out1_direction|node_out2_direction]_[node_in_bit]_off"

/obj/machinery/atmospherics/retrofilter/attack_hand(mob/user)
	if(..())
		user.Browse(null, "window=pipefilter")
		src.remove_dialog(user)
		return

	var/list/gases = list("O2", "N2", "CO2", "Plasma", "OTHER")
	src.add_dialog(user)
	var/dat = "<head><title>Gas Filtration Unit Mk VII</title></head><body><hr>"
	for (var/i in 1 to length(gases))
		if (!issilicon(user) && src.locked)
			dat += "[gases[i]]: [(src.filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]<br>"
		else
			dat += "[gases[i]]: <a href='?src=\ref[src];toggle_gas=[1 << (i - 1)]'>[(src.filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]</a><br>"

	var/pressure = MIXTURE_PRESSURE(air_in)
	var/total_moles = TOTAL_MOLES(air_in)

	dat += "<hr>Gas Levels: <br>Gas Pressure: [round(pressure,0.1)] kPa<br><br>"

	if (total_moles)
		var/o2_level = air_in.oxygen/total_moles
		var/n2_level = air_in.nitrogen/total_moles
		var/co2_level = air_in.carbon_dioxide/total_moles
		var/plasma_level = air_in.toxins/total_moles
		var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

		dat += "Nitrogen: [round(n2_level*100)]%<br>"

		dat += "Oxygen: [round(o2_level*100)]%<br>"

		dat += "Carbon Dioxide: [round(co2_level*100)]%<br>"

		dat += "Plasma: [round(plasma_level*100)]%<br>"

		if(unknown_level > 0.01)
			dat += "OTHER: [round(unknown_level)]%<br>"
	else
		dat += "Nitrogen: 0%<br>Oxygen: 0%<br>Carbon Dioxide: 0%<br>Plasma: 0%<br>"

	dat += "<br><A href='?src=\ref[src];close=1'>Close</A>"

	user.Browse(dat, "window=pipefilter;size=300x365")
	onclose(user, "pipefilter")

/obj/machinery/atmospherics/retrofilter/Topic(href, href_list)
	if(..() || (status & NOPOWER))
		return

	src.add_dialog(usr)

	src.add_fingerprint(usr)
	if (href_list["toggle_gas"] && (!src.locked || issilicon(usr)))
		var/gasToToggle = text2num(href_list["toggle_gas"])
		if (!gasToToggle)
			return
		gasToToggle = clamp(gasToToggle, 1, 16)
		if (filter_mode & gasToToggle)
			filter_mode &= ~gasToToggle
		else
			filter_mode |= gasToToggle

		src.updateUsrDialog()
		src.update_overlays()

	else if (href_list["close"])
		usr.Browse(null, "window=pipefilter")
		src.remove_dialog(usr)
		return

//Draw the nice little blinky lights that give an at-a-glance indication of filter state.
/obj/machinery/atmospherics/retrofilter/proc/update_overlays()
	src.overlays.len = 0

	if (src.open)
		src.overlays += image(src.icon, "filter-open")
	if (src.hacked)
		src.overlays += image(src.icon, "filter-bypass")

	if (status & NOPOWER)
		return

	if (src.emagged)
		src.overlays += image(src.icon, "filter-emag")
	else
		if (filter_mode & MODE_OXYGEN)
			src.overlays += image(src.icon, "filter-o2")
		if (filter_mode & MODE_NITROGEN)
			src.overlays += image(src.icon, "filter-n2")
		if (filter_mode & MODE_CO2)
			src.overlays += image(src.icon, "filter-co2")
		if (filter_mode & (MODE_PLASMA | MODE_TRACE))
			src.overlays += image(src.icon, "filter-tox")

/obj/machinery/atmospherics/retrofilter/process()
	..()
	if(status & NOPOWER)
		return

	if (!air_out2)
		return

	var/output_starting_pressure = MIXTURE_PRESSURE(air_out1)

	if(output_starting_pressure >= target_pressure)
		//No need to mix if target is already full!
		return 1

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles = 0

	if(air_in.temperature > 0)
		transfer_moles = ((pressure_delta*air_out2.volume)/(air_in.temperature * R_IDEAL_GAS_EQUATION))

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air_in.remove_ratio(transfer_ratio)//air_in.remove(transfer_moles)

		var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
		if(air_in.temperature)
			filtered_out.temperature = air_in.temperature

		//Unlike the regular filter, we can pick and choose the gas to remove!
		//One might say that a little filter being this advanced is rather unrealistic
		//However, who gives a fuck.
		if (filter_mode & MODE_PLASMA)
			if(removed.toxins)
				filtered_out.toxins = removed.toxins
				removed.toxins = 0
		if (filter_mode & MODE_OXYGEN)
			if(removed.oxygen)
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0
		if (filter_mode & MODE_NITROGEN)
			if(removed.nitrogen)
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0
		if (filter_mode & MODE_CO2)
			if(removed.carbon_dioxide)
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0
		if (filter_mode & MODE_TRACE)
			if(removed && length(removed.trace_gases))
				for(var/datum/gas/trace_gas as anything in removed.trace_gases)
					if(trace_gas)
						var/datum/gas/filtered_gas = filtered_out.get_or_add_trace_gas_by_type(trace_gas.type)
						filtered_gas.moles = trace_gas.moles
						removed.remove_trace_gas(trace_gas)

		air_out1.merge(filtered_out)
		air_out2.merge(removed)

	if ((network_out2 && network_in) && (network_out2 != network_in))
		network_in.merge(network_out2)
		network_out2 = network_in

	network_out1?.update = TRUE

	if(network_out2)
		network_out2.update = TRUE

	else if(network_in)
		network_in.update = TRUE

	return TRUE

/obj/machinery/atmospherics/retrofilter/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	src.emagged = TRUE
	if (user)
		src.add_fingerprint(user)
		src.visible_message("<span class='alert'>[user] has shorted out the [src.name] with an electromagnetic card!</span>")
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/retrofilter/demag(var/mob/user)
	if (!src.emagged)
		return FALSE
	if (user)
		user.show_message("<span class='notice'>You repair the [src.name]'s wiring!</span>")
	src.emagged = TRUE
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/retrofilter/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/device/pda2) && W:ID_card)
		W = W:ID_card
	if (istype(W, /obj/item/card/id))
		src.add_fingerprint(user)
		if (src.hacked)
			boutput(user, "<span class='alert'>Remove the foreign wires first!</span>")
			return
		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			src.updateUsrDialog()
			src.update_overlays()
		else
			boutput(user, "<span class='alert'>Access denied.</span>")
	else if (isscrewingtool(W))
		if(src.hacked)
			user.show_message("<span class='alert'>Remove the foreign wires first!</span>", 1)
			return
		src.add_fingerprint(user)
		user.show_message("<span class='alert'>Now [src.open ? "re" : "un"]securing the access system panel...</span>", 1)
		if (!do_after(user, 3 SECONDS))
			return
		src.open = !src.open
		user.show_message("<span class='alert'>Done!</span>",1)
		src.update_overlays()
		return
	else if (istype(W, /obj/item/cable_coil) && !hacked)
		if(!src.open)
			user.show_message("<span class='alert'>You must remove the panel first!</span>",1)
			return
		var/obj/item/cable_coil/C = W
		if(C.amount >= 4)
			user.show_message("<span class='alert'>You unravel some cable..</span>",1)
		else
			user.show_message("<span class='alert'>Not enough cable! <I>(Requires four pieces)</I></span>",1)
			return
		src.add_fingerprint(user)
		user.show_message("<span class='alert'>Now bypassing the access system... <I>(This may take a while)</I></span>", 1)
		if(!do_after(user, 100))
			return
		C.use(4)
		src.hacked = TRUE
		src.locked = FALSE
		src.update_overlays()
		return
	else if (issnippingtool(W) && hacked)
		src.add_fingerprint(user)
		user.show_message("<span class='alert'>Now removing the bypass wires... <I>(This may take a while)</I></span>", 1)
		if (!do_after(user, 5 SECONDS))
			return
		src.hacked = FALSE
		src.update_overlays()
		return
	else
		..()

// Housekeeping and pipe network stuff below
/obj/machinery/atmospherics/retrofilter/power_change()
	if( powered(ENVIRON) )
		status &= ~NOPOWER
	else
		SPAWN(rand(0, 15))
			status |= NOPOWER

	src.update_overlays()

/obj/machinery/atmospherics/retrofilter/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
	if(reference == node_in)
		network_in = new_network

	else if(reference == node_out1)
		network_out1 = new_network

	else if(reference == node_out2)
		network_out2 = new_network

	if(src in new_network.normal_members)
		return FALSE

	new_network.normal_members += src

/obj/machinery/atmospherics/retrofilter/initialize()
	if(node_out1 && node_in) return

	var/node_in_connect = turn(dir, -180)
	var/node_out1_connect = turn(dir, -90)
	var/node_out2_connect = dir


	for(var/obj/machinery/atmospherics/target in get_step(src,node_out1_connect))
		if(target.initialize_directions & get_dir(target,src))
			node_out1 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node_out2_connect))
		if(target.initialize_directions & get_dir(target,src))
			node_out2 = target
			break

	for(var/obj/machinery/atmospherics/target in get_step(src,node_in_connect))
		if(target.initialize_directions & get_dir(target,src))
			node_in = target
			break

	UpdateIcon()

/obj/machinery/atmospherics/retrofilter/build_network()
	if(!network_out1 && node_out1)
		network_out1 = new /datum/pipe_network()
		network_out1.normal_members += src
		network_out1.build_network(node_out1, src)

	if(!network_out2 && node_out2)
		network_out2 = new /datum/pipe_network()
		network_out2.normal_members += src
		network_out2.build_network(node_out2, src)

	if(!network_in && node_in)
		network_in = new /datum/pipe_network()
		network_in.normal_members += src
		network_in.build_network(node_in, src)


/obj/machinery/atmospherics/retrofilter/return_network(obj/machinery/atmospherics/reference)
	build_network()

	if(reference==node_out1)
		return network_out1

	if(reference==node_out2)
		return network_out2

	if(reference==node_in)
		return network_in

/obj/machinery/atmospherics/retrofilter/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_out1 == old_network)
		network_out1 = new_network

	if(network_out2 == old_network)
		network_out2 = new_network

	if(network_in == old_network)
		network_in = new_network

	return TRUE

/obj/machinery/atmospherics/retrofilter/return_network_air(datum/pipe_network/reference)
	var/list/results = list()

	if(network_out1 == reference)
		results += air_out1

	if(network_out2 == reference)
		results += air_out2

	if(network_in == reference)
		results += air_in

	return results

/obj/machinery/atmospherics/retrofilter/disconnect(obj/machinery/atmospherics/reference)
	if(reference==node_out1)
		if (network_out1)
			network_out1.dispose()
			network_out1 = null
		node_out1 = null

	else if(reference==node_out2)
		if (network_out2)
			network_out2.dispose()
			network_out2 = null
		node_out2 = null

	else if(reference==node_in)
		if (network_in)
			network_in.dispose()
			network_in = null
		node_in = null


#undef MODE_OXYGEN
#undef MODE_NITROGEN
#undef MODE_CO2
#undef MODE_PLASMA
#undef MODE_TRACE
