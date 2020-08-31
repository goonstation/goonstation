/obj/machinery/computer/pod
	name = "Pod Launch Control"
	icon_state = "computer_generic"
	var/id = 1.0
	var/obj/machinery/mass_driver/connected = null
	var/timing = 0.0
	var/time = 30.0
	//var/TPR = 0

	lr = 0.6
	lg = 1
	lb = 0.1

/obj/machinery/computer/pod/old
	icon_state = "old"
	name = "DoorMex Control Computer"

/obj/machinery/computer/pod/old/syndicate
	name = "ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"

	attack_hand(var/mob/user as mob)
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
			SPAWN_DBG( 0 )
				M.open()
				return
	sleep(2 SECONDS)

	//src.connected.drive()		*****RM from 40.93.3S
	for(var/obj/machinery/mass_driver/M in machine_registry[MACHINES_MASSDRIVERS])
		if(M.id == src.id)
			M.power = src.connected.power
			M.drive()

	sleep(5 SECONDS)
	for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			SPAWN_DBG( 0 )
				M.close()
				return
	return

/obj/machinery/computer/pod/New()
	..()
	SPAWN_DBG( 5 )
		for(var/obj/machinery/mass_driver/M in machine_registry[MACHINES_MASSDRIVERS])
			if (M.id == src.id)
				src.connected = M
			else
		return
	return

/obj/machinery/computer/pod/attackby(obj/item/I as obj, user as mob)
	if (isscrewingtool(I))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			if (src.status & BROKEN)
				boutput(user, "<span class='notice'>The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
				G.set_loc(src.loc)

				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/circuitboard/pod/M = null
				if(istype(src, /obj/machinery/computer/pod/old))
					M = new /obj/item/circuitboard/olddoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/syndicate))
						M = new /obj/item/circuitboard/syndicatedoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/swf))
						M = new /obj/item/circuitboard/swfdoor( A )
				else //it's not an old computer. Generate standard pod circuitboard.
					M = new /obj/item/circuitboard/pod( A )

				for (var/obj/C in src)
					C.set_loc(src.loc)
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span class='notice'>You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				//generate appropriate circuitboard. Accounts for /pod/old computer types
				var/obj/item/circuitboard/pod/M = null
				if(istype(src, /obj/machinery/computer/pod/old))
					M = new /obj/item/circuitboard/olddoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/syndicate))
						M = new /obj/item/circuitboard/syndicatedoor( A )
					if(istype(src, /obj/machinery/computer/pod/old/swf))
						M = new /obj/item/circuitboard/swfdoor( A )
				else //it's not an old computer. Generate standard pod circuitboard.
					M = new /obj/item/circuitboard/pod( A )

				for (var/obj/C in src)
					C.set_loc(src.loc)
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/pod/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pod/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Mass Driver Controls</B>"
	src.add_dialog(user)
	var/d2
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Time Launch</A>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Launch</A>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<HR><br>Timer System: []<br>Time Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>", d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
	if (src.connected)
		var/temp = ""
		var/list/L = list( 0.25, 0.5, 1, 2, 4, 8, 16 )
		for(var/t in L)
			if (t == src.connected.power)
				temp += text("[] ", t)
			else
				temp += text("<A href = '?src=\ref[];power=[]'>[]</A> ", src, t, t)
			//Foreach goto(172)
		dat += text("<HR><br>Power Level: []<BR><br><A href = '?src=\ref[];alarm=1'>Firing Sequence</A><BR><br><A href = '?src=\ref[];drive=1'>Test Fire Driver</A><BR><br><A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", temp, src, src, src)
	//*****RM from 40.93.3S
	else
		dat += text("<BR><br><A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
	//*****
	dat += text("<BR><BR><A href='?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	if(istype(src, /obj/machinery/computer/pod/old/swf))
		dat = "<HTML><BODY><TT><B>Magix IV Shuttle and Teleport Control</B>"
		//if(!src.TPR)
		dat += "<BR><BR><BR><A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A><BR>"
		//else
			//dat += "<BR><BR><BR>RECHARGING TELEPORT<BR><DD>Please stand by...</DD>"
		dat += text("<BR><BR><A href = '?src=\ref[];door=1'>Toggle Outer Door</A><BR>", src)
		dat += text("<BR><BR><A href='?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/pod/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/computer/pod/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["spell_teleport"])
			//src.TPR = 1
			//SPAWN_DBG(1 MINUTE)
			//	if(src)
			//		src.TPR = 0
			//		src.updateDialog()
			src.remove_dialog(usr)
			usr.Browse(null, "window=computer")
			usr.teleportscroll(1, 2, src)
			return
		if (href_list["power"])
			var/t = text2num(href_list["power"])
			t = min(max(0.25, t), 16)
			if (src.connected)
				src.connected.power = t
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
					else
						if (href_list["door"])
							for(var/obj/machinery/door/poddoor/M in by_type[/obj/machinery/door])
								if (M.id == src.id)
									if (M.density)
										SPAWN_DBG( 0 )
											M.open()
											return
									else
										SPAWN_DBG( 0 )
											M.close()
											return
								//Foreach goto(298)
		src.add_fingerprint(usr)
		src.updateUsrDialog()

	return
