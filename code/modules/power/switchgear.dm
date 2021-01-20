// a switchgear for cogwerks
// blatant ripoff of the power monitor computer's code, allows you to turn on and off supply to APCs on the powernet.

// its kind of a hack, right now it works by setting a flag on the APC. when the circuit is disabled the APC just sees no available power
// this is a problem, if the switchgear gets destroyed there's no other way to reset that flag. should do it differently but not sure how

// TODO: finish this thing, make it use a terminal to separate powernets then
// have switchgears control power to apcs in a small region. when its in the map
// it will separate powernets into high power (engine -> smes), mid power (smes ->
// switchgear) and low power (switchgear -> apc). would work with possible future
// tiered cables (same code just different sprites and max power before faults and
// build/repair steps and materials) to make power repair work a little more varied
// and separate the crew from the more dangerous wires to go with making higher power
// more dangerous
/obj/machinery/power/switchgear
	name = "High Voltage Switchgear"
	desc = "It looks like a giant cabinet full of switches and shiny metal parts. Why not start messing with it, what's the worst that could happen?"
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1
	var/locked = 1
	var/open = 0
	var/mainsupply = 1

/obj/machinery/power/switchgear/attack_ai(mob/user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return
	interacted(user)

/obj/machinery/power/switchgear/attack_hand(mob/user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return

	if (open)
		interacted(user)
	else
		if (locked)
			boutput(user, "<span class='alert'>The access panel is locked.</span>")
		else
			boutput(user, "<span class='notice'>You open the access panel.</span>")
			// todo: update icon to open state
			open = 1
			icon_state = initial(icon_state)

/obj/machinery/power/switchgear/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/card/id))
		if (src.allowed(user))
			if (src.open)
				boutput(user, "<span class='alert'>You need to close the panel first.</span>")
				return
			src.locked = !src.locked
			boutput(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the switchgear access panel.</span>")
		else
			boutput(user, "<span class='alert'>Access denied.</span>")
	else
		return ..(W, user)

/obj/machinery/power/switchgear/proc/interacted(mob/user)

	if ( (!in_range(src, user)) || (status & (BROKEN|NOPOWER)) )
		src.remove_dialog(user)
		user.Browse(null, "window=switchgear")
		return


	src.add_dialog(user)
	var/t = "<TT><B>Switchgear Control</B><BR><A href='?src=\ref[src];close=1'>Close Panel</A><HR>"

	if(!powernet)
		t += "<span style=\"color:red\">No connection</span>"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<FONT SIZE=+1><TABLE><tr><td colspan='2'><center>Main Supply<BR><FONT SIZE=+3><a href='?src=\ref[src];set_main=[mainsupply ? 0 : 1]'>[mainsupply ? "On" : "Off"]</A></center></font></td></tr>"

		if(L.len > 0)

			var/side = 0

			for(var/obj/machinery/power/apc/A in L)
				if (side)
					side = 0
					t += "<td align='left'><A href='?src=\ref[src];set_apc=\ref[A];circuit_disabled=[A.circuit_disabled ? 0 : 1]'>[A.circuit_disabled ? "Off" : "On"]</A> - [A.area.name]</td></tr>"
				else
					side = 1
					t += "<tr><td align = 'right'>[A.area.name] - <A href='?src=\ref[src];set_apc=\ref[A];circuit_disabled=[A.circuit_disabled ? 0 : 1]'>[A.circuit_disabled ? "Off" : "On"]</A></td>"

			if (side)
				t += "<td></td></tr>"

		t += "</TABLE></FONT></PRE>"

	t += "<HR></TT>"

	user.Browse(t, "window=switchgear;size=500x700")
	onclose(user, "switchgear")

/obj/machinery/power/switchgear/Topic(href, href_list)
	..()
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (isAI(usr)))
		if( href_list["set_main"] )
			var/value = text2num(href_list["set_main"])
			mainsupply = value
			src.updateDialog()
			return
		if( href_list["set_apc"] )
			var/obj/machinery/power/apc/A = locate(href_list["set_apc"])
			if (A) A.circuit_disabled = min(max(0, text2num(href_list["circuit_disabled"])), 1)
			// todo: messing with the APC was a hack, need to have the APCs check the switchgear somehow
			src.updateDialog()
			return
		if( href_list["close"] )
			if (isAI(usr))
				boutput(usr, "<span class='alert'>You'd close the panel, if only you had hands.</span>")
				return
			usr.Browse(null, "window=switchgear")
			src.remove_dialog(usr)
			src.open = 0
			icon_state = "c_unpowered"
			// update icon to closed state
			return
	else
		usr.Browse(null, "window=switchgear")
		src.remove_dialog(usr)

/obj/machinery/power/switchgear/process()
	if(!(status & (NOPOWER|BROKEN)) )
		use_power(250)

	src.updateDialog()

/obj/machinery/power/switchgear/power_change()

	if(status & BROKEN)
		icon_state = "broken"
	else
		if (!open) icon_state = "c_unpowered"
		else
			if( powered() )
				icon_state = initial(icon_state)
				status &= ~NOPOWER
			else
				SPAWN_DBG(rand(0, 15))
				src.icon_state = "c_unpowered"
				status |= NOPOWER
