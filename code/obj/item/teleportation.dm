/*
CONTAINS:
HAND_TELE

*/

/// HAND TELE

TYPEINFO(/obj/item/hand_tele)
	mats = 8

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
	tool_flags = TOOL_ASSEMBLY_APPLIER
	var/unscrewed = 0
	desc = "An experimental portable teleportation device that can create portals that link to the same destination as a teleport computer."
	var/obj/item/our_target = null
	var/turf/our_random_target = null
	var/obj/machinery/computer/teleporter/locked_computer = null
	var/list/portals = list()
	var/list/users = list() // List of people who've clicked on the hand tele and haven't resolved its UI yet
	var/direct_activateable = TRUE //If this is false, using this in hand will only set in the linked teleporter, not activate it. Needed for use in assemblies.
	var/power_cost = 25

	New()
		..()
		START_TRACKING
		AddComponent(/datum/component/cell_holder, new/obj/item/ammo/power_cell, TRUE, 100, TRUE)
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION, PROC_REF(assembly_manipulation))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, PROC_REF(assembly_removal))

	disposing()
		STOP_TRACKING
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_MANIPULATION)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL)
		..()

/// ----------- Trigger/Applier-Assembly-Related Procs -----------

	proc/assembly_manipulation(var/manipulated_hand_tele, var/obj/item/assembly/parent_assembly, var/mob/user)
		src.AttackSelf(user)

	proc/assembly_application(var/manipulated_hand_tele, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
		if(!src.check_useability() || ON_COOLDOWN(src, "remote_hand_tele", 4 SECONDS))
			return
		logTheThing(LOG_STATION, parent_assembly.last_armer, "'s [parent_assembly] creates a hand tele portal (<b>Last Input Destination:</b> [src.our_target ? "[log_loc(src.our_target)]" : "*random coordinates*"]) at [log_loc(src)].")
		src.try_portal(null, FALSE)

	proc/assembly_setup(var/manipulated_hand_tele, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
		src.direct_activateable = FALSE
		parent_assembly.chargeable_component = src

	proc/assembly_removal(var/manipulated_hand_tele, var/obj/item/assembly/parent_assembly, var/mob/user)
		//we need to reset the hand-tele and remove it from the chargeable components
		src.direct_activateable = TRUE
		parent_assembly.chargeable_component = null

/// ----------------------------------------------



	examine()
		. = ..()
		var/ret = list()
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
			. += SPAN_ALERT("No power cell installed.")
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
		if (I != src && I != src.master && C != src && C != src.master)
			if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (mag.holding != src && mag.holding != src.master)
					return
			else
				return

		//lets check here if the hand tele got enough charge and only has at most one portal liked to it
		if(!src.check_useability(user))
			return

		var/list/L = list()
		L += "Cancel" // So we'll always get a list.
		// Default option that should always be available, regardless of number of teleporters (or lack thereof).
		var/turf/random_turf = src.get_random_tele_turf()
		if (random_turf)
			L["None (Dangerous)"] += pick(random_turf)

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

		if (length(L) < 2) // Shouldn't happen, but you never know.
			user.show_text("Error: couldn't find valid coordinates or working teleporters.", "red")
			return

		users += user // We're about to show the UI
		var/t1
		if(user.client)
			t1 = tgui_input_list(user, "Please select a teleporter to lock in on.", "Target Selection", L)
		else
			t1 = pick(L)
		users -= user // We're done showing the UI

		if (user.stat || user.restrained() || !((src in user.equipped_list()) || (src.master in user.equipped_list()))) //let's check if you actually still HAVE the hand tele
			return

		if (t1 == "Cancel")
			return

		// "None" is a random turf, whereas computer-assisted teleportation locks on to a beacon or tracking implant.
		if (t1 == "None (Dangerous)")
			src.our_random_target = L[t1]
			src.our_target = null
			src.locked_computer = null
			user.show_text("Warning: Hand tele locked in on random coordinates.", "red")
		else
			src.locked_computer = L[t1]
			if (src.locked_computer)
				src.our_target = null
				src.our_random_target = null
				switch (locked_computer.check_teleporter())
					if (0)
						user.show_text("Error: selected teleporter is out of order.", "red")
						return
					if (1)
						src.our_target = src.locked_computer.locked
						if (!our_target)
							user.show_text("Error: selected teleporter is locked in to invalid coordinates.", "red")
							return
						else
							user.show_text("Teleporter selected. Locked in on [ismob(src.locked_computer.locked.loc) ? "[src.locked_computer.locked.loc.name]" : "beacon"] in [get_area(src.locked_computer.locked)].", "blue")
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

		if(src.direct_activateable)
			src.try_portal(user, TRUE)

		return

	proc/check_useability(var/mob/user)
		var/error_text = null
		var/output = TRUE
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.power_cost) & CELL_SUFFICIENT_CHARGE))
			error_text ="[src] doesn't have sufficient cell charge to function!"
			output = FALSE
		if (length(src.portals) >= 2)
			error_text = "The hand teleporter cannot sustain more than 2 portals!"
			output = FALSE
		var/turf/our_loc = get_turf(src)
		if (our_loc && isrestrictedz(our_loc.z))
			error_text ="The [src.name] does not seem to work here!"
			output = FALSE
		if(user && error_text)
			user.show_text(error_text, "red")
		return output


	proc/get_random_tele_turf()
		//this proc gets a random turf the dangerous mode of the handtele deems appropriate
		var/list/random_turfs = list()
		for (var/turf/T in orange(10, get_turf(src)))
			var/area/tele_check = get_area(T)
			if (T.x > world.maxx-4 || T.x < 4) // Don't put them at the edge.
				continue
			if (T.y > world.maxy-4 || T.y < 4)
				continue
			if (tele_check.teleport_blocked)
				continue
			random_turfs += T
		if (length(random_turfs))
			return pick(random_turfs)

	proc/try_portal(var/mob/user, var/spawn_direct = FALSE)
		var/turf/tele_loc = get_turf(src)
		if (isrestrictedz(tele_loc.z))
			if(user)
				user.show_text("The [src.name] does not seem to work here!", "red")
			return
		if (!spawn_direct)
			//if spawn_direct is false, this means we have to check and recalculate the location of the portal again. If it is invalid, we output a random location, but keep the computer locked in.
			//we need to check 1. is a computer locked in, 2. is the location still valid?
			if(src.locked_computer && src.locked_computer.check_teleporter() == 1 && src.locked_computer.locked)
				src.our_target = src.locked_computer.locked
				src.our_random_target = null
			else
				src.our_target = null
				var/turf/random_turf = src.get_random_tele_turf()
				if (random_turf)
					src.our_random_target = random_turf
				else
					return
		var/obj/portal/P = new /obj/portal
		P.set_loc(tele_loc)
		src.portals += P
		if (!src.our_target)
			P.set_target(src.our_random_target)
		else
			P.set_target(src.our_target)

		if(user)
			user.visible_message(SPAN_NOTICE("Portal opened."))
			logTheThing(LOG_STATION, user, "creates a hand tele portal (<b>Destination:</b> [src.our_target ? "[log_loc(src.our_target)]" : "*random coordinates*"]) at [log_loc(src)].")
		else
			src.visible_message(SPAN_NOTICE("A portal opened near [src]."))
		SEND_SIGNAL(src, COMSIG_CELL_USE, src.power_cost)

		SPAWN(30 SECONDS)
			if (P)
				src.portals -= P
				qdel(P)



	proc/dedupe_index(list/L, index)
		var/index_base = index
		var/i = 2
		while(L[index])
			index = index_base
			index += " [i]"
			i++
		return index
