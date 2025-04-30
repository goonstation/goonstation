//Ye olde filter of yore (Pre-dev adjustable filter)

//TODO: Make this more modular and use APPLY_TO_GASES

//TODO: Hacking.
#define MODE_OXYGEN (1<<0)
#define MODE_NITROGEN (1<<1)
#define MODE_CO2 (1<<2)
#define MODE_PLASMA (1<<3)

/obj/machinery/atmospherics/trinary/retrofilter
	icon = 'icons/obj/atmospherics/retro_filter.dmi'
	icon_state = "off-map"
	name = "Gas filter"

	req_access = list(access_engineering_atmos)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER

	var/target_pressure = ONE_ATMOSPHERE
	/// Percentage of passing gas to consider for transfer.
	var/transfer_ratio = 0.8
	/// Bitfield determining gases to filter.
	var/filter_mode = 0
	/// Are we locked from access?
	var/locked = TRUE
	/// Is the access system open?
	var/open = FALSE
	/// Has our access system been bypassed?
	var/hacked = FALSE
	/// Are we emagged?
	var/emagged = FALSE

/obj/machinery/atmospherics/trinary/retrofilter/update_icon()
	if(!(src.node1 && src.node2 && src.node3))
		src.status |= NOPOWER

	src.icon_state = "[(src.status & NOPOWER)?("off"):("on")]"
	SET_PIPE_UNDERLAY(src.node1, turn(src.dir, -180), "long", issimplepipe(src.node1) ?  src.node1.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node2, src.flipped ? turn(src.dir, 90) : turn(src.dir, -90), "long", issimplepipe(src.node2) ?  src.node2.color : null, FALSE)
	SET_PIPE_UNDERLAY(src.node3, src.dir, "long", issimplepipe(src.node3) ?  src.node3.color : null, FALSE)

/obj/machinery/atmospherics/trinary/retrofilter/attack_hand(mob/user)
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
			dat += "[gases[i]]: <a href='byond://?src=\ref[src];toggle_gas=[1 << (i - 1)]'>[(src.filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]</a><br>"

	var/pressure = MIXTURE_PRESSURE(src.air1)
	var/total_moles = TOTAL_MOLES(src.air1)

	dat += "<hr>Gas Levels: <br>Gas Pressure: [round(pressure,0.1)] kPa<br><br>"

	if (total_moles)
		var/o2_level = src.air1.oxygen/total_moles
		var/n2_level = src.air1.nitrogen/total_moles
		var/co2_level = src.air1.carbon_dioxide/total_moles
		var/plasma_level = src.air1.toxins/total_moles
		var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)

		dat += "Nitrogen: [round(n2_level*100)]%<br>"

		dat += "Oxygen: [round(o2_level*100)]%<br>"

		dat += "Carbon Dioxide: [round(co2_level*100)]%<br>"

		dat += "Plasma: [round(plasma_level*100)]%<br>"

		if(unknown_level > 0.01)
			dat += "OTHER: [round(unknown_level)]%<br>"
	else
		dat += "Nitrogen: 0%<br>Oxygen: 0%<br>Carbon Dioxide: 0%<br>Plasma: 0%<br>"

	dat += "<br><A href='byond://?src=\ref[src];close=1'>Close</A>"

	user.Browse(dat, "window=pipefilter;size=300x365")
	onclose(user, "pipefilter")

/obj/machinery/atmospherics/trinary/retrofilter/Topic(href, href_list)
	if(..() || (src.status & NOPOWER))
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

//Draw the nice little blinky lights that give an at-a-glance indication of filter state.
/obj/machinery/atmospherics/trinary/retrofilter/proc/update_overlays()
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
		if (src.filter_mode & MODE_OXYGEN)
			src.overlays += image(src.icon, "filter-o2")
		if (src.filter_mode & MODE_NITROGEN)
			src.overlays += image(src.icon, "filter-n2")
		if (src.filter_mode & MODE_CO2)
			src.overlays += image(src.icon, "filter-co2")
		if (src.filter_mode & MODE_PLASMA)
			src.overlays += image(src.icon, "filter-tox")

/obj/machinery/atmospherics/trinary/retrofilter/process()
	..()
	if(src.status & NOPOWER)
		return

	if (!src.air3)
		return

	var/output_starting_pressure = MIXTURE_PRESSURE(src.air2)

	if(output_starting_pressure >= src.target_pressure)
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = src.target_pressure - output_starting_pressure
	var/transfer_moles = 0

	if(src.air1.temperature)
		transfer_moles = ((pressure_delta*src.air3.volume)/(src.air1.temperature * R_IDEAL_GAS_EQUATION))

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = src.air1.remove_ratio(transfer_ratio)

		var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
		if(src.air1.temperature)
			filtered_out.temperature = src.air1.temperature

		//Unlike the regular filter, we can pick and choose the gas to remove!
		//One might say that a little filter being this advanced is rather unrealistic
		//However, who gives a fuck.
		if (src.filter_mode & MODE_PLASMA)
			if(removed.toxins)
				filtered_out.toxins = removed.toxins
				removed.toxins = 0
		if (src.filter_mode & MODE_OXYGEN)
			if(removed.oxygen)
				filtered_out.oxygen = removed.oxygen
				removed.oxygen = 0
		if (src.filter_mode & MODE_NITROGEN)
			if(removed.nitrogen)
				filtered_out.nitrogen = removed.nitrogen
				removed.nitrogen = 0
		if (src.filter_mode & MODE_CO2)
			if(removed.carbon_dioxide)
				filtered_out.carbon_dioxide = removed.carbon_dioxide
				removed.carbon_dioxide = 0

		src.air2.merge(filtered_out)
		src.air3.merge(removed)

	if ((src.network3 && src.network1) && (src.network3 != src.network1))
		src.network1.merge(src.network3)
		src.network3 = src.network1

	src.network1?.update = TRUE
	src.network2?.update = TRUE
	src.network3?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	src.emagged = TRUE
	if (user)
		src.add_fingerprint(user)
		src.visible_message(SPAN_ALERT("[user] has shorted out the [src.name] with an electromagnetic card!"))
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/demag(var/mob/user)
	if (!src.emagged)
		return FALSE
	if (user)
		user.show_message(SPAN_NOTICE("You repair the [src.name]'s wiring!"))
	src.emagged = FALSE
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/attackby(obj/item/W, mob/user)
	if ((get_id_card(W)))
		src.add_fingerprint(user)
		if (src.hacked)
			boutput(user, SPAN_ALERT("Remove the foreign wires first!"))
			return

		if (src.allowed(user))
			src.locked = !src.locked
			boutput(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			src.updateUsrDialog()
			src.update_overlays()
		else
			boutput(user, SPAN_ALERT("Access denied."))
	else if (isscrewingtool(W))
		if(src.hacked)
			user.show_message(SPAN_ALERT("Remove the foreign wires first!"), 1)
			return

		src.add_fingerprint(user)
		user.show_message(SPAN_ALERT("Now [src.open ? "re" : "un"]securing the access system panel..."), 1)
		if (!do_after(user, 3 SECONDS))
			return

		src.open = !src.open
		user.show_message(SPAN_ALERT("Done!"),1)
		src.update_overlays()
		return
	else if (istype(W, /obj/item/cable_coil) && !hacked)
		if(!src.open)
			user.show_message(SPAN_ALERT("You must remove the panel first!"),1)
			return

		var/obj/item/cable_coil/C = W
		if(C.amount >= 4)
			user.show_message(SPAN_ALERT("You unravel some cable.."),1)
		else
			user.show_message(SPAN_ALERT("Not enough cable! <I>(Requires four pieces)</I>"),1)
			return

		src.add_fingerprint(user)
		user.show_message(SPAN_ALERT("Now bypassing the access system... <I>(This may take a while)</I>"), 1)
		if(!do_after(user, 10 SECONDS))
			return

		C.use(4)
		src.hacked = TRUE
		src.locked = FALSE
		src.update_overlays()
		return

	else if (issnippingtool(W) && hacked)
		src.add_fingerprint(user)
		user.show_message(SPAN_ALERT("Now removing the bypass wires... <I>(This may take a while)</I>"), 1)
		if (!do_after(user, 5 SECONDS))
			return

		src.hacked = FALSE
		src.update_overlays()
		return

	else
		..()

/obj/machinery/atmospherics/trinary/retrofilter/power_change()
	if(powered(ENVIRON))
		src.status &= ~NOPOWER
	else
		SPAWN(rand(0, 15))
			src.status |= NOPOWER

	src.update_overlays()

	UpdateIcon()
