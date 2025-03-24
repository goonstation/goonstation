// Contains:
// - Portable machinery remote parent
// - Broken decal remote
// - Port-a-Brig & remote
// - Port-a-Medbay remote (Port-a-Medbay in sleeper.dm)
// - Port-a-NanoMed & remote
// - Port-a-Sci & remote

///////////////////////////// Remote parent ///////////////////////////////////

// Adapted from the PDA program in portable_machinery_control.dm (Convair880).
TYPEINFO(/obj/item/remote/porter)
	mats = 4

/obj/item/remote/porter
	name = "Remote"
	icon = 'icons/obj/items/device.dmi'
	desc = "You shouldn't be able to see this!"
	icon_state = "locator"
	item_state = "electronic"
	density = 0
	anchored = UNANCHORED
	w_class = W_CLASS_SMALL
	var/list/machinerylist = list()
	var/machinery_name = "" // For user prompt stuff.
	var/anti_spam = 0 // In relation to world time.

	proc/get_machinery()
		return

	// As to avoid a separate lookup for every remote.
	proc/teleport_sanity_check(var/obj/machinery/test_machinery, var/mob/test_mob, var/turf/test_turf, var/no_zlevel_check = 0)
		// Failure states:
		// 0: Tele-blocked loc, src/dest.loc/remote is null or related errors.
		// 1: Pass.
		// 2: On cooldown.
		// 3: There's an occupant and type of machinery requires lock to be engaged.
		// 4: Obstacle at dest.loc.
		// 5: Obstacle at home.loc.

		if (!test_machinery || !src || (test_turf && !isturf(test_turf)))
			return 0
		if (src.anti_spam && world.time < src.anti_spam + 50)
			return 2
		// If we're in a pod etc and want to summon the device, or if the machinery is on the MULE.
		// Both can have unexpected and bad results.
		if (!isturf(test_machinery.loc) || (!test_turf && !isturf(test_mob.loc)))
			return 4
		//if (hasvar(test_machinery, "occupant")) STILL NO, WHY, NO HASVAR
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

		var/turf/our_loc = get_turf(src)
		if (our_loc.loc:teleport_blocked == 2) return 0
		// We don't have to loop through the remote.loc checks as well if we send the device back to its home turf.
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

	attack_self(mob/user as mob)
		src.add_fingerprint(user)

		if (src.anti_spam && world.time < src.anti_spam + 50)
			user.show_text("The [machinery_name] is recharging!", "red")
			return

		src.machinerylist = list()
		src.get_machinery()
		if (!src.machinerylist || (src.machinerylist && length(src.machinerylist) == 0))
			user.show_text("Couldn't find any linkable machinery.", "red")
			return

		var/t1
		if (length(src.machinerylist) == 1)
			t1 = src.machinerylist[1]
		else
			t1 = input("Please select a [src.machinery_name] to control", "Target Selection", null, null) as null|anything in src.machinerylist
		if (!t1)
			return
		if ((user.equipped() != src) || user.stat || user.restrained())
			return

		var/obj/P = src.machinerylist[t1]
		var/turf/our_loc = get_turf(src)
		var/turf/machinery_loc = get_turf(P)
		var/turf/home_loc = null
		if (hasvar(P, "homeloc"))
			home_loc = get_turf(P:homeloc) // I have sinned, though the BAD OPERATOR might be unproblematic here.

		if (!home_loc || !isturf(home_loc))
			user.show_text("No home turf assigned to [src.machinery_name], can't teleport!", "red")
			return

		// Z-level check bypass for Port-a-Sci.
		var/zlevel_check_bypass = 0
		if (istype(P, /obj/storage/closet/port_a_sci/))
			zlevel_check_bypass = 1

		switch (src.teleport_sanity_check(P, user, machinery_loc != home_loc ? home_loc : null, zlevel_check_bypass))
			if (0)
				user.show_text("Teleportation failed due to unknown interference!", "red")
				return
			if (2)
				user.show_text("The [src.machinery_name] is recharging!", "red")
				return
			if (3)
				user.show_text("Cannot teleport unlocked [src.machinery_name] with someone inside!", "red")
				return
			if (4)
				user.show_text("Teleportation failed due to obstacle!", "red")
				return
			if (5)
				user.show_text("Teleportation failed due to obstacle at home turf!", "red")
				return

			else
				src.anti_spam = world.time

				if (machinery_loc == home_loc)
					P.set_loc(our_loc) // We're at home, so let's summon the thing to our location.
					flick("[P.icon_state]-tele", P)
					user.show_text("[src.machinery_name] summoned successfully.", "blue")
					logTheThing(LOG_STATION, user, "teleports [P] to [log_loc(our_loc)].")
				else
					P.set_loc(home_loc) // Send back to home location.
					flick("[P.icon_state]-tele", P)
					user.show_text("[src.machinery_name] sent to home turf.", "blue")
					logTheThing(LOG_STATION, user, "teleports [P] to its home turf [log_loc(home_loc)].")

				if (hasvar(P, "occupant"))
					if (istype(P, /obj/machinery/port_a_brig/))
						var/obj/machinery/port_a_brig/PB = P
						if (PB.occupant)
							PB.occupant.set_loc(PB)
					if (istype(P, /obj/machinery/sleeper/port_a_medbay))
						var/obj/machinery/sleeper/port_a_medbay/PM = P
						if (PM.occupant)
							PM.occupant.set_loc(PM)
							PM.PDA_alert_check()
				if (istype(P, /obj/storage/closet/port_a_sci/))
					var/obj/storage/closet/port_a_sci/PS = P
					PS.on_teleport()

				elecflash(P)

		return

///////////////////////////////// Remotes //////////////////////////////////

/obj/item/remote/porter/port_a_brig
	name = "Port-A-Brig Remote"
	icon_state = "pbrig"
	desc = "A remote that summons a Port-A-Brig."
	machinery_name = "Port-a-Brig"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/port_a_brig/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_medbay
	name = "Port-A-Medbay Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Medbay."
	machinery_name = "Port-a-Medbay"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/sleeper/port_a_medbay/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

// I suppose this device would be sorta useless with tele-block checks?
TYPEINFO(/obj/item/remote/porter/port_a_sci)
	mats = list("metal" = 5,
				"conductive" = 5,
				"telecrystal" = 10)
/obj/item/remote/porter/port_a_sci
	name = "Port-A-Sci Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Sci."
	machinery_name = "Port-a-Sci"

	get_machinery()
		if (!src)
			return

		for (var/obj/storage/closet/port_a_sci/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			/*var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue*/
			if (!(M in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_nanomed
	name = "Port-A-NanoMed Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-NanoMed."
	machinery_name = "Port-a-NanoMed"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/vending/port_a_nanomed/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_gene
	name = "Port-A-Gene Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Gene."
	machinery_name = "Port-a-Gene"

	get_machinery()
		if (!src)
			return

		for (var/obj/machinery/computer/genetics/portable/M in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/M_loc = get_turf(M)
			if (M && M_loc && isturf(M_loc) && isrestrictedz(M_loc.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(M in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(M)]"] += M // Don't remove the #[number] part here.
		return

/obj/item/remote/porter/port_a_laundry
	name = "Port-A-Laundry Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	desc = "A remote that summons a Port-A-Laundry."
	machinery_name = "Port-a-Laundry"

	get_machinery()
		if (!src)
			return

		for (var/obj/submachine/laundry_machine/portable/LP in by_cat[TR_CAT_PORTABLE_MACHINERY])
			var/turf/T = get_turf(LP)
			if (isrestrictedz(T?.z)) // Don't show stuff in "somewhere", okay.
				continue
			if (!(LP in src.machinerylist))
				src.machinerylist["[src.machinery_name] #[src.machinerylist.len + 1] at [get_area(LP)]"] += LP // Don't remove the #[number] part here.
		return

/obj/item/remote/busted
	name = "Port-A-Busted Remote"
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote_busted"
	desc = "A remote for a teleportation device. Looks like it's been through the laundry... or something..."

///////////////////////////////////// Port-a-Brig /////////////////////////////////////

TYPEINFO(/obj/machinery/port_a_brig)
	mats = 30

/obj/machinery/port_a_brig
	name = "Port-A-Brig"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "port_a_brig_0"
	desc = "A portable holding cell with teleporting capabilites."
	density = 1
	anchored = UNANCHORED
	p_class = 1.8
	req_access = list(access_security)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	var/mob/occupant = null
	var/locked = 0
	var/homeloc = null
	var/unlock_timer_start = 0
	var/unlock_timer_req = 2.5 MINUTES
	var/processing = 0

	New()
		..()
		UnsubscribeProcess()
		START_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		build_icon()
		src.homeloc = src.loc

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		..()

	examine()
		. = ..()
		. += "Home turf: [get_area(src.homeloc)]. The interface is [src.locked ? "locked" : "unlocked"]."

	SubscribeToProcess()
		..()
		unlock_timer_start = world.timeofday
		processing = 1

	UnsubscribeProcess()
		..()
		processing = 0

	process()
		var/req = unlock_timer_req - (world.timeofday - unlock_timer_start)
		if (req <= 0)
			locked = 0
			playsound(src, 'sound/machines/airlock_unbolt.ogg', 40, TRUE, -2)
			go_out()
			.= 0
		.= req

	mob_flip_inside(var/mob/user)
		..(user)
		if (!src.locked)
			src.go_out()
			return
		if (!processing)
			SubscribeToProcess()

		var/req = src.process()
		if (req)
			user.show_text(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]. Somehow, you know that it will unlock in [req/10] seconds."))

	Click(location, control, params)
		if(!src.ghost_observe_occupant(usr, src.occupant))
			. = ..()

	// Could be useful (Convair880).
	mouse_drop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (usr == src.occupant || !isturf(usr.loc))
			return
		if (is_incapacitated(usr))
			return
		if (BOUNDS_DIST(src, usr) > 0)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (BOUNDS_DIST(over_object, src) > 0)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor/))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (tgui_alert(usr, "Set selected turf as home location?", "Set home location", list("Yes", "No")) == "Yes")
			src.homeloc = over_object
			usr.visible_message(SPAN_NOTICE("<b>[usr.name]</b> changes the [src.name]'s home turf."), SPAN_NOTICE("New home turf selected: [get_area(src.homeloc)]."))
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing(LOG_STATION, usr, "sets [src.name]'s home turf to [log_loc(src.homeloc)].")
		return

	allow_drop()
		return 0

	relaymove(mob/user as mob)
		if(!user || !isalive(user) || is_incapacitated(user))
			return
		src.go_out()
		return

	Exited(atom/movable/Obj)
		..()
		if(Obj == src.occupant)
			logTheThing(LOG_STATION, obj, "exits [src.name] at [log_loc(src)].")
			src.occupant = null
			build_icon()
			for (var/obj/item/I in src) //What if you drop something while inside? WHAT THEN HUH?
				I.set_loc(src.loc)

			if (processing)
				UnsubscribeProcess()

	attackby(obj/item/W, mob/user as mob)
		var/obj/item/card/id/id_card = get_id_card(W)
		if (istype(id_card, /obj/item/card/id))
			if (src.allowed(user))
				src.locked = !src.locked
				boutput(user, "You [ src.locked ? "lock" : "unlock"] the [src].")
				if (src.locked)
					playsound(src, 'sound/machines/airlock_unbolt.ogg', 40, TRUE, -2)
				else
					playsound(src, 'sound/machines/airlock_bolt.ogg', 40, TRUE, -2)
				if (src.occupant)
					logTheThing(LOG_STATION, user, "[src.locked ? "locks" : "unlocks"] [src.name] with [constructTarget(src.occupant,"station")] inside at [log_loc(src)].")
			else
				boutput(user, SPAN_ALERT("This [src] doesn't seem to accept your authority."))

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting)
				return
			if (!ishuman(G.affecting))
				boutput(user, SPAN_ALERT("You can't find a way to fit [G.affecting] into [src]!"))
				return
			if (src.occupant)
				boutput(user, SPAN_ALERT("The Port-A-Brig is already occupied!"))
				return
			if (src.locked)
				boutput(user, SPAN_ALERT("The Port-A-Brig is locked!"))
				return
			src.add_fingerprint(user)
			actions.start(new /datum/action/bar/portabrig_shove_in(src, user, G.affecting, G), user)

		else if (ispryingtool(W))
			boutput(user, SPAN_NOTICE("Prying door open."))
			SETUP_GENERIC_ACTIONBAR(user, src, 15 SECONDS, /obj/machinery/port_a_brig/proc/pry_open, list(user), W.icon, W.icon_state,
				SPAN_ALERT("[user] pries open [src]."), INTERRUPT_ACT | INTERRUPT_ACTION | INTERRUPT_MOVE | INTERRUPT_ATTACKED | INTERRUPT_STUNNED)

	proc/build_icon()
		if(src.occupant)
			icon_state = "port_a_brig_1"
		else
			icon_state = "port_a_brig_0"

	proc/go_out()
		if (src.locked)
			boutput(usr, SPAN_ALERT("The Port-A-Brig is locked!"))
			return
		if(src.occupant)
			src.occupant.set_loc(src.loc)
			src.occupant.changeStatus("knockdown", 2 SECONDS)
			playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)
		return

	verb/move_eject()
		set src in oview(1)
		set category = "Local"
		if (!src.can_eject_occupant(usr))
			return
		src.go_out()
		add_fingerprint(usr)
		return

/datum/action/bar/portabrig_shove_in
	duration = 3 SECONDS
	var/mob/victim
	var/obj/item/grab/G
	var/obj/machinery/port_a_brig/brig
	interrupt_flags = INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION

	New(obj/machinery/port_a_brig/brig, mob/user, mob/victim, obj/item/grab/G)
		..()
		src.owner = user
		src.brig = brig
		src.victim = victim
		src.G = G

	onStart()
		..()
		if (!src.owner || !src.victim || QDELETED(G))
			interrupt(INTERRUPT_ALWAYS)
		if (!(BOUNDS_DIST(src.owner, src.brig) == 0) || !(BOUNDS_DIST(src.victim, src.brig) == 0))
			interrupt(INTERRUPT_ALWAYS)
		src.brig.visible_message(SPAN_ALERT("[owner] begins shoving [victim] into [src.brig]!"))


	onUpdate()
		..()
		if (!src.owner || !src.victim || QDELETED(G))
			interrupt(INTERRUPT_ALWAYS)
		if (!(BOUNDS_DIST(src.owner, src.brig) == 0) || !(BOUNDS_DIST(src.victim, src.brig) == 0))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		if (!src.owner || !src.victim || QDELETED(G) || brig?.occupant)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!(BOUNDS_DIST(src.owner, src.brig) == 0) || !(BOUNDS_DIST(src.victim, src.brig) == 0) || !isturf(src.victim.loc) || !isturf(src.owner.loc))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.brig.visible_message(SPAN_ALERT("[owner] shoves [victim] into [src.brig]!"))
		src.brig.occupant = victim
		victim.set_loc(src.brig)
		for(var/obj/O in src.brig)
			O.set_loc(src.brig.loc)
		src.brig.build_icon()
		playsound(brig.loc, 'sound/machines/sleeper_close.ogg', 50, 1)
		qdel(G)

/obj/machinery/port_a_brig/proc/pry_open()
	playsound(src.loc, 'sound/items/Crowbar.ogg', 100, TRUE)
	src.locked = FALSE
	playsound(src, 'sound/machines/airlock_unbolt.ogg', 40, TRUE, -2)

/obj/item/paper/Port_A_Brig
	name = "paper - 'A-97 Port-A-Brig Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the A-97 Port-A-Brig Security device!<br>
	Using the A-97 is as simple as beating a criminal to death! Simply Summon the A-97 with the remote, put the criminal inside, lock the door with your ID and send it back!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, the Port-A-Brig teleporter system may fail if you are not in a open space.</i><br>
	<font size=1>This technology produced under license from  Quantum Movement Inc, LTD.</font>"}

/////////////////////////////////////// Port-a-Sci ///////////////////////////////////////////

/obj/storage/closet/port_a_sci
	name = "Port-A-Sci"
	desc = "This has gotta be the fanciest locker you've ever seen. The ones in highscool sure didn't have li'l TVs in 'em! They probably couldn't teleport, either."
	icon_state = "portasci"
	icon_closed = "portasci"
	icon_opened = "portasci-open"
	density = 1
	anchored = UNANCHORED
	p_class = 6
	can_leghole = FALSE
	//mats = 30 // Nope! We don't need multiple personal teleporters without any z-level restrictions (Convair880).
	var/homeloc = null

	var/unsafe_mode = 1 //Hilarious accident mode, more like
	var/list/possible_new_friend = list()
	//Debug vars that should never ever be used maliciously, no sir
	var/force_failure = 0
	var/force_body_swap = 0

	New()
		..()
		START_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)

		src.homeloc = src.loc

		possible_new_friend = typesof(/mob/living/critter/bear) + typesof(/mob/living/critter/spider/ice) + typesof(/mob/living/critter/small_animal/cat) + typesof(/obj/critter/parrot)\
						+ list(/mob/living/critter/aberration, /obj/critter/domestic_bee, /obj/critter/domestic_bee/chef, /obj/critter/bat/buff, /obj/critter/bat, /obj/critter/bloodling, /mob/living/critter/skeleton/wraith, /mob/living/critter/skeleton, /mob/living/critter/brullbar)\
						- list(/mob/living/critter/spider/ice/queen)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		..()

	examine()
		. = ..()
		. += "Home turf: [get_area(src.homeloc)]."

	// This thing isn't z-level-restricted except for the homeloc.
	// Somebody WILL find an exploit otherwise (Convair880).
	mouse_drop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if ((usr in src.contents) || !isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("knockdown"))
			return
		if (BOUNDS_DIST(src, usr) > 0)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (BOUNDS_DIST(over_object, src) > 0)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor/))
			usr.show_text("You can't set this target as the home location.", "red")
			return
		var/turf/check_loc = over_object
		if (check_loc && isturf(check_loc) && isrestrictedz(check_loc.z))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (tgui_alert(usr, "Set selected turf as home location?", "Set home location", list("Yes", "No")) == "Yes")
			src.homeloc = over_object
			usr.visible_message(SPAN_NOTICE("<b>[usr.name]</b> changes the [src.name]'s home turf."), SPAN_NOTICE("New home turf selected: [get_area(src.homeloc)]."))
			// The crusher, hell fires etc. This feature enables quite a bit of mischief.
			logTheThing(LOG_STATION, usr, "sets [src.name]'s home turf to [log_loc(src.homeloc)].")
		return

	allow_drop()
		return 0

	attackby(obj/item/W, mob/user)
		if (src.open && iswrenchingtool(W))
			return
		else
			return ..()

	proc/on_teleport()
		if(unsafe_mode)
			var/has_mob = 0
			for(var/mob/living/carbon/M in src.contents)
				if(M.client && !isdead(M)) //We want a logged-in and living mob otherwise fucklers could spam this without consequence.
					has_mob = 1
					break

			//Body swapping
			if((force_body_swap || prob(1)) && has_mob)
				var/list/mob/body_list = list()
				for(var/mob/living/carbon/M in src.contents) //Don't think you're gonna get lucky, ghosts!
					if(!isdead(M)) body_list += M
				if(length(body_list) > 1)

					for(var/I = 1, I <= body_list.len , I++)
						var/next_in_line = ((I % body_list.len) + 1)

						var/mob/M = body_list[I] //What the actual fuck is this motherfucking nonsense shit fuck I hate you byond what the hell.
						if(M.mind)
							logTheThing(LOG_COMBAT, src, "swapped [key_name(M)] and [constructTarget(body_list[next_in_line],"combat")]'s bodies!")
							M.mind.swap_with(body_list[next_in_line])
							I++ //Step once more to prevent us from hitting the swapped mob

			//Other fuckery
			if( has_mob && (prob(20) || force_failure) ) //This is totally safe.

				switch( force_failure ? force_failure : rand(1,100) )

					if(81 to INFINITY) //Travel sickness!
						for(var/mob/living/carbon/M in src.contents)
							SPAWN(rand(10,40))
								M.nauseate(8,11)
								M.change_misstep_chance(40)
								M.changeStatus("drowsy", 10 SECONDS)

					if(51 to 70) //A nice tan
						for(var/mob/living/M in src.contents)
							M.take_radiation_dose(0.5 SIEVERTS)
							M.show_text("\The [src] buzzes oddly.", "red")
					if(31 to 50) //A very nice tan
						for(var/mob/living/M in src.contents)
							M.take_radiation_dose(1.25 SIEVERTS)
							M.show_text("You feel a warm tingling sensation.", "red")
					if(21 to 30) //The nicest tan
						for(var/mob/living/M in src.contents)
							M.take_radiation_dose(2 SIEVERTS)
							M.show_text("<B>You feel a wave of searing heat wash over you!</B>", "red")
							//if(M.bioHolder && M.bioHolder.mobAppearance) //lol
								// s_tone now an RGB rather than a numeric value so disabling this for the moment
								//M.bioHolder.mobAppearance.s_tone  = max(M.bioHolder.mobAppearance.s_tone - 40, -185)
								//for(var/obj/item/parts/human_parts/HP in M.contents)
								//	HP.set_skin_tone()

								//M.bioHolder.mobAppearance.UpdateMob()

					if(11 to 20) //Mechanical failure aaaaaa
						var/list/temp = src.contents.Copy()
						src.open()
						src.visible_message(SPAN_ALERT("<B>\the [src]'s door flies open and a gout of flame erupts from within!"))
						fireflash(src, 2, chemfire = CHEM_FIRE_RED)
						for(var/mob/living/carbon/M in temp)
							M.update_burning(100)
							var/turf/T = get_edge_target_turf(M, turn(NORTH, rand(0,7) * 45))
							M.throw_at(T,100, 2)

					if(3 to 10) //Hitchhiker friend!
						var/C = pick(possible_new_friend)
						new C(src)

						for(var/mob/M in src.contents)
							M.show_text("Did it just get more cramped in here...?", "red")

					if(1 to 2) //Hilarious accident
						for(var/mob/living/carbon/human/M in src.contents)
							M.set_mutantrace(/datum/mutantrace/roach)
							M.show_text("You feel different...", "red")


//////////////////////////////////////// Port-a-NanoMed ///////////////////////////////////////////

TYPEINFO(/obj/machinery/vending/port_a_nanomed)
	mats = null

/obj/machinery/vending/port_a_nanomed
	name = "Port-A-NanoMed"
	desc = "A compact and portable version of the NanoMed Plus."
	icon = 'icons/obj/porters.dmi'
	icon_state = "vend"
	icon_deny = "vend-deny"
	layer = FLOOR_EQUIP_LAYER1
	req_access = list(access_medical_lockers)
	acceptcard = 0
	anchored = UNANCHORED
	p_class = 1.2
	can_fall = 0
	ai_control_enabled = 1
	power_usage = 0
	var/homeloc = null

	New()
		..()
		UnsubscribeProcess()
		START_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)

		animate_bumble(src, Y1 = 1, Y2 = -1, slightly_random = 0)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		src.homeloc = src.loc
		//Products
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/bruise, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/burn, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/atropine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/calomel, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/charcoal, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/antihistamine, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/epinephrine, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/filgrastim, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/heparin, 2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/insulin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/mannitol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/anti_rad, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/proconvertin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/salbutamol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/salicylic_acid, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/saline, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/spaceacillin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/synaptizine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/formaldehyde, 2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mutadone, 5)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 6)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_organ_upgrade, 2)

		//Hidden
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/random, rand(1, 3), hidden=1)


	disposing()
		STOP_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		..()

	examine()
		. = ..()
		. += "Home turf: [get_area(src.homeloc)]."

	// Could be useful (Convair880).
	mouse_drop(over_object, src_location, over_location)
		..()
		if (isobserver(usr) || isintangible(usr))
			return
		if (!isturf(usr.loc))
			return
		if (usr.stat || usr.getStatusDuration("stunned") || usr.getStatusDuration("knockdown"))
			return
		if (BOUNDS_DIST(src, usr) > 0)
			usr.show_text("You are too far away to do this!", "red")
			return
		if (BOUNDS_DIST(over_object, src) > 0)
			usr.show_text("The [src.name] is too far away from the target!", "red")
			return
		if (!istype(over_object,/turf/simulated/floor/))
			usr.show_text("You can't set this target as the home location.", "red")
			return

		if (tgui_alert(usr, "Set selected turf as home location?", "Set home location", list("Yes", "No")) == "Yes")
			src.homeloc = over_object
			usr.visible_message(SPAN_NOTICE("<b>[usr.name]</b> changes the [src.name]'s home turf."), SPAN_NOTICE("New home turf selected: [get_area(src.homeloc)]."))
			// The crusher, hell fires etc. This feature enables quite a bit of mischief...well, if it wouldn't be the NanoMed.
			//logTheThing(LOG_STATION, usr, "sets [src.name]'s home turf to [log_loc(src.homeloc)].")
		return

	allow_drop()
		return 0

	powered()
		return

	use_power()
		return

	power_change()
		return

//DIRTY DIRTY PLAYERS
TYPEINFO(/obj/submachine/laundry_machine/portable)
	mats = 0

/obj/submachine/laundry_machine/portable
	name = "Port-A-Laundry"
	desc = "Don't ask."
	anchored = UNANCHORED
	pixel_y = 6
	var/homeloc

	New()
		. = ..()
		START_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		animate_bumble(src, Y1 = 1, Y2 = -1, slightly_random = 0)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		src.homeloc = get_turf(src)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_PORTABLE_MACHINERY)
		..()
