// Currently only used to control /obj/machinery/inlet/filter
// todo: expand to vent control as well?

/obj/machinery/filter_control
	power_usage = 5
	power_channel = ENVIRON

/obj/machinery/filter_control/New()
	..()
	SPAWN(0.5 SECONDS)	//wait for world
		for(var/obj/machinery/inlet/filter/F as anything in machine_registry[MACHINES_INLETS])
			if(F.control == src.control)
				F.f_mask = src.f_mask
		desc = "A remote control for a filter: [control]"

/obj/machinery/filter_control/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/filter_control/attackby(obj/item/weapon/W, mob/user as mob)
	if (istype(W, /obj/item/weapon/detective_scanner))
		return ..()
	if (isscrewingtool(W))
		src.add_fingerprint(user)
		user.show_message(text("<span class='alert'>Now [] the panel...</span>", (src.locked) ? "unscrewing" : "reattaching"), 1)
		sleep(3 SECONDS)
		src.locked =! src.locked
		src.UpdateIcon()
		return
	if (issnippingtool(W) && !src.locked)
		status ^= BROKEN
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='alert'>[] has []activated []!</span>", user, (stat&BROKEN) ? "de" : "re", src), 1)
		src.UpdateIcon()
		return
	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		emagged++
		for(var/mob/O in viewers(user, null))
			O.show_message(text("<span class='alert'>[] has shorted out the []'s access system with an electromagnetic card!</span>", user, src), 1)
		src.UpdateIcon()
		return src.Attackhand(user)
	return src.Attackhand(user)

/obj/machinery/filter_control/process()
	if(!(status & NOPOWER))
		..()
		AutoUpdateAI(src)
		src.updateUsrDialog()
	src.UpdateIcon()

/obj/machinery/filter_control/attack_hand(mob/user)
	if(status & NOPOWER)
		user << browse(null, "window=filter_control")
		user.machine = null
		return
	if(user.stat || user.lying)
		return
	if ((BOUNDS_DIST(src, user) > 0 || !istype(src.loc, /turf)) && !isAI(user))
		return 0

	var/list/gases = list("O2", "N2", "Plasma", "CO2", "N2O")
	var/dat
	src.add_dialog(user)

	var/IGoodConnection = 0
	var/IBadConnection = 0

	for(var/obj/machinery/inlet/filter/F as anything in machine_registry[MACHINES_INLETS])
		if((F.control == src.control) && !(F.stat && (NOPOWER|BROKEN)))
			IGoodConnection++
		else if(F.control == src.control)
			IBadConnection++
	var/ITotalConnections = IGoodConnection+IBadConnection

	if(ITotalConnections && !(status & BROKEN))	//ugly
		dat += "Connection status: Inlets:[ITotalConnections]/[IGoodConnection]<BR><br>Control ID: [control]<BR><BR><br>"
	else
		dat += "<font color=red>No Connections Detected!</font><BR><br>Control ID: [control]<BR><br>"
	if(!status & BROKEN)
		for (var/i = 1; i <= gases.len; i++)
			dat += "[gases[i]]: <A HREF='?src=\ref[src];tg=[1 << (i - 1)]'>[(src.f_mask & 1 << (i - 1)) ? "Siphoning" : "Passing"]</A><BR><br>"
	else
		dat += "<big><font color='red'>Warning! Severe Internal Memory Corruption!</big><BR><br><BR><br>Consult a qualified station technician immediately!</font><BR><br>"
		dat += "<BR><br><small>Error codes: 0x0000001E 0x0000007B</small><BR><br>"

	dat += "<BR><br><A href='?src=\ref[src];close=1'>Close</A><BR><br>"
	user << browse(dat, "window=filter_control;size=300x225")
	onclose(user, "filter_control")
/obj/machinery/filter_control/Topic(href, href_list)
	if (href_list["close"])
		usr << browse(null, "window=filter_control;")
		usr.machine = null
		return	//Who cares if we're dead or whatever let us close the fucking window
	if(..())
		return
	if ((((BOUNDS_DIST(src, usr) == 0 || usr.telekinesis == 1) || isAI(usr)) && isturf(src.loc)))
		src.add_dialog(usr)
		if (src.allowed(usr) || src.emagged && !(status & BROKEN))
			if (href_list["tg"])	//someone modified the html so I added a check here
				// toggle gas
				src.f_mask ^= text2num_safe(href_list["tg"])
				for(var/obj/machinery/inlet/filter/FI as anything in machine_registry[MACHINES_INLETS])
					if(FI.control == src.control)
						FI.f_mask ^= text2num_safe(href_list["tg"])
		else
			usr.see("<span class='alert'>Access Denied ([src.name] operation restricted to authorized atmospheric technicians.)</span>")
		AutoUpdateAI(src)
		src.updateUsrDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=filter_control")
		usr.machine = null
		return

/obj/machinery/filter_control/UpdateIcon()
	overlays = null
	if(status & NOPOWER)
		icon_state = "filter_control-nopower"
		return
	icon_state = "filter_control"
	if(src.locked && (status & BROKEN))
		overlays += image('icons/obj/stationobjs.dmi', "filter_control00")
		return
	else if(!src.locked)
		icon_state = "filter_control-unlocked"
		if(status & BROKEN)
			overlays += image('icons/obj/stationobjs.dmi', "filter_control-wirecut")
			overlays += image('icons/obj/stationobjs.dmi', "filter_control00")
			return

	var/GoodConnection = 0
	for(var/obj/machinery/inlet/filter/F as anything in machine_registry[MACHINES_INLETS])
		if((F.control == src.control) && !(F.stat && (NOPOWER|BROKEN)))
			GoodConnection++
			break

	if(GoodConnection && src.f_mask)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control1")
	else if(GoodConnection)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control10")
	else if(src.f_mask)
		overlays += image('icons/obj/stationobjs.dmi', "filter_control0")
	else
		overlays += image('icons/obj/stationobjs.dmi', "filter_control00")

	if (src.f_mask & (GAS_N2O|GAS_PL))
		src.overlays += image('icons/obj/stationobjs.dmi', "filter_control-tox")
	if (src.f_mask & GAS_O2)
		src.overlays += image('icons/obj/stationobjs.dmi', "filter_control-o2")
	if (src.f_mask & GAS_N2)
		src.overlays += image('icons/obj/stationobjs.dmi', "filter_control-n2")
	if (src.f_mask & GAS_CO2)
		src.overlays += image('icons/obj/stationobjs.dmi', "filter_control-co2")
	return

/obj/machinery/filter_control/power_change()
	if(powered(ENVIRON))
		status &= ~NOPOWER
	else
		status |= NOPOWER
	SPAWN(rand(1,15))
		src.UpdateIcon()
	return
