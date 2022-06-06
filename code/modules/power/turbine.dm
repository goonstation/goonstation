/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1
	machine_registry_idx = MACHINES_MISC
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	directwired = 1
	var/turf/simulated/outturf
	var/lastgen

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel0e"
	anchored = 1
	density = 1
	circuit_type = /obj/item/circuitboard/turbine_control
	id = 0
	var/obj/machinery/compressor/compressor
	var/list/obj/machinery/door/poddoor/doors
	var/door_status = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/compressor/New()
	..()

	gas_contained = new
	inturf = get_step(src, dir)

	SPAWN(0.5 SECONDS)
		turbine = locate() in get_step(src, get_dir(inturf, src))
		if(!turbine)
			status |= BROKEN


#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800

/obj/machinery/compressor/process()
	if(!starter)
		return
	overlays = null
	if(status & BROKEN)
		return
	if(!turbine)
		status |= BROKEN
		return
	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/datum/gas_mixture/environment = inturf.return_air()
	var/transfer_moles = TOTAL_MOLES(environment)/10
	//var/transfer_moles = rpm/10000*capacity
	var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

	rpm = max(0, rpm - (rpm*rpm)/COMPFRICTION)


	if(starter && !(status & NOPOWER))
		use_power(2800)
		if(rpm<1000)
			rpmtarget = 1000
	else
		if(rpm<1000)
			rpmtarget = 0



	if(rpm>50000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o4", FLY_LAYER)
	else if(rpm>10000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o3", FLY_LAYER)
	else if(rpm>2000)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o2", FLY_LAYER)
	else if(rpm>500)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "comp-o1", FLY_LAYER)
	 //TODO: DEFERRED

/obj/machinery/power/turbine/New()
	..()

	outturf = get_step(src, dir)

	SPAWN(0.5 SECONDS)

		compressor = locate() in get_step(src, get_dir(outturf, src))
		if(!compressor)
			status |= BROKEN


#define TURBPRES 9000000
#define TURBGENQ 20000
#define TURBGENG 0.8

/obj/machinery/power/turbine/process()
	if(!compressor.starter)
		return
	overlays = null
	if(status & BROKEN)
		return
	if(!compressor)
		status |= BROKEN
		return
	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) *TURBGENQ

	add_avail(lastgen)
	var/newrpm = ((compressor.gas_contained.temperature) * TOTAL_MOLES(compressor.gas_contained))/4
	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if(TOTAL_MOLES(compressor.gas_contained)>0)
		var/oamount = min(TOTAL_MOLES(compressor.gas_contained), (compressor.rpm+100)/35000*compressor.capacity)
		var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

	if(lastgen > 100)
		overlays += image('icons/obj/atmospherics/pipes.dmi', "turb-o", FLY_LAYER)


	src.updateDialog()


/obj/machinery/power/turbine/attack_ai(mob/user)

	if(status & (BROKEN|NOPOWER))
		return

	interacted(user)

/obj/machinery/power/turbine/attack_hand(mob/user)

	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return

	interacted(user)

/obj/machinery/power/turbine/proc/interacted(mob/user)

	if ( (BOUNDS_DIST(src, user) > 0 ) || (status & (NOPOWER|BROKEN)) && (!isAI(user)) )
		src.remove_dialog(user)
		user.Browse(null, "window=turbine")
		return

	src.add_dialog(user)

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	t += "Generated power : [round(lastgen)] W<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user.Browse(t, "window=turbine")
	onclose(user, "turbine")

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	..()
	if(status & BROKEN)
		return
	if (usr.stat || usr.restrained() )
		return

	if (( usr.using_dialog_of(src) && ((BOUNDS_DIST(src, usr) == 0) && istype(src.loc, /turf))) || (isAI(usr)))
		if( href_list["close"] )
			usr.Browse(null, "window=turbine")
			src.remove_dialog(usr)
			return

		else if( href_list["str"] )
			compressor.starter = !compressor.starter

		SPAWN(0)
			for(var/mob/M in viewers(1, src))
				if (M.using_dialog_of(src))
					src.interacted(M)

	else
		usr.Browse(null, "window=turbine")
		src.remove_dialog(usr)

	return





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/obj/machinery/computer/turbine_computer/New()
	..()
	SPAWN(0.5 SECONDS)
		for(var/obj/machinery/compressor/C in machine_registry[MACHINES_MISC])
			if(id == C.comp_id)
				compressor = C
		doors = new /list()
		for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door])
			if(P.id == id)
				doors += P

/obj/machinery/computer/turbine_computer/attack_hand(var/mob/user)
	src.add_dialog(user)
	var/dat
	if(src.compressor)
		dat += {"<BR><B>Gas turbine remote control system</B><HR>
		<br>Turbine status: [ src.compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]
		<br><BR>
		<br>Turbine speed: [src.compressor.rpm]rpm<BR>
		<br>Power currently being generated: [src.compressor.turbine.lastgen]W<BR>
		<br>Internal gas temperature: [src.compressor.gas_contained.temperature]K<BR>
		<br>Vent doors: [ src.door_status ? "<A href='?src=\ref[src];doors=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];doors=1'>Open</A>"]
		<br></PRE><HR><A href='?src=\ref[src];view=1'>View</A>
		<br></PRE><HR><A href='?src=\ref[src];close=1'>Close</A>
		<br><BR>
		<br>"}
	else
		dat += "<span style=\"color:red\"><B>No compatible attached compressor found.</span>"

	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/robotics/special_deconstruct(obj/computerframe/frame as obj)
	frame.circuit.id = src.id

/obj/machinery/computer/turbine_computer/attack_ai(mob/user as mob)
	// overridden to prevent AI from accessing
	return

/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

		if( href_list["view"] )
			usr.client.eye = src.compressor
		else if( href_list["str"] )
			src.compressor.starter = !src.compressor.starter
		else if (href_list["doors"])
			for(var/obj/machinery/door/poddoor/D in src.doors)
				if (door_status == 0)
					SPAWN( 0 )
						D.open()
						door_status = 1
				else
					SPAWN( 0 )
						D.close()
						door_status = 0
		else if( href_list["close"] )
			usr.Browse(null, "window=computer")
			src.remove_dialog(usr)
			return

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return
