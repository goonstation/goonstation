/*CONTENTS
Gas Sensor
Siphon computer
Atmos alert computer
*/

/obj/machinery/computer/atmosphere
	name = "atmos"

	lr = 0.85
	lg = 0.86
	lb = 1

/obj/machinery/computer/atmosphere/alerts
	name = "Alert Computer"
	icon_state = "atmos"
	var/alarms = list("Fire"=list(), "Atmosphere"=list())
	machine_registry_idx = MACHINES_ATMOSALERTS

/obj/machinery/computer/atmosphere/siphonswitch
	name = "Area Air Control"
	icon_state = "atmos"
	var/otherarea
	var/area/area

/obj/machinery/computer/atmosphere/mixercontrol
	name = "Gas Mixer Control"
	icon_state = "atmos"


/obj/machinery/computer/atmosphere/siphonswitch/mastersiphonswitch
	name = "Master Air Control"


//the atmos alerts computer
/obj/machinery/computer/atmosphere/alerts/attack_ai(mob/user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/computer/atmosphere/alerts/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/computer/atmosphere/alerts/attackby(var/obj/item/I as obj, user as mob)
	if (isscrewingtool(I))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 2 SECONDS))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)
				var/obj/item/circuitboard/atmospherealerts/M = new /obj/item/circuitboard/atmospherealerts( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/atmospherealerts/M = new /obj/item/circuitboard/atmospherealerts( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return


/obj/machinery/computer/atmosphere/alerts/proc/interacted(mob/user)
	src.add_dialog(usr)
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
	dat += "<A HREF='?action=mach_close&window=alerts'>Close</A><br><br>"
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR><br>", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "[A.name]"
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR><br>"
		else
			dat += "-- All Systems Nominal<BR><br>"
		dat += "<BR><br>"
	user.Browse(dat, "window=alerts")
	onclose(user, "alerts")

/obj/machinery/computer/atmosphere/alerts/Topic(href, href_list)
	if(..())
		return
	return

/obj/machinery/computer/atmosphere/alerts/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(status & (BROKEN|NOPOWER))
		return
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1

/obj/machinery/computer/atmosphere/alerts/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(status & (BROKEN|NOPOWER))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	return !cleared
