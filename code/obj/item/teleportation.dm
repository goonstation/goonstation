/*
CONTAINS:
LOCATOR
HAND_TELE

*/
/obj/item/locator
	name = "locator"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = FREQ_TRACKING_IMPLANT
	var/broadcasting = null
	var/listening = 1
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 400

/obj/item/locator/attack_self(mob/user as mob)
	src.add_dialog(user)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='?src=\ref[src];refresh=1'>Refresh</A>"}
	user.Browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		src.add_dialog(usr)
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"

				for_by_tcl(W, /obj/item/device/radio/beacon)
					if (W.frequency == src.frequency)
						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += "[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>Extranneous Signals:</B><BR>"
				for_by_tcl(W, /obj/item/implant/tracking)
					if (W.frequency == src.frequency)
						if (!W.implanted || !ismob(W.loc))
							continue
						else
							var/mob/M = W.loc
							if (isdead(M))
								if (M.timeofdeath + 6000 < world.time)
									continue

						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 20)
								if (direct < 5)
									direct = "very strong"
								else
									if (direct < 10)
										direct = "strong"
									else
										direct = "weak"
								src.temp += "[W.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					src.temp = null
		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/// HAND TELE

/obj/item/hand_tele
	name = "hand tele"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	health = 5
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	c_flags = ONBELT
	var/unscrewed = 0
	mats = 8
	desc = "An experimental portable teleportation device that can create portals that link to the same destination as a teleport computer."
	var/obj/item/our_target = null
	var/turf/our_random_target = null
	var/list/portals = list()
	var/list/users = list() // List of people who've clicked on the hand tele and haven't resolved its UI yet
	var/power_cost = 25

	New()
		..()
		START_TRACKING
		AddComponent(/datum/component/cell_holder, new/obj/item/ammo/power_cell, TRUE, 100, TRUE)

	disposing()
		STOP_TRACKING
		..()

	examine()
		. = ..()
		var/ret = list()
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
			. += "<span class='alert'>No power cell installed.</span>"
		else
			. += "The power cell has [ret["charge"]]/[ret["max_charge"]] PUs left! Each portal will use [src.power_cost] PUs."


	// Port of the telegun improvements (Convair880).
	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		// If they've already got the UI open, don't try and open a new one
		if (user in users)
			return

		// Make sure you're holding the hand tele, or it's implanted, before you can use it.
		var/obj/item/I = user.equipped()
		var/obj/item/C = null
		if (istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/humanuser = user
			C = humanuser.chest_item
		if (I != src && C != src)
			if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (mag.holding != src)
					return
			else
				return

		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.power_cost) & CELL_SUFFICIENT_CHARGE))
			user.show_text("[src] doesn't have sufficient cell charge to function!", "red")
			return 0

		if (src.portals.len >= 2)
			user.show_text("The hand teleporter cannot sustain more than 2 portals!", "red")
			return

		var/turf/our_loc = get_turf(src)
		if (our_loc && isrestrictedz(our_loc.z))
			user.show_text("The [src.name] does not seem to work here!", "red")
			return

		var/list/L = list()
		L += "Cancel" // So we'll always get a list.

		// Default option that should always be available, regardless of number of teleporters (or lack thereof).
		var/list/random_turfs = list()
		for (var/turf/T in orange(10))
			var/area/tele_check = get_area(T)
			if (T.x > world.maxx-4 || T.x < 4) // Don't put them at the edge.
				continue
			if (T.y > world.maxy-4 || T.y < 4)
				continue
			if (tele_check.teleport_blocked)
				continue
			random_turfs += T
		if (length(random_turfs))
			L["None (Dangerous)"] += pick(random_turfs)

		for(var/obj/machinery/teleport/portal_generator/PG as anything in machine_registry[MACHINES_PORTALGENERATORS])
			if (!PG.linked_computer || !PG.linked_rings)
				continue
			var/turf/PG_loc = get_turf(PG)
			if (PG && isrestrictedz(PG_loc.z)) // Don't show teleporters in "somewhere", okay.
				continue

			var/obj/machinery/computer/teleporter/Control = PG.linked_computer
			if (Control)
				switch (Control.check_teleporter())
					if (0) // It's busted, Jim.
						continue
					if (1)
						var/index = "Tele at [get_area(Control)]: Locked in ([ismob(Control.locked.loc) ? "[Control.locked.loc.name]" : "[get_area(Control.locked)]"])"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
					if (2)
						var/index = "Tele at [get_area(Control)]: *NOPOWER*"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
					if (3)
						var/index = "Tele at [get_area(Control)]: Inactive"
						if (L[index])
							L[dedupe_index(L, index)] = Control
						else
							L[index] = Control
			else
				continue

		if (L.len < 2) // Shouldn't happen, but you never know.
			user.show_text("Error: couldn't find valid coordinates or working teleporters.", "red")
			return

		users += user // We're about to show the UI
		var/t1
		if(user.client)
			t1 = tgui_input_list(user, "Please select a teleporter to lock in on.", "Target Selection", L)
		else
			t1 = pick(L)
		users -= user // We're done showing the UI

		if (user.stat || user.restrained())
			return

		if (t1 == "Cancel")
			return

		// "None" is a random turf, whereas computer-assisted teleportation locks on to a beacon or tracking implant.
		if (t1 == "None (Dangerous)")
			src.our_random_target = L[t1]
			src.our_target = null
			user.show_text("Warning: Hand tele locked in on random coordinates.", "red")
		else
			var/obj/machinery/computer/teleporter/Control2 = L[t1]
			if (Control2)
				src.our_target = null
				src.our_random_target = null
				switch (Control2.check_teleporter())
					if (0)
						user.show_text("Error: selected teleporter is out of order.", "red")
						return
					if (1)
						src.our_target = Control2.locked
						if (!our_target)
							user.show_text("Error: selected teleporter is locked in to invalid coordinates.", "red")
							return
						else
							user.show_text("Teleporter selected. Locked in on [ismob(Control2.locked.loc) ? "[Control2.locked.loc.name]" : "beacon"] in [get_area(Control2.locked)].", "blue")
					if (2)
						user.show_text("Error: selected teleporter is unpowered.", "red")
						return
					if (3)
						user.show_text("Error: selected teleporter is not locked in.", "red")
						return
			else
				user.show_text("Error: couldn't establish connection to selected teleporter.", "red")
				return

		if (!src.our_target && !src.our_random_target)
			user.show_text("Error: invalid coordinates detected, please try again.", "red")
			return

		our_loc = get_turf(src)
		if (our_loc && isrestrictedz(our_loc.z))
			user.show_text("The [src.name] does not seem to work here!", "red")
			return

		var/obj/portal/P = new /obj/portal
		P.set_loc(our_loc)
		portals += P
		if (!src.our_target)
			P.target = src.our_random_target
		else
			P.target = src.our_target

		user.visible_message("<span class='notice'>Portal opened.</span>")
		SEND_SIGNAL(src, COMSIG_CELL_USE, src.power_cost)
		logTheThing(LOG_STATION, user, "creates a hand tele portal (<b>Destination:</b> [src.our_target ? "[log_loc(src.our_target)]" : "*random coordinates*"]) at [log_loc(user)].")

		SPAWN(30 SECONDS)
			if (P)
				portals -= P
				qdel(P)

		return

	proc/dedupe_index(list/L, index)
		var/index_base = index
		var/i = 2
		while(L[index])
			index = index_base
			index += " [i]"
			i++
		return index
