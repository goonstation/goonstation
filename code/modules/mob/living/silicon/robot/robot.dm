/mob/living/silicon/robot/New()

	spawn (1)
		src << "\blue Your icons have been generated!"
		updateicon()
		if(src.real_name == "Cyborg")
			src.real_name += " [pick(rand(1, 999))]"
			src.name = src.real_name
	spawn (4)
		if(!src.connected_ai)
			for(var/mob/living/silicon/ai/A in world)
				src.connected_ai = A
				A.connected_robots += src
				break
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.real_name
		src.camera.network = "SS13"


/mob/living/silicon/robot/proc/pick_module()

	var/module = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Security", "Medical", "Janitor", "Brobot")
	switch(module)
		if("Standard")
			src.module = new /obj/item/weapon/robot_module/standard(src)
		if("Medical")
			src.module = new /obj/item/weapon/robot_module/medical(src)
		if("Security")
			src.module = new /obj/item/weapon/robot_module/security(src)
		if("Engineering")
			src.module = new /obj/item/weapon/robot_module/engineering(src)
		if("Janitor")
			src.module = new /obj/item/weapon/robot_module/janitor(src)
		if("Brobot")
			src.module = new /obj/item/weapon/robot_module/brobot(src)

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	src.robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"
	for (var/cat in src.alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				if (sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	src.viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/blob_act()
	if (src.stat != 2)
		src.bruteloss += 30
		src.updatehealth()
		return 1
	return 0

/mob/living/silicon/robot/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		//if(ticker.mode.name == "AI malfunction" && ticker.processing)
		//	stat(null, text("Time until all [station_name()]'s systems are taken over: [(ticker.AIwin - ticker.AItime) / 600 % 60]:[(ticker.AIwin - ticker.AItime) / 100 % 6][(ticker.AIwin - ticker.AItime) / 10 % 10]"))

		if(src.cell)
			stat(null, text("Charge Left: [src.cell.charge]/[src.cell.maxcharge]"))
		else
			stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/ex_act(severity)
	flick("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		del(src)
		return

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				b_loss += 100
				f_loss += 100
				src.gib(1)
				return
		if(2.0)
			if (src.stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (src.stat != 2)
				b_loss += 30
	src.bruteloss = b_loss
	src.fireloss = f_loss
	src.updatehealth()

/mob/living/silicon/robot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		src.updatehealth()
	return

/mob/living/silicon/robot/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
	else if (flag == PROJECTILE_TASER)
		return
	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.updatehealth()
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.updatehealth()
	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 10
			src.updatehealth()
	return

/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	src.show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
	var/who

	if(!connected_ai)
		src << "<b>Error Error, No AI detected</b>"
		return
	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	connected_ai.laws_sanity_check()
	connected_ai.laws_object.show_laws(who)

/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(20))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					src.now_pushing = 0
					return
		src.now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return
/*
/mob/living/silicon/robot/proc/firecheck(turf/T as turf)

	if (T.firelevel < 900000.0)
		return 0
	var/total = 0
	total += 0.25
	return total
*/
/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
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
	src << text("--- [class] alarm detected in [A.name]!")
	if (src.viewalerts) src.robot_alerts()
	return 1

/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
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
	if (cleared)
		src << text("--- [class] alarm in [A.name] has been cleared.")
		if (src.viewalerts) src.robot_alerts()
	return !cleared

/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:get_fuel() > 2)
			W:use_fuel(1)
		else
			user << "Need more welding fuel!"
			return
		src.bruteloss -= 30
		if(src.bruteloss < 0) src.bruteloss = 0
		src.updatehealth()
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)

	else if(istype(W, /obj/item/weapon/cable_coil) && wiresexposed)
		var/obj/item/weapon/cable_coil/coil = W
		src.fireloss -= 30
		if(src.fireloss < 0) src.fireloss = 0
		src.updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the burnt wires on [src]!"), 1)

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			opened = 0
			updateicon()
		else
			if(locked)
				user << "The cover is locked and cannot be opened."
			else
				opened = 1
				updateicon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			user << "Close the panel first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."
//			chargecount = 0
		updateicon()

	else if	(istype(W, /obj/item/weapon/screwdriver) && opened)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		updateicon()

	else if (istype(W, /obj/item/weapon/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			user << "The interface is broken"
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else
			if(src.allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] [src]'s interface."
				updateicon()
			else
				user << "\red Access denied."

	else if (istype(W, /obj/item/weapon/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel first"
		else
			sleep(6)
			if(prob(50))
				emagged = 1
				locked = 0
				user << "You emag [src]'s interface."
				updateicon()
			else
				user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
	else
		return ..()

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(src.opened && !src.wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user << "You remove the power cell."
			src.updateicon()


/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && src.check_access(george.equipped()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/proc/updateicon()

	src.overlays = null

	if(emagged)
		src.overlays += "emag"

	if(src.stat == 0)
		src.overlays += "eyes"

	if(opened)
		if(bruteloss > 150)
			src.overlays += "d3+o"
		else if(bruteloss > 100)
			src.overlays += "d2+o"
		else if(bruteloss > 50)
			src.overlays += "d1+o"
		if(fireloss > 150)
			src.overlays += "b3+o"
		else if(fireloss > 100)
			src.overlays += "b2+o"
		else if(fireloss > 50)
			src.overlays += "b1+o"
	else
		if(bruteloss > 150)
			src.overlays += "d3"
		else if(bruteloss > 100)
			src.overlays += "d2"
		else if(bruteloss > 50)
			src.overlays += "d1"
		if(fireloss > 150)
			src.overlays += "b3"
		else if(fireloss > 100)
			src.overlays += "b2"
		else if(fireloss > 50)
			src.overlays += "b1"

	if(wiresexposed)
		icon_state = "robot+we"
		return

	else if(opened)
		icon_state = "[ cell ? "robot+o+c" : "robot+o-c" ]"		// if opened, show cell if it's inserted
		return

	else
		icon_state = "robot"

/mob/living/silicon/robot/verb/cmd_installed_modules()
	set category = "Robot Commands"
	set name = "Installed Modules"
	src.installed_modules()

/mob/living/silicon/robot/proc/installed_modules()
	if(!src.module)
		src.pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}

	for (var/obj in src.module.modules)
		if(src.activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
	src << browse(dat, "window=robotmod&can_close=0")


/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "robotalerts")
			src.viewalerts = 0
		var/t1 = text("window=[href_list["mach_close"]]")
		src.machine = null
		src << browse(null, t1)
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(activated(O))
			src << "Already activated"
			return
		if(!src.module_state_1)
			src.module_state_1 = O
			src.contents += O
		else if(!src.module_state_2)
			src.module_state_2 = O
			src.contents += O
		else if(!src.module_state_3)
			src.module_state_3 = O
			src.contents += O
		else
			src << "You need to disable a module first!"
		src.installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(src.module_state_1 == O)
				src.module_state_1 = null
				src.contents -= O
			else if(src.module_state_2 == O)
				src.module_state_2 = null
				src.contents -= O
			else if(src.module_state_3 == O)
				src.module_state_3 = null
				src.contents -= O
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		src.installed_modules()
	return

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(src.module_state_1 == O)
		return 1
	else if(src.module_state_2 == O)
		return 1
	else if(src.module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/proc/radio_menu()
	var/obj/item/device/radio/R
	if(istype(src.module_state_1, /obj/item/device/radio))
		R = src.module_state_1
	else if(istype(src.module_state_2, /obj/item/device/radio))
		R = src.module_state_2
	else if(istype(src.module_state_3, /obj/item/device/radio))
		R = src.module_state_3
	else
		return
	var/dat = {"
<TT>
Microphone: [R.broadcasting ? "<A href='byond://?src=\ref[R];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[R];talk=1'>Disengaged</A>"]<BR>
Speaker: [R.listening ? "<A href='byond://?src=\ref[R];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[R];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[R];freq=-10'>-</A>
<A href='byond://?src=\ref[R];freq=-2'>-</A>
[format_frequency(R.frequency)]
<A href='byond://?src=\ref[R];freq=2'>+</A>
<A href='byond://?src=\ref[R];freq=10'>+</A><BR>
-------
</TT>"}
	src << browse(dat, "window=radio")
	onclose(src, "radio")
	return

/mob/living/silicon/robot/proc/activate_baton()
	src << "TEST TEST THIS ISA TEST"

/mob/living/silicon/robot/verb/cmd_drop()
	set category = "Robot Commands"
	set name = "drop"
	src.pulling = null

/mob/living/silicon/robot/Move(a, b, flag)

	if (src.buckled)
		return

	if (src.restrained())
		src.pulling = null

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at [__LINE__] in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [G.affecting] has been pulled from [G.assailant]'s grip by [src]"), 1)
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/living/silicon/robot/proc/self_destruct()
	src.gib(1)
