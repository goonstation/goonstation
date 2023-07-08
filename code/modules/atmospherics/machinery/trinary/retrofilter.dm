//Ye olde filter of yore (Pre-dev adjustable filter)

//TODO: Make this more modular and use APPLY_TO_GASES

//TODO: Hacking.
#define MODE_OXYGEN (1<<0)
#define MODE_NITROGEN (1<<1)
#define MODE_CO2 (1<<2)
#define MODE_PLASMA (1<<3)

/obj/machinery/atmospherics/trinary/retrofilter
	icon = 'icons/obj/atmospherics/retro_filter.dmi'
	icon_state = "intact_off"
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
	if(node1&&node2&&node3)
		icon_state = "intact_[(status & NOPOWER)?("off"):("on")]"
	else
		icon_state = "" //bad but am lazy to make icons rn planning for a later retrofilter pr
		status |= NOPOWER

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
			dat += "[gases[i]]: <a href='?src=\ref[src];toggle_gas=[1 << (i - 1)]'>[(src.filter_mode & (1 << (i - 1))) ? "Releasing" : "Passing"]</a><br>"

	var/pressure = MIXTURE_PRESSURE(air1)
	var/total_moles = TOTAL_MOLES(air1)

	dat += "<hr>Gas Levels: <br>Gas Pressure: [round(pressure,0.1)] kPa<br><br>"

	if (total_moles)
		var/o2_level = air1.oxygen/total_moles
		var/n2_level = air1.nitrogen/total_moles
		var/co2_level = air1.carbon_dioxide/total_moles
		var/plasma_level = air1.toxins/total_moles
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

/obj/machinery/atmospherics/trinary/retrofilter/Topic(href, href_list)
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
		if (filter_mode & MODE_OXYGEN)
			src.overlays += image(src.icon, "filter-o2")
		if (filter_mode & MODE_NITROGEN)
			src.overlays += image(src.icon, "filter-n2")
		if (filter_mode & MODE_CO2)
			src.overlays += image(src.icon, "filter-co2")
		if (filter_mode & MODE_PLASMA)
			src.overlays += image(src.icon, "filter-tox")

/obj/machinery/atmospherics/trinary/retrofilter/process()
	..()
	if(status & NOPOWER)
		return

	if (!air3)
		return

	var/output_starting_pressure = MIXTURE_PRESSURE(air2)

	if(output_starting_pressure >= target_pressure)
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles = 0

	if(air1.temperature)
		transfer_moles = ((pressure_delta*air3.volume)/(air1.temperature * R_IDEAL_GAS_EQUATION))

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

		var/datum/gas_mixture/filtered_out = new /datum/gas_mixture
		if(air1.temperature)
			filtered_out.temperature = air1.temperature

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

		air2.merge(filtered_out)
		air3.merge(removed)

	if ((network3 && network1) && (network3 != network1))
		network1.merge(network3)
		network3 = network1

	network1?.update = TRUE
	network2?.update = TRUE
	network3?.update = TRUE

	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.emagged)
		return FALSE
	src.emagged = TRUE
	if (user)
		src.add_fingerprint(user)
		src.visible_message("<span class='alert'>[user] has shorted out the [src.name] with an electromagnetic card!</span>")
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/demag(var/mob/user)
	if (!src.emagged)
		return FALSE
	if (user)
		user.show_message("<span class='notice'>You repair the [src.name]'s wiring!</span>")
	src.emagged = FALSE
	src.update_overlays()
	return TRUE

/obj/machinery/atmospherics/trinary/retrofilter/attackby(obj/item/W, mob/user)
	if ((get_id_card(W)))
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
		if(!do_after(user, 10 SECONDS))
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

/obj/machinery/atmospherics/trinary/retrofilter/power_change()
	if( powered(ENVIRON) )
		status &= ~NOPOWER
	else
		SPAWN(rand(0, 15))
			status |= NOPOWER

	src.update_overlays()

	UpdateIcon()
