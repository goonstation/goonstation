/obj/machinery/computer/pod
	name = "pod launch control"
	icon_state = "computer_generic"
	circuit_type = /obj/item/circuitboard/pod
	id = 1
	var/obj/machinery/mass_driver/connected = null
	var/timing = 0
	var/time = 30
	//var/TPR = 0

	light_r =0.6
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "\improper DoorMex control computer"
	circuit_type = /obj/item/circuitboard/olddoor

/obj/machinery/computer/pod/old/syndicate
	name = "\improper ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."
	circuit_type = /obj/item/circuitboard/syndicatedoor

/obj/machinery/computer/pod/old/swf
	name = "\improper Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"
	icon_state = "wizard"
	circuit_type = /obj/item/circuitboard/swfdoor

	attack_hand(var/mob/user)
		if (!iswizard(user))
			user.show_text("The [src.name] doesn't respond to your inputs.", "red")
			return
		else
			return ..()

/obj/machinery/computer/pod/proc/alarm()
	if(status & (NOPOWER|BROKEN))
		return

	if (!( src.connected ))
		viewers(null, null) << "Cannot locate mass driver connector. Cancelling firing sequence!"
		return
	for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			SPAWN( 0 )
				M.open()
				return
	sleep(2 SECONDS)

	//src.connected.drive()		*****RM from 40.93.3S
	for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
		if(M.id == src.id)
			M.power = src.connected.power
			M.drive()

	sleep(5 SECONDS)
	for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			SPAWN( 0 )
				M.close()
				return
	return

/obj/machinery/computer/pod/New()
	. = ..()
	SPAWN( 5 )
		for(var/obj/machinery/mass_driver/M as anything in machine_registry[MACHINES_MASSDRIVERS])
			if (M.id == src.id)
				src.connected = M

/obj/machinery/computer/pod/attack_hand(var/mob/user)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Mass Driver Controls</B>"
	src.add_dialog(user)
	var/d2
	if (src.timing)
		d2 = text("<A href='byond://?src=\ref[];time=0'>Stop Time Launch</A>", src)
	else
		d2 = text("<A href='byond://?src=\ref[];time=1'>Initiate Time Launch</A>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<HR><br>Timer System: []<br>Time Left: [][] <A href='byond://?src=\ref[];tp=-30'>-</A> <A href='byond://?src=\ref[];tp=-1'>-</A> <A href='byond://?src=\ref[];tp=1'>+</A> <A href='byond://?src=\ref[];tp=30'>+</A>", d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
	if (src.connected)
		var/temp = ""
		var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
		for(var/t in L)
			if (t == src.connected.power)
				temp += text("[] ", t)
			else
				temp += text("<A href = 'byond://?src=\ref[];power=[]'>[]</A> ", src, t, t)
			//Foreach goto(172)
		dat += text("<HR><br>Power Level: []<BR><br><A href = 'byond://?src=\ref[];alarm=1'>Firing Sequence</A><BR><br><A href = 'byond://?src=\ref[];drive=1'>Test Fire Driver</A><BR><br><A href = 'byond://?src=\ref[];door=1'>Toggle Outer Door</A><BR>", temp, src, src, src)
	//*****RM from 40.93.3S
	else
		dat += text("<BR><br><A href = 'byond://?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
	//*****
	dat += text("<BR><BR><A href='byond://?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	if(istype(src, /obj/machinery/computer/pod/old/swf))
		dat = "<HTML><BODY><TT><B>Magix IV Shuttle and Teleport Control</B>"
		//if(!src.TPR)
		dat += "<BR><BR><BR><A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
		//else
			//dat += "<BR><BR><BR>RECHARGING TELEPORT<BR><DD>Please stand by...</DD>"
		dat += text("<BR><BR><A href = 'byond://?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
		dat += text("<BR><BR><A href='byond://?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/pod/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			SPAWN(0)
				alarm()
				src.time = 0
				src.timing = 0
		src.updateDialog()
	return

/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["spell_teleport"])
			//src.TPR = 1
			//SPAWN(1 MINUTE)
			//	if(src)
			//		src.TPR = 0
			//		src.updateDialog()
			src.remove_dialog(usr)
			usr.Browse(null, "window=computer")
			usr.teleportscroll(1, 2, src)
			return
		if (href_list["power"])
			var/t = text2num_safe(href_list["power"])
			t = clamp(t, 0.25, 16)
			if (src.connected)
				src.connected.power = t
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num_safe(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num_safe(href_list["tp"])
						src.time += tp
						src.time = clamp(round(src.time), 0, 120)
					else
						if (href_list["door"])
							for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
								if (M.id == src.id)
									if (M.density)
										SPAWN( 0 )
											M.open()
											return
									else
										SPAWN( 0 )
											M.close()
											return
								//Foreach goto(298)
		src.add_fingerprint(usr)
		src.updateUsrDialog()

	return
