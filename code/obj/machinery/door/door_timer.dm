/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doortimer0"
	desc = "A remote control switch for a door."
	req_access = list(access_security)
	anchored = 1.0
	var/id = null
	var/time = 30.0
	var/timing = 0.0
	var/last_tick = 0

	// Please keep synchronizied with these lists for easy map changes:
	// /obj/storage/secure/closet/brig/automatic (secure_closets.dm)
	// /obj/machinery/floorflusher (floorflusher.dm)
	// /obj/machinery/door/window/brigdoor (window.dm)
	// /obj/machinery/flasher (flasher.dm)

	solitary
		name = "Cell #1"
		id = "solitary"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary2
		name = "Cell #2"
		id = "solitary2"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary3
		name = "Cell #3"
		id = "solitary3"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	solitary4
		name = "Cell #4"
		id = "solitary4"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig
		name = "Mini-Brig"
		id = "minibrig"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig2
		name = "Mini-Brig #2"
		id = "minibrig2"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	minibrig3
		name = "Mini-Brig #3"
		id = "minibrig3"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop
		name = "General Population"
		id = "genpop"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop_n
		name = "General Population North"
		id = "genpop_n"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

	genpop_s
		name = "General Population South"
		id = "genpop_s"

		new_walls
			north
				pixel_y = 24
			east
				pixel_x = 22
			south
				pixel_y = -19
			west
				pixel_x = -22

/obj/machinery/door_timer/examine()
	. = list("A remote control switch for a door.")

	if(src.timing)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		. += "<span class='alert'>Time Remaining: <b>[(minute ? text("[minute]:") : null)][second]</b></span>"
	else
		. += "<span class='alert'>There is no time set.</span>"

/obj/machinery/door_timer/process()
	..()
	if (src.timing)
		if (!last_tick) last_tick = world.time
		var/passed_time = round(max(round(world.time - last_tick),10) / 10)
		if (src.time > 0)
			src.time -= passed_time
		else
			alarm()
			src.time = 0
			src.timing = 0
			last_tick = 0
		src.updateDialog()
		src.update_icon()
		last_tick = world.time
	else
		last_tick = 0
	return

/obj/machinery/door_timer/power_change()
	update_icon()


// Why range 30? COG2 places linked fixtures much further away from the timer than originally envisioned.
/obj/machinery/door_timer/proc/alarm()
	if (!src)
		return
	if (status & (NOPOWER|BROKEN))
		return
/*
	for(var/obj/machinery/sim/chair/C in range(30, src))
		if (C.id == src.id)
			if(!C.active)
				continue
			if(C.con_user)
				C.con_user.network_device = null
				C.active = 0
*/

	//	MBC : wow this proc is suuuuper fucking costly
	//loop through range(30) three times. sure. whatever.
	//FIX LATER, putting it in a spawn and lagchecking for now.

	SPAWN_DBG(0)
		for (var/obj/machinery/door/window/brigdoor/M in range(30, src))
			if (M.id == src.id)
				SPAWN_DBG(0)
					if (M) M.close()
			LAGCHECK(LAG_HIGH)

		LAGCHECK(LAG_LOW)

		for (var/obj/machinery/floorflusher/FF in range(30, src))
			if (FF.id == src.id)
				if (FF.open != 1)
					FF.openup()
			LAGCHECK(LAG_HIGH)

		LAGCHECK(LAG_LOW)

		for (var/obj/storage/secure/closet/brig/automatic/B in range(30, src))
			if (B.id == src.id && B.our_timer == src)
				if (B.locked)
					B.locked = 0
					B.update_icon()
					B.visible_message("<span class='notice'>[B.name] unlocks automatically.</span>")
			LAGCHECK(LAG_HIGH)

	src.updateUsrDialog()
	src.update_icon()
	return

/obj/machinery/door_timer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_timer/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>[src.name] door controls</B>"
	src.add_dialog(user)
	var/d2 = "<A href='?src=\ref[src];time=1'>Initiate Time</A><br>"
	if (src.timing)
		d2 = "<A href='?src=\ref[src];time=0'>Stop Timed</A><br>"
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += "<br><HR><br>Timer System: [d2]<br>Time Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
	for (var/obj/machinery/flasher/F in range(10, src))
		if (F.id == src.id)
			if (F.last_flash && world.time < F.last_flash + 150)
				dat += "<BR><BR><A href='?src=\ref[src];fc=1'>Flash Cell (Charging)</A>"
			else
				dat += "<BR><BR><A href='?src=\ref[src];fc=1'>Flash Cell</A>"
	dat += "<BR><BR><A href='?action=mach_close&window=computer'>Close</A></TT></BODY></HTML>"
	user.Browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/door_timer/Topic(href, href_list)
	if (..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)
		if (href_list["time"])
			if (src.allowed(usr))
				if (src.timing == 0)
					for (var/obj/machinery/door/window/brigdoor/M in range(10, src))
						if (M.id == src.id)
							M.close()				//close the cell door up when the timer starts.
				else
					for (var/obj/machinery/door/window/brigdoor/M in range(10, src))
						if (M.id == src.id)
							M.open()				//open the cell door if the timer is stopped.

				src.timing = text2num(href_list["time"])
				logTheThing("station", usr, null, "[src.timing ? "starts" : "stops"] a door timer: [src] [log_loc(src)].")

		else
			if (href_list["tp"])
				if(src.allowed(usr))
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 0), 300)
					logTheThing("station", usr, null, "[tp > 0 ? "added" : "removed"] [tp]sec (total: [src.time]sec) to a door timer: [src] [log_loc(src)].")
			if (href_list["fc"])
				if (src.allowed(usr))
					logTheThing("station", usr, null, "sets off flashers from a door timer: [src] [log_loc(src)].")
					for (var/obj/machinery/flasher/F in range(10, src))
						if (F.id == src.id)
							F.flash()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
	return

/obj/machinery/door_timer/proc/update_icon()
	if (status & (NOPOWER))
		icon_state = "doortimer-p"
		return
	else if (status & (BROKEN))
		icon_state = "doortimer-b"
		return
	else
		if (src.timing)
			icon_state = "doortimer1"
		else if (src.time > 0)
			icon_state = "doortimer0"
		else
			SPAWN_DBG(5 SECONDS)
				icon_state = "doortimer0"
			icon_state = "doortimer2"
