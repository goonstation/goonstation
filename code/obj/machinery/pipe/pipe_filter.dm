// *** pipefilter

/obj/machinery/pipefilter/New()
	..()
	p_dir = (NORTH|SOUTH|EAST|WEST) ^ turn(dir, 180)

	gas = new /datum/gas_mixture
	ngas = new /datum/gas_mixture

	f_gas = new /datum/gas_mixture
	f_ngas = new /datum/gas_mixture

	gasflowlist += src

/obj/machinery/pipefilter/disposing()
	if(gas)
		qdel(gas)
	if(ngas)
		qdel(ngas)
	if(f_gas)
		qdel(f_gas)
	if(f_ngas)
		qdel(f_ngas)
	..()

/obj/machinery/pipefilter/buildnodes()
	var/turf/T = src.loc

	n1dir = turn(dir, 90)
	n2dir = turn(dir,-90)

	node1 = get_machine( level, T , n1dir )	// the main flow dir
	node2 = get_machine( level, T , n2dir )
	node3 = get_machine( level, T, dir )	// the ejector port

	if(node1) vnode1 = node1.getline()
	if(node2) vnode2 = node2.getline()
	if(node3) vnode3 = node3.getline()

/obj/machinery/pipefilter/gas_flow()
	gas.copy_from(ngas)
	f_gas.copy_from(f_ngas)

/obj/machinery/pipefilter/process()
/*	var/delta_gt

	if(vnode1)
		delta_gt = FLOWFRAC * ( vnode1.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode1, delta_gt)
	else
		leak_to_turf(1)
	if(vnode2)
		delta_gt = FLOWFRAC * ( vnode2.get_gas_val(src) - TOTAL_MOLES(gas) / capmult)
		calc_delta( src, gas, ngas, vnode2, delta_gt)
	else
		leak_to_turf(2)
	if(vnode3)
		delta_gt = FLOWFRAC * ( vnode3.get_gas_val(src) - TOTAL_MOLES(f_gas) / capmult)
		calc_delta( src, f_gas, f_ngas, vnode3, delta_gt)
	else
		leak_to_turf(3)

	// transfer gas from ngas->f_ngas according to extraction rate, but only if we have power
	if(! (status & NOPOWER) )
		use_power(min(src.f_per, 100),ENVIRON)
		var/datum/gas_mixture/ndelta = src.get_extract()
		ngas.sub_delta(ndelta)
		f_ngas.add_delta(ndelta)
	AutoUpdateAI(src)
	src.updateUsrDialog()*/ //TODO: FIX

/obj/machinery/pipefilter/get_gas_val(from)
	return ((from == vnode3) ? TOTAL_MOLES(f_gas) : TOTAL_MOLES(gas))/capmult

/obj/machinery/pipefilter/get_gas(from)
	return (from == vnode3) ? f_gas : gas

/obj/machinery/pipefilter/proc/leak_to_turf(var/port)
	var/turf/T

	switch(port)
		if(1)
			T = get_step(src, n1dir)
		if(2)
			T = get_step(src, n2dir)
		if(3)
			T = get_step(src, dir)
			if(T.density)
				T = src.loc
				if(T.density)
					return
			flow_to_turf(f_gas, f_ngas, T)
			return

	if(T.density)
		T = src.loc
		if(T.density)
			return

	flow_to_turf(gas, ngas, T)

/obj/machinery/pipefilter/proc/get_extract()
	/*
	var/datum/gas_mixture/ndelta = new()
	if (src.f_mask & GAS_O2)
		ndelta.oxygen = min(src.f_per, src.ngas.oxygen)
	if (src.f_mask & GAS_N2)
		ndelta.n2 = min(src.f_per, src.ngas.n2)
	if (src.f_mask & GAS_PL)
		ndelta.plasma = min(src.f_per, src.ngas.plasma)
	if (src.f_mask & GAS_CO2)
		ndelta.co2 = min(src.f_per, src.ngas.co2)
	if (src.f_mask & GAS_N2O)
		ndelta.sl_gas = min(src.f_per, src.ngas.sl_gas)
	return ndelta
	*/ //TODO: FIX

/obj/machinery/pipefilter/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/weapon/detective_scanner))
		return ..()
	if (isscrewingtool(W))
		if(bypassed)
			user.show_message(text("<span class='alert'>Remove the foreign wires first!</span>"), 1)
			return
		src.add_fingerprint(user)
		user.show_message(text("<span class='alert'>Now []securing the access system panel...</span>", (src.locked) ? "un" : "re"), 1)
		sleep(3 SECONDS)
		locked =! locked
		user.show_message(text("<span class='alert'>Done!</span>"),1)
		src.UpdateIcon()
		return
	if(istype(W, /obj/item/weapon/cable_coil) && !bypassed)
		if(src.locked)
			user.show_message(text("<span class='alert'>You must remove the panel first!</span>"),1)
			return
		var/obj/item/weapon/cable_coil/C = W
		if(C.use(4))
			user.show_message(text("<span class='alert'>You unravel some cable..</span>"),1)
		else
			user.show_message(text("<span class='alert'>Not enough cable! <I>(Requires four pieces)</I></span>"),1)
		src.add_fingerprint(user)
		user.show_message(text("<span class='alert'>Now bypassing the access system... <I>(This may take a while)</I></span>"), 1)
		sleep(10 SECONDS)
		bypassed = 1
		src.UpdateIcon()
		return
	if (issnippingtool(W) && bypassed)
		src.add_fingerprint(user)
		user.show_message(text("<span class='alert'>Now removing the bypass wires... <I>(This may take a while)</I></span>"), 1)
		sleep(5 SECONDS)
		bypassed = 0
		src.UpdateIcon()
		return
	if(istype(W, /obj/item/weapon/card/emag) && (!emagged))
		emagged++
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='alert'>[] has shorted out the [] with an electromagnetic card!</span>", user, src), 1)
		src.overlays += image('pipes2.dmi', "filter-spark")
		sleep(0.6 SECONDS)
		src.UpdateIcon()
		return src.Attackhand(user)
	return src.Attackhand(user)

// pipefilter interact/topic
/obj/machinery/pipefilter/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/pipefilter/attack_hand(mob/user)
/*	if(status & NOPOWER)
		user << browse(null, "window=pipefilter")
		user.machine = null
		return

	var/list/gases = list("O2", "N2", "Plasma", "CO2", "N2O")
	src.add_dialog(user)
	var/dat = "Filter Release Rate:<BR><br><A href='?src=\ref[src];fp=-[num2text(src.maxrate, 9)]'>M</A> <A href='?src=\ref[src];fp=-100000'>-</A> <A href='?src=\ref[src];fp=-10000'>-</A> <A href='?src=\ref[src];fp=-1000'>-</A> <A href='?src=\ref[src];fp=-100'>-</A> <A href='?src=\ref[src];fp=-1'>-</A> [src.f_per] <A href='?src=\ref[src];fp=1'>+</A> <A href='?src=\ref[src];fp=100'>+</A> <A href='?src=\ref[src];fp=1000'>+</A> <A href='?src=\ref[src];fp=10000'>+</A> <A href='?src=\ref[src];fp=100000'>+</A> <A href='?src=\ref[src];fp=[num2text(src.maxrate, 9)]'>M</A><BR><br>"
	for (var/i = 1; i <= gases.len; i++)
		dat += "[gases[i]]: <A HREF='?src=\ref[src];tg=[1 << (i - 1)]'>[(src.f_mask & 1 << (i - 1)) ? "Releasing" : "Passing"]</A><BR><br>"
	if(TOTAL_MOLES(gas))
		var/totalgas = TOTAL_MOLES(gas)
		var/pressure = round(totalgas / gas.maximum * 100)
		var/nitrogen = gas.n2 / totalgas * 100
		var/oxygen = gas.oxygen / totalgas * 100
		var/plasma = gas.plasma / totalgas * 100
		var/co2 = gas.co2 / totalgas * 100
		var/no2 = gas.sl_gas / totalgas * 100

		dat += "<BR>Gas Levels: <BR><br>Pressure: [pressure]%<BR><br>Nitrogen: [nitrogen]%<BR><br>Oxygen: [oxygen]%<BR><br>Plasma: [plasma]%<BR><br>CO2: [co2]%<BR><br>N2O: [no2]%<BR><br>"
	else
		dat += "<BR>Gas Levels: <BR><br>Pressure: 0%<BR><br>Nitrogen: 0%<BR><br>Oxygen: 0%<BR><br>Plasma: 0%<BR><br>CO2: 0%<BR><br>N2O: 0%<BR><br>"
	dat += "<BR><br><A href='?src=\ref[src];close=1'>Close</A><BR><br>"

	user << browse(dat, "window=pipefilter;size=300x365")*/ //TODO: FIX
	//onclose(user, "pipefilter")

/obj/machinery/pipefilter/Topic(href, href_list)
	..()
	if(usr.restrained() || usr.lying)
		return
	if ((((BOUNDS_DIST(src, usr) == 0 || usr.telekinesis == 1) || isAI(usr)) && istype(src.loc, /turf)))
		src.add_dialog(usr)
		if (href_list["close"])
			usr << browse(null, "window=pipefilter;")
			usr.machine = null
			return
		if (src.allowed(usr) || src.emagged || src.bypassed)
			if (href_list["fp"])
				src.f_per = clamp(round(src.f_per + text2num_safe(href_list["fp"])), 0, src.maxrate)
			else if (href_list["tg"])
				// toggle gas
				src.f_mask ^= text2num_safe(href_list["tg"])
				src.UpdateIcon()
		else
			usr.see("<span class='alert'>Access Denied ([src.name] operation restricted to authorized atmospheric technicians.)</span>")
		AutoUpdateAI(src)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=pipefilter")
		usr.machine = null
		return

/obj/machinery/pipefilter/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else
		status |= NOPOWER
	SPAWN(rand(1,15))	//so all the filters don't come on at once
		UpdateIcon()

/obj/machinery/pipefilter/UpdateIcon()
	src.overlays = null
	if(status & NOPOWER)
		icon_state = "filter-off"
	else
		icon_state = "filter"
		if(emagged)	//only show if powered because presumeably its the interface that has been fried
			src.overlays += image('pipes2.dmi', "filter-emag")
		if (src.f_mask & (GAS_N2O|GAS_PL))
			src.overlays += image('pipes2.dmi', "filter-tox")
		if (src.f_mask & GAS_O2)
			src.overlays += image('pipes2.dmi', "filter-o2")
		if (src.f_mask & GAS_N2)
			src.overlays += image('pipes2.dmi', "filter-n2")
		if (src.f_mask & GAS_CO2)
			src.overlays += image('pipes2.dmi', "filter-co2")
	if(!locked)
		src.overlays += image('pipes2.dmi', "filter-open")
		if(bypassed)	//should only be bypassed if unlocked
			src.overlays += image('pipes2.dmi', "filter-bypass")
