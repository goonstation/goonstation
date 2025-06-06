/obj/machinery/computer/door_control
	name = "Door Control"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sec_computer"
	req_access = list(access_brig)
//	var/authenticated = 0.0		if anyone wants to make it so you need to log in in future go ahead.
	id = 1

/obj/machinery/computer/door_control/proc/alarm()
	if(src.status & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/door/window/brigdoor/M in by_type[/obj/machinery/door])
		if (M.id == src.id)
			if(M.density)
				SPAWN( 0 )
					M.open()
			else
				SPAWN( 0 )
					M.close()
	src.updateUsrDialog()
	return

/obj/machinery/computer/door_control/attack_hand(var/mob/user)
	if(..())
		return
	var/dat = "<HTML><BODY><TT><B>Brig Computer</B><br><br>"
	src.add_dialog(user)
	for(var/obj/machinery/door/window/brigdoor/M in by_type[/obj/machinery/door])  //DOORS OH MY GOD (was previously looping through WORLD)
		if(M.id == 1)
			dat += text("<A href='byond://?src=\ref[src];setid=1'>Door 1: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 2)
			dat += text("<A href='byond://?src=\ref[src];setid=2'>Door 2: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 3)
			dat += text("<A href='byond://?src=\ref[src];setid=3'>Door 3: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 4)
			dat += text("<A href='byond://?src=\ref[src];setid=4'>Door 4: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 5)
			dat += text("<A href='byond://?src=\ref[src];setid=5'>Door 5: [(M.density ? "Closed" : "Opened")]</A><br>")
		else
			boutput(world, "Invalid ID detected on brigdoor ([M.x],[M.y],[M.z]) with id [M.id]")
	dat += text("<br><A href='byond://?src=\ref[src];openall=1'>Open All</A><br>")
	dat += text("<A href='byond://?src=\ref[src];closeall=1'>Close All</A><br>")
	dat += text("<BR><BR><A href='byond://?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>")
	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/door_control/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["setid"])
			if(src.allowed(usr))
				src.id = text2num_safe(href_list["setid"])
				src.alarm()
		if (href_list["openall"])
			if(src.allowed(usr))
				for(var/obj/machinery/door/window/brigdoor/M in by_type[/obj/machinery/door])
					if(M.density)
						M.open()
		if (href_list["closeall"])
			if(src.allowed(usr))
				for(var/obj/machinery/door/window/brigdoor/M in by_type[/obj/machinery/door])
					if(!M.density)
						M.close()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
