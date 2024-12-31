// Contains:
// - Portable machinery remote partent
// - Port-a-Brig remote
// - Port-a-Medbay remote
// - Port-a-NanoMed remote
// - Port-a-Sci remote

// First attempt at coding a PDA program. It's probably not very good, let's face it.
// The separate remotes have also been updated and retained as a backup in porters.dm (Convair880).

/datum/computer/file/pda_program/portable_machinery_control
	name = "portable machinery base"

	var/list/machinerylist = list()
	var/obj/our_machinery = null // Type of machinery the remote is controlling.
	var/machinery_name = "" // For HTML stuff.
	var/obj/active // Selected machinery. If null, show global list instead.
	var/anti_spam = 0 // In relation to world time.

	proc/get_machinery()
		return

	// As to avoid a separate lookup for every remote.
	proc/teleport_sanity_check(var/obj/machinery/test_machinery, var/mob/test_mob, var/turf/test_turf, var/no_zlevel_check = 0)
		// Failure states:
		// 0: Tele-blocked loc, src/dest.loc/PDA is null or related errors.
		// 1: Pass.
		// 2: On cooldown.
		// 3: There's an occupant and type of machinery requires lock to be engaged.
		// 4: Obstacle at dest.loc.
		// 5: Obstacle at home.loc.

		if (!test_machinery || !src.master || (test_turf && !isturf(test_turf)))
			return 0
		if (src.anti_spam && world.time < src.anti_spam + 50)
			return 2
		// If we're in a pod etc and want to summon the device, or if the machinery is on the MULE.
		// Both can have unexpected and bad results.
		if (!isturf(test_machinery.loc) || (!test_turf && !isturf(test_mob.loc)))
			return 4
		//if (hasvar(test_machinery, "occupant")) why are you doing a hasvar() if you just end up checking the types and doing nothing to anything that isn't those types WHY, WHY WOULD YOU DO THIS, IT'S TOTALLY POINTLESS
		if (istype(test_machinery, /obj/machinery/port_a_brig))
			var/obj/machinery/port_a_brig/PB = test_machinery
			if (PB.occupant && (test_mob && ismob(test_mob)) && (PB.occupant == test_mob))
				return 0 // It's not a Port-a-Sci, okay.
			if (PB.occupant && !PB.locked)
				return 3
		else if (istype(test_machinery, /obj/machinery/sleeper/port_a_medbay))
			var/obj/machinery/sleeper/port_a_medbay/PM = test_machinery
			if (PM.occupant && (test_mob && ismob(test_mob)) && (PM.occupant == test_mob))
				return 0 // It's not a Port-a-Sci, okay.

		var/turf/our_loc = get_turf(src.master)
		if(isAIeye(test_mob))
			our_loc = get_turf(test_mob)
		if (our_loc.loc:teleport_blocked == 2) return 0

		// We don't have to loop through the PDA.loc checks as well if we send the device back to its home turf.
		if (test_turf)
			if (test_turf.loc:teleport_blocked == 2) return 0
			if (!no_zlevel_check && (isrestrictedz(test_turf.z) || isrestrictedz(our_loc.z))) // Somebody will find a way to abuse it if I don't put this here.
				return 0
			if (test_turf.density)
				return 5
			for (var/obj/thing in view(0, test_turf))
				if (thing.density && !(thing.flags & ON_BORDER))
					return 5
			for (var/obj/machinery/door/D in view(0, test_turf))
				return 5
			for (var/turf/simulated/wall/W in view(0, test_turf))
				return 5

		else
			if (!our_loc || !isturf(our_loc))
				return 0
			if (!no_zlevel_check && isrestrictedz(our_loc.z)) // Somebody will find a way to abuse it if I don't put this here.
				return 0
			if (our_loc.density)
				return 4
			for (var/obj/thing2 in view(0, our_loc))
				if (thing2.density && !(thing2.flags & ON_BORDER))
					return 4
			for (var/obj/machinery/door/D in view(0, our_loc))
				return 4
			for (var/turf/simulated/wall/W in view(0, our_loc))
				return 4

		return 1

	init()
		src.get_machinery()
		return

	// Probably quite the mess, but I wanted to see if identical code x4 could be averted for the HTML generation as well.
	// The portable machinery objects are very similar after all.
	return_text()
		if (..())
			return

		. = src.return_text_header()

		. += "<h4>[src.machinery_name] Interlink</h4>"

		if (!src.active) // Show us the list.
			if (!src.machinerylist || (src.machinerylist && length(src.machinerylist) == 0))
				. += "No linkable machinery found.<BR>"

			else
				for (var/obj/O in src.machinerylist )
					if (istype(O, src.our_machinery))
						. += "<A href='byond://?src=\ref[src];op=control;machinery=\ref[O]'>[O] at [get_area(O)]</A><BR>"

			. += "<BR><A href='byond://?src=\ref[src];op=scanmachinery'>Scan for linkable machinery</A><BR>"

		else // Control a particular piece of machinery.

			. += "<B>[src.active]</B><BR> Status: (<A href='byond://?src=\ref[src];op=control;machinery=\ref[src.active]'><i>refresh</i></A>)<BR>"

			if (istype(src.active, /obj/machinery/port_a_brig/))
				var/obj/machinery/port_a_brig/P2 = src.active

				. += "Location: [get_area(P2)] (Home: [P2.homeloc ? "[get_area(P2.homeloc)]" : "N/A"])<BR>"
				. += "Occupant: [P2.occupant ? "[P2.occupant.name]" : "None"] ([P2.locked ? "locked" : "unlocked"])"

				. += "<BR>\[<A href='byond://?src=\ref[src];op=lock'>Toggle lock</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=summon'>Summon</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=return'>Send to home turf</A>\]<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=machinerylist'>Return to list</A>"

			else if (istype(src.active, /obj/machinery/sleeper/port_a_medbay))
				var/obj/machinery/sleeper/port_a_medbay/P2 = src.active

				. += "Location: [get_area(P2)] (Home: [P2.homeloc ? "[get_area(P2.homeloc)]" : "N/A"])<BR>"
				. += "Occupant: [P2.occupant ? "[P2.occupant.name]" : "None"]"

				. += "<BR>\[<A href='byond://?src=\ref[src];op=summon'>Summon</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=return'>Send to home turf</A>\]<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=machinerylist'>Return to list</A>"

			else if (istype(src.active, /obj/machinery/vending/port_a_nanomed/))
				var/obj/machinery/vending/port_a_nanomed/P2 = src.active

				. += "Location: [get_area(P2)] (Home: [P2.homeloc ? "[get_area(P2.homeloc)]" : "N/A"])"

				. += "<BR>\[<A href='byond://?src=\ref[src];op=summon'>Summon</A>\] "
				. += "\[<A href='byond://?src=\ref[src];op=return'>Send to home turf</A>\]<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=machinerylist'>Return to list</A>"

			else if (istype(src.active, /obj/storage/closet/port_a_sci/))
				var/obj/storage/closet/port_a_sci/P2 = src.active

				. += "Location: [get_area(P2)] (Home: [P2.homeloc ? "[get_area(P2.homeloc)]" : "N/A"])"

				. += "\[<A href='byond://?src=\ref[src];op=return'>Send to home turf</A>\]<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=machinerylist'>Return to list</A>"

			else
				. += "An error occurred, unable to display linkable machinery.<BR>"
				. += "<HR><A href='byond://?src=\ref[src];op=machinerylist'>Return to list</A>"

		return

	Topic(href, href_list)
		if (..())
			return

		var/obj/item/device/pda2/PDA = src.master

		switch (href_list["op"])

			if ("control")
				active = locate(href_list["machinery"]) in src.machinerylist

			if ("scanmachinery") // Get list of linkable machinery.
				src.get_machinery()

			if ("machinerylist")
				active = null

			if ("lock")
				if (istype(src.active, /obj/machinery/port_a_brig/))
					var/obj/machinery/port_a_brig/P3 = src.active
					if (P3.locked)
						P3.locked = 0
					else
						P3.locked = 1

					if (P3.occupant)
						logTheThing(LOG_STATION, usr, "[P3.locked ? "locks" : "unlocks"] [P3.name] with [constructTarget(P3.occupant,"station")] inside at [log_loc(P3)].")

					PDA.display_alert(SPAN_NOTICE("The [src.machinery_name] is now [P3.locked ? "locked" : "unlocked"]."))

				else return

			if ("summon")
				var/obj/P4 = src.active
				var/turf/our_loc = get_turf(PDA)
				if (isAIeye(usr))
					our_loc = get_turf(usr)
					if (!(our_loc.camera_coverage_emitters && length(our_loc.camera_coverage_emitters)))
						boutput(usr, SPAN_ALERT("This area is not within your range of influence."))
						return

				// Z-level check bypass for Port-a-Sci.
				var/zlevel_check_bypass = 0
				if (istype(P4, /obj/storage/closet/port_a_sci/))
					zlevel_check_bypass = 1

				switch (src.teleport_sanity_check(P4, usr, null, zlevel_check_bypass))
					if (0)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to unknown interference!"))
					if (2)
						PDA.display_alert(SPAN_ALERT("The [src.machinery_name] is recharging!"))
					if (3)
						PDA.display_alert(SPAN_ALERT("Cannot teleport unlocked [src.machinery_name] with someone inside!"))
					if (4)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to obstacle!"))
					if (5)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to obstacle at home turf!"))

					else
						src.anti_spam = world.time

						P4.set_loc(our_loc)
						if (hasvar(P4, "occupant"))
							if (istype(P4, /obj/machinery/port_a_brig/))
								var/obj/machinery/port_a_brig/PB = P4
								if (PB.occupant)
									PB.occupant.set_loc(PB)
							if (istype(P4, /obj/machinery/sleeper/port_a_medbay))
								var/obj/machinery/sleeper/port_a_medbay/PM = P4
								if (PM.occupant)
									PM.occupant.set_loc(PM)
						if (istype(P4, /obj/storage/closet/port_a_sci/))
							var/obj/storage/closet/port_a_sci/PS = P4
							PS.on_teleport()

						flick("[P4.icon_state]-tele", P4)
						elecflash(P4)
						logTheThing(LOG_STATION, usr, "teleports [P4] to [log_loc(our_loc)].")

			if ("return")
				var/obj/P5 = src.active
				var/turf/dest_loc = null
				if (hasvar(P5, "homeloc"))
					dest_loc = get_turf(P5:homeloc) // I have sinned, though the BAD OPERATOR might be unproblematic here.

				if (!dest_loc || !isturf(dest_loc))
					PDA.display_alert(SPAN_ALERT("No home turf assigned to [src.machinery_name], can't teleport!"))
					return

				// Z-level check bypass for Port-a-Sci.
				var/zlevel_check_bypass = 0
				if (istype(P5, /obj/storage/closet/port_a_sci/))
					zlevel_check_bypass = 1

				switch (src.teleport_sanity_check(P5, usr, dest_loc, zlevel_check_bypass))
					if (0)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to unknown interference!"))
					if (2)
						PDA.display_alert(SPAN_ALERT("The [src.machinery_name] is recharging!"))
					if (3)
						PDA.display_alert(SPAN_ALERT("Cannot teleport unlocked [src.machinery_name] with someone inside!"))
					if (4)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to obstacle!"))
					if (5)
						PDA.display_alert(SPAN_ALERT("Teleportation failed due to obstacle at home turf!"))

					else
						src.anti_spam = world.time

						P5.set_loc(dest_loc)
						if (hasvar(P5, "occupant"))
							if (istype(P5, /obj/machinery/port_a_brig/))
								var/obj/machinery/port_a_brig/PB2 = P5
								if (PB2.occupant)
									PB2.occupant.set_loc(PB2)
							if (istype(P5, /obj/machinery/sleeper/port_a_medbay))
								var/obj/machinery/sleeper/port_a_medbay/PM2 = P5
								if (PM2.occupant)
									PM2.occupant.set_loc(PM2)
									PM2.PDA_alert_check()
						if (istype(P5, /obj/storage/closet/port_a_sci/))
							var/obj/storage/closet/port_a_sci/PS2 = P5
							PS2.on_teleport()
						flick("[P5.icon_state]-tele", P5)
						elecflash(P5)
						logTheThing(LOG_STATION, usr, "teleports [P5] to its home turf [log_loc(dest_loc)].")

		PDA.updateSelfDialog()
		return

/datum/computer/file/pda_program/portable_machinery_control/portabrig
	name = "Port-a-Brig Remote"
	our_machinery = /obj/machinery/port_a_brig/
	machinery_name = "Port-a-Brig"
	size = 4

	get_machinery()
		if (!src.master)
			return

		for (var/obj/machinery/port_a_brig/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist += M
		return

/datum/computer/file/pda_program/portable_machinery_control/portamedbay
	name = "Port-a-Medbay Remote" // Damn forced line breaks.
	our_machinery = /obj/machinery/sleeper/port_a_medbay
	machinery_name = "Port-a-Medbay"
	size = 4

	get_machinery()
		if (!src.master)
			return

		for (var/obj/machinery/sleeper/port_a_medbay/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist += M
		return

/datum/computer/file/pda_program/portable_machinery_control/portananomed
	name = "Port-a-NanoMed Remote" // Damn forced line breaks.
	our_machinery = /obj/machinery/vending/port_a_nanomed/
	machinery_name = "Port-a-NanoMed"
	size = 4

	get_machinery()
		if (!src.master)
			return

		for (var/obj/machinery/vending/port_a_nanomed/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist += M
		return

// I suppose this device would be sorta useless with tele-block checks?
/datum/computer/file/pda_program/portable_machinery_control/portasci
	name = "Port-a-Sci Remote"
	our_machinery = /obj/storage/closet/port_a_sci/
	machinery_name = "Port-a-Sci"
	size = 4

	get_machinery()
		if (!src.master)
			return

		for (var/obj/storage/closet/port_a_sci/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			/*var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue*/
			if (!(M in src.machinerylist))
				src.machinerylist += M
		return
