/obj/machinery/sim/transmitter
	name = "Sim Mainframe"
	desc = "Controls the simulation room and V-space"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "mastercomp"
	anchored = ANCHORED
	density = 1
	power_usage = 100
	var/active = 1
	var/id = 1
	var/vspace_id = 1
	var/network = "none"
	var/linked_space = null
	var/list/programs = list()		//loaded programs
	var/list/chairs = list()		//Chairs that are ran by this machine
	var/list/disks = list()			//Disks inside the machine

/*
/obj/machinery/sim/transmitter/New()
	SPAWN(1 SECOND)
		Connect()
	..()
*/

/obj/machinery/sim/transmitter/process()
	if(status & (NOPOWER|BROKEN))
		src.active = 0
		for(var/obj/machinery/sim/chair/C in orange(9,src))
			if(!C.active)
				continue
			if(C.con_user)
				C.con_user.network_device = null
				C.active = 0
		return
	else
		if(!active)
			src.active = 1

	..()
//	src.updateDialog()

/*
/obj/machinery/sim/transmitter/proc/Connect()
	for(var/obj/machinery/sim/chair/C in machines)
		if(C.id == src.id)
			chairs.Add(C)
	return


/obj/machinery/sim/transmitter/attack_ai(mob/user)
	return
//	add_fingerprint(user)
//	if(status & (BROKEN|NOPOWER))
//		return
//	interact(user)


/obj/machinery/sim/transmitter/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interact(user)



/obj/machinery/sim/transmitter/proc/interact(mob/user)
	if ( (BOUNDS_DIST(src, user) > 0 ) || (status & (BROKEN|NOPOWER)) )
		if (!issilicon(user))
			user.machine = null
			user.Browse(null, "window=mm")
			return

	src.add_dialog(user)
	var/dat = "<HEAD><TITLE>V-space Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
	dat += "<A HREF='?action=mach_close&window=mm'>Close</A><br><br>"

	dat += {"<B>System Status:</B>[active] <BR>
	<A href='byond://?src=\ref[src];setup=1'>Setup System</A><BR>"}


	for(var/obj/machinery/sim/chair/C in chairs)
		dat +={"
*------------------------------*<BR>
<B>Chair #[C.internal_id]:</B><BR>
"}
		if(C.active)
			var/M = C.con_user
			if(ishuman(M))
				dat += {"
<B>General Information:</B><BR>
<BR>
<B>Name:</B> [M:real_name]<BR>
<B>Age:</B> [M:age]<BR>
<B>Health:</B> [M:health]<BR>
<B>Status:</B> [M:stat ? "Non-responsive" : "Stable"]<BR>
"}
			else
				dat += {"
<B>Nonhuman user detected</B><BR>
"}
		else
			dat += {"<B>Not active</B> <BR>"}




	user.Browse(dat, "window=mm")
	onclose(user, "mm")

/obj/machinery/sim/transmitter/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["setup"])
			if(active)
				boutput(usr, "System already set up.")
				return//Might add in some pre setup prefs here
			active = 1

	return

*/

/obj/machinery/sim/chair
	name = "Sim Chair"
	desc = "Lets a user access V-space"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "simchair"
	anchored = ANCHORED
	density = 0
	machine_registry_idx = MACHINES_SIM
	var/active = 0
	var/id = 0
	var/internal_id = 0
	var/network = "none"
	var/mob/living/con_user = null

/obj/machinery/sim/chair/MouseDrop_T(mob/M as mob, mob/user as mob)
	if (!ticker)
		boutput(user, "You can't buckle anyone in before the game starts.")
		return
	if ((!( iscarbon(M) ) || BOUNDS_DIST(src, user) > 0 || M.loc != src.loc || user.restrained() || user.stat))
		return
	if (M.buckled)	return

	if (M == user)
		user.visible_message(SPAN_NOTICE("[user] buckles in!"))
	else
		M.visible_message(SPAN_NOTICE("[M] is buckled in by [user]!"))

	M.anchored = ANCHORED
	M.buckled = src
	M.set_loc(src.loc)
	M.network_device = src
	src.con_user = M
	src.active = 1
	Station_VNet.Enter_Vspace(M, M.network_device,M.network_device:network)
	src.add_fingerprint(user)
	return

/obj/machinery/sim/chair/attack_hand(mob/user)
	if (src.con_user)
		var/mob/living/M = src.con_user
		if (M != user)
			M.visible_message(SPAN_NOTICE("[M] is unbuckled by [user]."))
		else
			M.visible_message(SPAN_NOTICE("[M] is unbuckles."))

		M.anchored = UNANCHORED
		M.buckled = null
		M.network_device = null
		src.active = 0
		src.con_user = null
		src.add_fingerprint(user)
	return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//A VR-Bed to replace the stupid chairs.

/obj/machinery/sim/vr_bed
	name = "VR containment unit"
	desc = "An advanced pod that lets the user enter V-space"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "vrbed"//_0"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_MULTITOOL
	machine_registry_idx = MACHINES_SIM
	var/active = 0
	var/internal_id = 0
	var/network = "none"
	var/mob/living/con_user = null
	var/mob/occupant = null
	var/image/image_lid = null
	var/time = 30
	var/timing = 0
	var/last_tick = 0
	//var/emagged = 0

/obj/machinery/sim/vr_bed/New()
	..()
	src.UpdateIcon()

/obj/machinery/sim/vr_bed/disposing()
	go_out()
	. = ..()


/obj/machinery/sim/vr_bed/update_icon()
	ENSURE_IMAGE(src.image_lid, src.icon, "lid[!isnull(occupant)]")
	src.UpdateOverlays(src.image_lid, "lid")

/obj/machinery/sim/vr_bed/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/grab))
		var/obj/item/grab/G = O
		if (!ismob(G.affecting))
			return
		if (src.occupant)
			boutput(user, SPAN_NOTICE("<B>The VR pod is already occupied!</B>"))
			return
		if(..())
			return
		var/dat = "<HTML><BODY><TT><B>VR pod timer</B>"
		src.add_dialog(user)
		var/d2
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Timed</A><br>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time</A><br>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		dat += text("<br><HR><br>Timer System: [d2]<br>Time Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-5'>-</A> <A href='?src=\ref[src];tp=5'>+</A> <A href='?src=\ref[src];tp=30'>+</A>")
		dat += text("<BR><BR><A href='?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
		user.Browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")

		if (G)
			src.log_in(G.affecting)
			qdel(G)
		src.add_fingerprint(user)
		return

/obj/machinery/sim/vr_bed/proc/log_in(mob/M as mob)
	if (src.occupant && !isobserver(M))
		if(M == src.occupant)
			return src.go_out()
		boutput(M, SPAN_NOTICE("<B>The VR pod is already occupied!</B>"))
		return

	if (!iscarbon(M) && !isobserver(M))
		boutput(M, SPAN_NOTICE("<B>You cannot possibly fit into that!</B>"))
		return

	if (!isobserver(M) || isAIeye(M))
		M.set_loc(src)
		M.network_device = src
		//M.verbs += /mob/proc/jack_in
		src.occupant = M
		src.con_user = M
		src.active = 1
	/*
	if(src.emagged)
		boutput(M, "You feel a terrible pain in your head, and everything goes black...")
		M.paralysis += 5
		sleep(0.5 SECONDS)
		M.set_loc(pick(mazewarp))
		return
	*/
	//Station_VNet.Enter_Vspace(M, M.network_device, M.network_device:network)
	Station_VNet.Enter_Vspace(M, src, src.network)
	for(var/obj/O in src)
		O.set_loc(src.loc)
	src.UpdateIcon()
	return

/obj/machinery/sim/vr_bed/Click(location,control,params)
	var/lpm = params2list(params)
	if(isobserver(usr) && !lpm["ctrl"] && !lpm["shift"] && !lpm["alt"] && alert("Are you sure you want to enter VR?","Are you sure?","Yes","No") == "Yes")
		src.move_inside()
	else return ..()

/obj/machinery/sim/vr_bed/verb/move_inside()
	set src in oview(1)
	set category = "Local"

	if (!Station_VNet) return
	//if(isobserver(usr)) //let ghosts have their VR fun!
	//	Station_VNet.Enter_Vspace(usr, src, src:network)
	//	return

	if (is_incapacitated(usr) && !isobserver(usr))
		return
	src.log_in(usr)
	src.add_fingerprint(usr)
	if (!isobserver(usr))
		playsound(src, 'sound/machines/sleeper_close.ogg', 50, 1)
	return

/obj/machinery/sim/vr_bed/MouseDrop_T(mob/living/target, mob/user)
	if (BOUNDS_DIST(user, src) > 0 || !in_interact_range(src,user)) return
	if (target == user)
		move_inside()

/obj/machinery/sim/vr_bed/verb/move_eject()
	set src in oview(1)
	set category = "Local"
	if (!isalive(usr) || usr.getStatusDuration("stunned") !=0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sim/vr_bed/relaymove(mob/user as mob, dir)
	if (user == src.occupant && (user.canmove))
		src.go_out()
		add_fingerprint(user)
		return

	return

/obj/machinery/sim/vr_bed/remove_air(amount)
	return src.loc.remove_air(amount)

/obj/machinery/sim/vr_bed/attack_hand(var/mob/user)
	if(..())
		return
	var/dat = "<HTML><BODY><TT><B>VR pod timer</B>"
	src.add_dialog(user)
	var/d2
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Timed</A><br>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time</A><br>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<br><HR><br>Timer System: [d2]<br>Time Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-5'>-</A> <A href='?src=\ref[src];tp=5'>+</A> <A href='?src=\ref[src];tp=30'>+</A>")
	dat += text("<BR><BR><A href='?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	src.add_fingerprint(user)
	return

/obj/machinery/sim/vr_bed/proc/go_out()
	for(var/obj/O in src)
		O.set_loc(get_turf(src.loc))
//	src.verbs -= /mob/proc/jack_in
	src.occupant?.set_loc(get_turf(src.loc))
	src.occupant?.changeStatus("knockdown", 2 SECONDS)
	src.occupant?.network_device = null
	src.occupant = null
	src.active = 0
	src.con_user = null
	src.UpdateIcon()
	playsound(src, 'sound/machines/sleeper_open.ogg', 50, 1)
	return

/obj/machinery/sim/vr_bed/Exited(atom/movable/thing, newloc)
	. = ..()
	if(thing == src.occupant && (!isobserver(thing) || isAIeye(thing)))
		src.go_out()

/obj/machinery/sim/vr_bed/process()
	..()
	if (src.timing)
		if (!last_tick) last_tick = world.time
		var/passed_time = round(max(round(world.time - last_tick),10) / 10)
		if (src.time > 0)
			src.time -= passed_time
		else
			done()
			src.time = 0
			src.timing = 0
			last_tick = 0
		last_tick = world.time
	else
		last_tick = 0
	return

/obj/machinery/sim/vr_bed/proc/done()
	if(status & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/sim/vr_bed/C in machine_registry[MACHINES_SIM])
		if(!C.active)
			continue
		if(C.con_user)
			C.con_user.network_device = null
			C.active = 0
			src.go_out()

/obj/machinery/sim/vr_bed/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["time"])
			if(src.allowed(usr))
				src.timing = text2num_safe(href_list["time"])
		else
			if (href_list["tp"])
				if(src.allowed(usr))
					var/tp = text2num_safe(href_list["tp"])
					src.time += tp
					src.time = clamp(round(src.time), 0, 300)
		src.updateUsrDialog()
	return

///////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/sim/programcomp
	name = "Sim Computer"
	desc = "Controls part of V-space"
	icon = 'icons/misc/simroom.dmi'
	icon_state = "simcomp"
	anchored = ANCHORED
	density = 1
	var/id = "none"
	var/network = "none"
	var/list/programs = list()		//loaded programs


/obj/machinery/sim/programcomp/proc/interacted(mob/user)
	if ( (!in_interact_range(src,user)) || (status & (BROKEN|NOPOWER)) )
		src.remove_dialog(user)
		user.Browse(null, "window=mm")
		return

	src.add_dialog(user)
	var/dat = "<HEAD><TITLE>V-space Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
	dat += "<A HREF='?action=mach_close&window=mm'>Close</A><br><br>"


	dat +={"
*------------------------------*<BR>
<B>Programs</B><BR>
<A href='byond://?src=\ref[src];set=grass'>Grassland</A><BR>
<A href='byond://?src=\ref[src];set=floor'>Floor</A><BR>

<B>Sims</B><BR>

<A href='byond://?src=\ref[src];pro=zed'>Zombies</A><BR>

<B>Other</B><BR>
<A href='byond://?src=\ref[src];jackout=\ref[user]'>Jack Out</A><BR>


"}



	user.Browse(dat, "window=mm")
	onclose(user, "mm")

/obj/machinery/sim/programcomp/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		switch(href_list["set"])
			if("grass")
				Setup_Vspace("grass",network)
			if("floor")
				Setup_Vspace("floor",network)

		switch(href_list["pro"])
			if("zed")
				Run_Program("zombies",1)

		if(href_list["Jack Out"])
//			if("1")
			var/mob/living/carbon/human/virtual/V = usr

			if(src.network == "prison")
				boutput(V, SPAN_ALERT("Leaving this network from the inside has been disabled!"))
				return
			Station_VNet.Leave_Vspace(V)

	return


/obj/machinery/sim/programcomp/attack_ai(mob/user)
	return
//	add_fingerprint(user)
//	if(status & (BROKEN|NOPOWER))
//		return
//	interacted(user)


/obj/machinery/sim/programcomp/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)



/obj/machinery/sim/programcomp/proc/Setup_Vspace(var/icons = "grass",var/network = "none")
	for(var/turf/simulated/floor/Vspace/V in world)
		if(istype(V,/turf/simulated/floor/Vspace))
			if(V.network != network)	continue
			if(V.network_ID == src.id)
				if(icons == "grass")
					V.icon_state = pick("grass1","grass2","grass3","grass4","sand1")
				else if(icons == "floor")
					V.icon_state = "floor"
	return


/obj/machinery/sim/programcomp/proc/Run_Program(var/program = "zombies", var/vspace = 0)
	if(vspace == 0)	return

	for(var/turf/T in landmarks["[network]_critter_spawn"])
		switch(program)
			if("zombies")
				new /mob/living/critter/zombie(T)
			else
				break

	return
