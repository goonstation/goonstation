/*
Contains:
- Uplink parent
- Generic Syndicate uplink
- Integrated uplink (PDA & headset)
- Wizard's spellbook

Note: Add new traitor items to syndicate_buylist.dm, not here.
      Every type of Syndicate uplink now includes support for job- and objective-specific items.
*/

/////////////////////////////////////////// Uplink parent ////////////////////////////////////////////

/obj/item/uplink
	name = "uplink"
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/uses = 12 // Amount of telecrystals.
	var/list/datum/syndicate_buylist/items_general = list() // See setup().
	var/list/datum/syndicate_buylist/items_job = list()
	var/list/datum/syndicate_buylist/items_objective = list()
	var/list/datum/syndicate_buylist/items_telecrystal = list()
	var/is_VR_uplink = 0
	var/lock_code = null
	var/lock_code_autogenerate = 0
	var/locked = 0

	var/use_default_GUI = 0 // Use the parent's HTML interface (less repeated code).
	var/temp = null
	var/selfdestruct = 0
	var/can_selfdestruct = 0
	var/datum/syndicate_buylist/reading_about = null

	/// Bitflags for what items this uplink can buy (see `_std/defines/uplink.dm` for flags)
	var/purchase_flags
	var/owner_ckey = null

	// Spawned uplinks for which setup() wasn't called manually only get the standard (generic) items.
	New()
		..()
		SPAWN(1 SECOND)
			if (src && istype(src) && (!length(src.items_general) && !length(src.items_job) && !length(src.items_objective) && !length(src.items_telecrystal)))
				src.setup()

	proc/generate_code()
		if (!src || !istype(src))
			return

		var/code = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega","Gamma","Zeta")]"
		return code

	proc/setup(var/datum/mind/ownermind, var/obj/item/device/master)
		if (!src || !istype(src))
			return

		src.owner_ckey = ownermind?.ckey

		if (!islist(src.items_general))
			src.items_general = list()
		if (!islist(src.items_job))
			src.items_job = list()
		if (!islist(src.items_objective))
			src.items_objective = list()
		if (!islist(src.items_telecrystal))
			src.items_telecrystal = list()

		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			if (src.is_VR_uplink)
				if (!S.vr_allowed)
					continue
				if (S.objective)
					src.items_objective.Add(S)
				else if (S.job)
					src.items_job.Add(S)
				else
					src.items_general.Add(S)

			else

				if(!(S.can_buy & purchase_flags))
					continue

				if (istype(S, /datum/syndicate_buylist/surplus))
					continue

				if (istype(S, /datum/syndicate_buylist/generic) && !src.items_general.Find(S))
					if (S.telecrystal)
						src.items_telecrystal.Add(S)
						src.items_general.Remove(S)
					else
						src.items_general.Add(S)

				if (ownermind || istype(ownermind))
					if (ownermind.special_role != ROLE_NUKEOP && istype(S, /datum/syndicate_buylist/traitor))
						if (!S.objective && !S.job && !src.items_general.Find(S))
							src.items_general.Add(S)

					if (S.objective)
						if (ownermind.objectives)
							var/has_objective = 0
							for (var/datum/objective/O in ownermind.objectives)
								if (istype(O, S.objective))
									has_objective = 1
							if (has_objective && !src.items_objective.Find(S))
								src.items_objective.Add(S)

					if (S.job)
						for (var/allowedjob in S.job)
							if (ownermind.assigned_role && ownermind.assigned_role == allowedjob && !src.items_job.Find(S))
								src.items_job.Add(S)

		// Sort alphabetically by item name.
		var/list/names = list()
		var/list/namecounts = list()

		if (length(src.items_general))
			var/list/sort1 = list()

			for (var/datum/syndicate_buylist/S1 in src.items_general)
				var/name = S1.name
				if (name in names) // Should never, ever happen, but better safe than sorry.
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort1[name] = S1

			src.items_general = sortList(sort1, /proc/cmp_text_asc)

		if (length(src.items_job))
			var/list/sort2 = list()

			for (var/datum/syndicate_buylist/S2 in src.items_job)
				var/name = S2.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort2[name] = S2

			src.items_job = sortList(sort2, /proc/cmp_text_asc)

		if (length(src.items_objective))
			var/list/sort3 = list()

			for (var/datum/syndicate_buylist/S3 in src.items_objective)
				var/name = S3.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort3[name] = S3

			src.items_objective = sortList(sort3, /proc/cmp_text_asc)

		if (length(src.items_telecrystal))
			var/list/sort4 = list()

			for (var/datum/syndicate_buylist/S4 in src.items_telecrystal)
				var/name = S4.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort4[name] = S4

			src.items_telecrystal = sortList(sort4, /proc/cmp_text_asc)

		return

	proc/vr_check(var/mob/user)
		if (!src || !istype(src) || !user || !ismob(user))
			return 0
		if (src.is_VR_uplink == 0)
			return 1

		var/area/A = get_area(user)
		if (!A || !istype(A, /area/sim))
			return 0
		else
			return 1

	proc/explode()
		if (!src || !istype(src))
			return

		if (src.can_selfdestruct == 1)
			var/turf/location = get_turf(src.loc)
			if (location && isturf(location))
				location.hotspot_expose(700,125)
				explosion(src, location, 0, 0, 2, 4)
			qdel(src)

		return

	attack_self(mob/user as mob)
		if (src.vr_check(user) != 1)
			user.show_text("This uplink only works in virtual reality.", "red")
		else if (src.use_default_GUI == 1)
			src.add_dialog(user)
			src.generate_menu()
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/uplink_telecrystal))
			if (!src.locked)
				var/crystal_amount = W.amount
				uses = uses + crystal_amount
				boutput(user, "You insert [crystal_amount] [syndicate_currency] into the [src].")
				qdel(W)
		if (istype(W, /obj/item/explosive_uplink_telecrystal))
			if (!src.locked)
				boutput(user, "<span class='alert'>The [W] explodes!</span>")
				var/turf/T = get_turf(W.loc)
				if(T)
					T.hotspot_expose(700,125)
					explosion(W, T, -1, -1, 2, 3) //about equal to a PDA bomb
				W.set_loc(user.loc)
				qdel(W)

	proc/generate_menu()
		if (src.uses < 0)
			src.uses = 0
		if (src.use_default_GUI == 0)
			return

		var/list/dat = list()
		if (src.selfdestruct)
			dat += "Self Destructing..."

		else if (src.locked && !isnull(src.lock_code))
			dat += "The uplink is locked. <A href='byond://?src=\ref[src];unlock=1'>Enter password</A>.<BR>"

		else if (reading_about)
			var/item_about = "<b>Error:</b> We're sorry, but there is no current entry for this item!<br>For full information on Syndicate Tools, call 1-555-SYN-DKIT."
			if(reading_about.desc) item_about = "[reading_about.desc]"
			dat += "<b>Extended Item Information:</b><hr>[item_about]<hr><A href='byond://?src=\ref[src];back=1'>Back</A>"

		else
			if (src.temp)
				dat += "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
			else
				if (src.is_VR_uplink)
					dat += "<B><U>Syndicate Simulator 2053!</U></B><BR>"
					dat += "Buy the Cat Armor DLC today! Only 250 Credits!"
					dat += "<HR>"
					dat += "<B>Sandbox mode - Spawn item:</B><BR><table cellspacing=5>"
				else
					dat += "<B>Syndicate Uplink Console:</B><BR>"
					dat += "[syndicate_currency] left: [src.uses]<BR>"
					dat += "<HR>"
					dat += "<B>Request item:</B><BR>"
					dat += "<I>Each item costs a number of [syndicate_currency] as indicated by the number following their name.</I><BR><table cellspacing=5>"
				if (src.items_telecrystal && islist(src.items_telecrystal) && length(src.items_telecrystal))
					dat += "</table><B>Ejectable [syndicate_currency]:</B><BR><table cellspacing=5>"
					for (var/T in src.items_telecrystal)
						var/datum/syndicate_buylist/I4 = src.items_telecrystal[T]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_telecrystal[T]]'>[I4.name]</A> ([I4.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_telecrystal[T]]'>About</A></td>"
				if (src.items_objective && islist(src.items_objective) && length(src.items_objective))
					dat += "</table><B>Objective Specific:</B><BR><table cellspacing=5>"
					for (var/O in src.items_objective)
						var/datum/syndicate_buylist/I3 = src.items_objective[O]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_objective[O]]'>[I3.name]</A> ([I3.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_objective[O]]'>About</A></td>"
				if (src.items_job && islist(src.items_job) && length(src.items_job))
					dat += "</table><B>Job Specific:</B><BR><table cellspacing=5>"
					for (var/J in src.items_job)
						var/datum/syndicate_buylist/I2 = src.items_job[J]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_job[J]]'>[I2.name]</A> ([I2.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_job[J]]'>About</A></td>"
				if (src.items_general && islist(src.items_general) && length(src.items_general))
					dat += "</table><B>Standard Equipment:</B><BR><table cellspacing=5>"
					for (var/G in src.items_general)
						var/datum/syndicate_buylist/I1 = src.items_general[G]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_general[G]]'>[I1.name]</A> ([I1.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_general[G]]'>About</A></td>"
				dat += "</table>"
				var/do_divider = 1

				if (istype(src, /obj/item/uplink/integrated/radio))
					var/obj/item/uplink/integrated/radio/RU = src
					if (!isnull(RU.origradio) && istype(RU.origradio, /obj/item/device/radio))
						dat += "<HR><A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
						do_divider = 0
				else if (src.is_VR_uplink == 0 && !isnull(src.lock_code))
					dat += "<HR><A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
					do_divider = 0

				if (src.can_selfdestruct == 1)
					dat += "[do_divider == 1 ? "<HR>" : ""]<A href='byond://?src=\ref[src];selfdestruct=1'>Self-Destruct</A>"

		usr.Browse(jointext(dat, ""), "window=radio")
		onclose(usr, "radio")
		return


	// Validates that the user is not trying to spawn something they should not
	proc/validate_spawn(var/datum/syndicate_buylist/SB)

		for(var/S in items_general)
			if(SB == items_general[S])
				return 1

		for(var/S in items_job)
			if(SB == items_job[S])
				return 1

		for(var/S in items_objective)
			if(SB == items_objective[S])
				return 1

		for(var/S in items_telecrystal)
			if(SB == items_telecrystal[S])
				return 1

		return 0

#define CHECK1 (BOUNDS_DIST(src, usr) > 0 || !usr.contents.Find(src) || !isliving(usr) || iswraith(usr) || isintangible(usr))
#define CHECK2 (is_incapacitated(usr) || usr.restrained())
	Topic(href, href_list)
		..()
		if (src.uses < 0)
			src.uses = 0
		if (src.use_default_GUI == 0)
			return
		if (CHECK1)
			return
		if (CHECK2)
			return
		if (src.vr_check(usr) != 1)
			usr.show_text("This uplink only works in virtual reality.", "red")
			return

		src.add_dialog(usr)

		if (href_list["unlock"] && src.locked && !isnull(src.lock_code))
			var/the_code = adminscrub(input(usr, "Please enter the password.", "Unlock Uplink", null))
			if (!src || !istype(src) || !usr || !ismob(usr) || CHECK1 || CHECK2)
				return
			if (isnull(the_code) || !cmptext(the_code, src.lock_code))
				usr.show_text("Incorrect password.", "red")
				return

			src.locked = 0
			usr.show_text("The uplink beeps softly and unlocks.", "blue")

		else if (href_list["lock"])
			if (istype(src, /obj/item/uplink/integrated/radio))
				var/obj/item/uplink/integrated/radio/RU = src
				if (!isnull(RU.origradio) && istype(RU.origradio, /obj/item/device/radio))
					src.remove_dialog(usr)
					usr.Browse(null, "window=radio")
					var/obj/item/device/radio/T = RU.origradio
					RU.set_loc(T)
					T.set_loc(usr)
					usr.u_equip(RU)
					usr.put_in_hand_or_drop(T)
					RU.set_loc(T)
					T.set_frequency(initial(T.frequency))
					T.attack_self(usr)
					return

			else if (src.locked == 0 && src.is_VR_uplink == 0)
				src.locked = 1
				usr.show_text("The uplink is now locked.", "blue")

		else if (href_list["spawn"])
			var/datum/syndicate_buylist/I = locate(href_list["spawn"])
			if (!I || !istype(I))
				//usr.show_text("Something went wrong (invalid syndicate_buylist reference). Please try again and contact a coder if the problem persists.", "red")
				return

			// Trying to spawn things you shouldn't, eh?
			if(!validate_spawn(I))
				trigger_anti_cheat(usr, "tried to href exploit the syndicate buylist")
				return

			if (src.is_VR_uplink == 0)
				if (src.uses < I.cost)
					boutput(usr, "<span class='alert'>The uplink doesn't have enough [syndicate_currency] left for that!</span>")
					return
				src.uses = max(0, src.uses - I.cost)
				var/datum/antagonist/traitor/T = usr.mind?.get_antagonist(ROLE_TRAITOR)
				if (!istype(I, /datum/syndicate_buylist/generic/telecrystal) && istype(T))
					T.purchased_items.Add(I)
				logTheThing(LOG_DEBUG, usr, "bought this from uplink: [I.name]")

			if (I.item)
				var/obj/item = new I.item(get_turf(src))
				I.run_on_spawn(item, usr, FALSE, src)
				if (src.is_VR_uplink == 0)
					statlog_traitor_item(usr, I.name, I.cost)
			if (I.item2)
				new I.item2(get_turf(src))
			if (I.item3)
				new I.item3(get_turf(src))

		else if (href_list["about"])
			reading_about = locate(href_list["about"])

		else if (href_list["back"])
			reading_about = null

		else if (href_list["selfdestruct"] && src.can_selfdestruct == 1)
			src.selfdestruct = 1
			SPAWN(10 SECONDS)
				if (src)
					src.explode()

		else if (href_list["temp"])
			src.temp = null

		src.attack_self(usr)
		return
#undef CHECK1
#undef CHECK2

/////////////////////////////////////////////// Syndicate uplink ////////////////////////////////////////////

/obj/item/uplink/syndicate
	name = "station bounced radio"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "radio"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	item_state = "radio"
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	use_default_GUI = 1
	can_selfdestruct = 1

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (src.lock_code_autogenerate == 1)
			src.lock_code = src.generate_code()
			src.locked = 1

		return

	alternate // a version that isn't hidden as a radio. So nukeops can better understand where to click to get guns.
		name = "syndicate equipment uplink"
		desc = "An uplink terminal that allows you to order weapons and items."
		icon_state = "uplink"
		purchase_flags = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY | UPLINK_SPY_THIEF | UPLINK_HEAD_REV //Currently this sits unused except for an admin's character, so we can safely have fun with it

	traitor
		purchase_flags = UPLINK_TRAITOR

	nukeop
		name = "syndicate operative uplink"
		desc = "An uplink terminal that allows you to order weapons and items."
		icon_state = "uplink"
		purchase_flags = UPLINK_NUKE_OP

	rev
		purchase_flags = UPLINK_HEAD_REV

	spy
		purchase_flags = UPLINK_SPY

	omni //For admin fuckery and omnitraitors, have fun.
		name = "syndicate omnivendor"
		desc = "Warning: User may suffer from choice paralysis."
		icon_state = "uplink"
		purchase_flags = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_NUKE_OP | UPLINK_HEAD_REV | UPLINK_NUKE_COMMANDER | UPLINK_SPY_THIEF


/obj/item/uplink/syndicate/virtual
	name = "Syndicate Simulator 2053"
	desc = "Pretend you are a space terrorist! Harmless VR fun for all the family!"
	uses = INFINITY
	is_VR_uplink = 1
	can_selfdestruct = 0
	purchase_flags = UPLINK_TRAITOR

	explode()
		src.temp = "Bang! Just kidding."
		return

///////////////////////////////////////////////// Integrated uplinks (PDA & headset) //////////////////////////////////

/obj/item/uplink/integrated
	name = "uplink module"
	desc = "An electronic uplink system of unknown origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	can_selfdestruct = 0

	explode()
		return

/obj/item/uplink/integrated/pda
	lock_code_autogenerate = 1
	var/obj/item/device/pda2/hostpda = null
	var/orignote = null //Restore original notes when locked.
	var/active = 0 //Are we currently active??
	var/menu_message = ""

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (master && istype(master))
			if (istype(master, /obj/item/device/pda2))
				var/obj/item/device/pda2/P = master
				P.uplink = src
				if (src.lock_code_autogenerate == 1)
					src.lock_code = src.generate_code()
				src.hostpda = P
		return

	proc/unlock()
		if ((isnull(src.hostpda)))
			return

		if(src.active)
			src.hostpda.host_program:mode = 1
			return

		if(istype(src.hostpda.host_program, /datum/computer/file/pda_program/os/main_os))

			src.orignote = src.hostpda.host_program:note
			src.active = 1
			src.hostpda.host_program:mode = 1 //Switch right to the notes program

		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

	//Communicate with traitor through the PDA's note function.
	proc/print_to_host(var/text)
		if (isnull(src.hostpda))
			return

		if (!istype(src.hostpda.host_program, /datum/computer/file/pda_program/os/main_os))
			return
		src.hostpda.host_program:note = text
		src.hostpda.updateSelfDialog()

		return

	proc/refresh()
		if(src.active)
			src.generate_menu()
			src.print_to_host(src.menu_message)

	//Let's build a menu!
	generate_menu()
		if (src.uses < 0)
			src.uses = 0
		if (src.vr_check(usr) != 1)
			src.menu_message = "This uplink only works in virtual reality."
			return

		src.menu_message = "<B>Syndicate Uplink Console:</B><BR>"
		src.menu_message += "[syndicate_currency] left: [src.uses]<BR>"
		src.menu_message += "<HR>"
		src.menu_message += "<B>Request item:</B><BR>"
		src.menu_message += "<I>Each item costs a number of [syndicate_currency] as indicated by the number following their name.</I><BR><table cellspacing=5>"

		if (src.items_general && islist(src.items_general) && length(src.items_general))
			for (var/G in src.items_general)
				var/datum/syndicate_buylist/I1 = src.items_general[G]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_general[G]]'>[I1.name]</A> ([I1.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_general[G]]'>About</A></td>"
		if (src.items_job && islist(src.items_job) && length(src.items_job))
			src.menu_message += "</table><B>Job Specific:</B><BR><table cellspacing=5>"
			for (var/J in src.items_job)
				var/datum/syndicate_buylist/I2 = src.items_job[J]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_job[J]]'>[I2.name]</A> ([I2.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_job[J]]'>About</A></td>"
		if (src.items_objective && islist(src.items_objective) && length(src.items_objective))
			src.menu_message += "</table><B>Objective Specific:</B><BR><table cellspacing=5>"
			for (var/O in src.items_objective)
				var/datum/syndicate_buylist/I3 = src.items_objective[O]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_objective[O]]'>[I3.name]</A> ([I3.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_objective[O]]'>About</A></td>"
		if (src.items_telecrystal && islist(src.items_telecrystal) && length(src.items_telecrystal))
			src.menu_message += "</table><B>Ejectable [syndicate_currency]:</B><BR><table cellspacing=5>"
			for (var/O in src.items_telecrystal)
				var/datum/syndicate_buylist/I3 = src.items_telecrystal[O]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_telecrystal[O]]'>[I3.name]</A> ([I3.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_telecrystal[O]]'>About</A></td>"

		src.menu_message += "</table><HR>"
		return

	Topic(href, href_list)
		if (src.uses < 0)
			src.uses = 0
		if (isnull(src.hostpda) || !src.active)
			return
		if (!in_interact_range(src.hostpda, usr) || !usr.contents.Find(src.hostpda) || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (src.vr_check(usr) != 1)
			usr.show_text("This uplink only works in virtual reality.", "red")
			return

		if (href_list["buy_item"])
			var/datum/syndicate_buylist/I = locate(href_list["buy_item"])
			if (!I || !istype(I))
				//usr.show_text("Something went wrong (invalid syndicate_buylist reference). Please try again and contact a coder if the problem persists.", "red")
				return

			// Trying to spawn things you shouldn't, eh?
			if(!validate_spawn(I))
				trigger_anti_cheat(usr, "tried to href exploit the syndicate buylist")
				return

			if (src.is_VR_uplink == 0)
				if (src.uses < I.cost)
					boutput(usr, "<span class='alert'>The uplink doesn't have enough [syndicate_currency] left for that!</span>")
					return
				src.uses = max(0, src.uses - I.cost)
				var/datum/antagonist/traitor/T = usr.mind?.get_antagonist(ROLE_TRAITOR)
				if (!istype(I, /datum/syndicate_buylist/generic/telecrystal) && istype(T))
					T.purchased_items.Add(I)
				logTheThing(LOG_DEBUG, usr, "bought this from uplink: [I.name]")

			if (I.item)
				var/obj/item = new I.item(get_turf(src.hostpda))
				I.run_on_spawn(item, usr)
				if (src.is_VR_uplink == 0)
					statlog_traitor_item(usr, I.name, I.cost)
			if (I.item2)
				new I.item2(get_turf(src.hostpda))
			if (I.item3)
				new I.item3(get_turf(src.hostpda))

		else if (href_list["abt_item"])
			var/datum/syndicate_buylist/I = locate(href_list["abt_item"])
			var/item_about = "<b>Error:</b> We're sorry, but there is no current entry for this item!<br>For full information on Syndicate Tools, call 1-555-SYN-DKIT."
			if(I.desc) item_about = I.desc

			src.print_to_host("<b>Extended Item Information:</b><hr>[item_about]<hr><A href='byond://?src=\ref[src];back=1'>Back</A>")
			return

		/*else if (href_list["back"])
			src.generate_menu()
			src.print_to_host(src.menu_message)
			return*/

		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

	traitor
		purchase_flags = UPLINK_TRAITOR

	nukeop
		purchase_flags = UPLINK_NUKE_OP

	rev
		purchase_flags = UPLINK_HEAD_REV

	spy
		purchase_flags = UPLINK_SPY

/obj/item/uplink/integrated/radio
	lock_code_autogenerate = 1
	use_default_GUI = 1
	var/obj/item/device/radio/origradio = null

	generate_code()
		if (!src || !istype(src))
			return

		var/freq = 1441
		var/list/freqlist = list()
		while (freq <= 1489)
			if (freq < 1451 || freq > 1459)
				freqlist += freq
			freq += 2
			if ((freq % 2) == 0)
				freq += 1
		freq = freqlist[rand(1, length(freqlist))]
		return freq

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (master && istype(master))
			if (istype(master, /obj/item/device/radio))
				var/obj/item/device/radio/R = master
				R.traitorradio = src
				if (src.lock_code_autogenerate == 1)
					R.traitor_frequency = src.generate_code()
				R.protected_radio = 1
				src.name = R.name
				src.icon = R.icon
				src.icon_state = R.icon_state
				src.origradio = R
		return

	traitor
		purchase_flags = UPLINK_TRAITOR

	nukeop
		purchase_flags = UPLINK_NUKE_OP

	rev
		purchase_flags = UPLINK_HEAD_REV

	spy
		purchase_flags = UPLINK_SPY

/obj/item/uplink/integrated/pda/spy
	uses = 5 //amount of times that we can deliver items
			//When uses hits 0, the spawn will be an ID tracker
			//at -1 and below, no new item spawns! yer done

	var/start_uses = 5

	var/loops_allowed = 1
	var/loops = 0			//allow us to continue getting gear at a slowed rate instead of allowing uses to go to -1!
	var/max_loops = 8
	var/bounty_tally = 0 //during loop, need more bountieas for rewards to fill

	/// for use with photo printer cooldown
	var/last_photo_print = 0

	var/datum/game_mode/spy_theft/game
	purchase_flags = UPLINK_SPY_THIEF

	disposing()
		if (game)
			game.uplinks -= src
		..()

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (ticker?.mode)
			if (istype(ticker.mode, /datum/game_mode/spy_theft))
				src.game = ticker.mode
			else //The gamemode is NOT spy, but we've got one on our hands! Set this badboy up.
				if (!ticker.mode.spy_market)
					ticker.mode.spy_market = new /datum/game_mode/spy_theft
					SPAWN(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
						ticker.mode.spy_market.build_bounty_list()
						ticker.mode.spy_market.update_bounty_readouts()
				game = ticker.mode.spy_market

		if (game)
			game.uplinks += src

		return

	proc/req_bounties()
		if (loops <= 0 || !loops_allowed)
			.= 1
		else
			.= loops+1 - bounty_tally

	proc/bounty_is_claimable(var/A)
		.= 0
		if (ismob(A))
			var/mob/M = A
			for (var/obj/possible in M.contents)
				.= bounty_object_is_claimable(possible)
				if(.)
					break
		else if (isobj(A))
			.= bounty_object_is_claimable(A)


	proc/bounty_object_is_claimable(var/obj/delivery)
		.= 0
		for(var/datum/bounty_item/B in game.active_bounties)
			if (B.claimed)
				continue

			var/organ_succ = (B.item && delivery == B.item)
			var/everythingelse_succ = ( (B.path && istype(delivery,B.path)) || B.item && delivery == B.item || (B.photo_containing && istype(delivery,/obj/item/photo) && findtext(delivery.name, B.photo_containing)) )
			if (((B.bounty_type == BOUNTY_TYPE_ORGAN) && organ_succ) || ((B.bounty_type != BOUNTY_TYPE_ORGAN) && everythingelse_succ))
				if (B.delivery_area && B.delivery_area != get_area(src.hostpda))
					return 0
				return delivery

	proc/try_deliver(var/obj/delivery, var/mob/user)
		if (uses < 0)
			src.ui_update()
			return

		if (user.mind && user.mind.special_role != ROLE_SPY_THIEF)
			user.show_text("You cannot claim a bounty! The PDA doesn't recognize you!", "red")
			return 0

		for(var/datum/bounty_item/B in game.active_bounties)
			if (B.claimed)
				continue
			if ( (B.path && istype(delivery,B.path)) || B.item && delivery == B.item || (B.photo_containing && istype(delivery,/obj/item/photo) && findtext(delivery.name, B.photo_containing)) )
				if (B.delivery_area && B.delivery_area != get_area(src.hostpda))
					user.show_text("You must stand in the designated delivery zone to send this item!", "red")
					if (istype(B.delivery_area, /area/diner))
						user.show_text("It can be found at the nearby space diner!", "red")
					var/turf/end = B.delivery_area.spyturf
					user.gpsToTurf(end, doText = 0) // spy thieves probably need to break in anyway, so screw access check
					return 0
				for (var/obj/item/device/pda2/P in delivery.contents) //make sure we don't delete the PDA
					if (P.uplink == src)
						return 0
				user.removeGpsPath(doText = 0)
				B.claimed = 1
				for (var/mob/M in delivery.contents) //make sure we dont delete mobs inside the stolen item
					M.set_loc(get_turf(delivery))
				if (istype(delivery.loc, /mob))
					var/mob/M = delivery.loc
					if (istype(delivery,/obj/item/parts) && ishuman(M))
						var/mob/living/carbon/human/H = M
						var/obj/item/parts/HP = delivery
					//	var/limb_name = HP.holder.real_name + "'s " + HP.name
						if(HP == B.item && HP.holder == M) //Is this the right limb and is it attached?
							HP.remove()
							take_bleeding_damage(H, null, 10)
							H.changeStatus("weakened", 3 SECONDS)
							playsound(H.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
							H.emote("scream")
							logTheThing(LOG_STATION, user, "spy thief claimed [constructTarget(H)]'s [HP] at [log_loc(user)]")
						else if(HP != B.item)
							user.show_text("That isn't the right limb!", "red")
							return 0
					else
						M.drop_from_slot(delivery,get_turf(M))
				if (!istype(delivery,/obj/item/parts))
					logTheThing(LOG_DEBUG, user, "spy thief claimed delivery of: [delivery] at [log_loc(user)]")
				qdel(delivery)
				if (user.mind && user.mind.special_role == ROLE_SPY_THIEF)
					user.mind.spy_stolen_items += B.name

				if (req_bounties() > 1)
					bounty_tally += 1
					user.show_text("Your PDA accepts the bounty. Deliver [req_bounties()] more bounties to earn a reward.", "red")
				else
					src.spawn_reward(B, user)
				src.ui_update()
				return 1

		user.show_text("You cannot claim [delivery] for bounty!", "red")
		src.ui_update()
		return 0

	proc/loop()
		if (loops_allowed && loops < max_loops)
			uses = start_uses
			loops += 1

	proc/spawn_reward(var/datum/bounty_item/B, var/mob/user)
		B.spawn_reward(user,src.loc)

		if (uses == 0)//Spawn ID tracker. Last item!


			if (loops <= 0)
				if (user.mind)
					var/spawn_tracker = 0
					//for (var/datum/objective/objective in user.mind.objectives)
					//	if (istype(objective,/datum/objective_set/spy_theft/vigilante))
					//		spawn_tracker = 1

					if (spawn_tracker) //only aspawn id tracker if we have the proper objective
						var/obj/item/extra = new /datum/syndicate_buylist/traitor/idtracker/spy
						user.put_in_hand_or_drop(extra)
			loop()

		uses--
		bounty_tally = 0

		return 1

	proc/ui_update() //when the market refreshes or bounties are claimed, everyone needs ta know
		src.generate_menu()
		if(src.active)
			src.print_to_host(src.menu_message)

	/// Prints a photo of the spy theif's target item or mob owner
	proc/print_photo(datum/bounty_item/B, mob/user)
		if (!B) return
		if (!user) return
		if (TIME <= src.last_photo_print + 5 SECONDS)
			boutput(user, "<span class='alert'>The photo printer is recharging!</span>")
			return

		var/title = null
		var/detail = null
		var/image/photo_image
		var/icon/photo_icon
		var/atom/A = null
		if ((B.bounty_type == BOUNTY_TYPE_ORGAN) && B.item)
			var/obj/item/parts/O = B.item
			if (O.holder)
				A = O.holder
			else
				A = O // loose limb
		else if (B.item)
			A = B.item

		if (ismob(A))
			var/mob/M = A
			var/list/trackable_mobs = get_mobs_trackable_by_AI()
			if (!(((M.name in trackable_mobs) && (trackable_mobs[M.name] == M)) || (M == user)))
				boutput(user, "<span class='alert'>Unable to locate target within the station camera network!</span>")
				return
			photo_image = image(A.icon, null, A.icon_state, null, SOUTH)
			photo_image.overlays = A.overlays
			photo_image.underlays = A.underlays
			photo_icon = M.build_flat_icon(SOUTH)

			title = "photo of [M]"
			var/holding = null
			if (M.l_hand || M.r_hand)
				var/they_are = M.gender == "male" ? "He's" : M.gender == "female" ? "She's" : "They're"
				if (M.l_hand)
					holding = "[they_are] holding \a [M.l_hand]"
				if (M.r_hand)
					if (holding)
						holding += " and \a [M.r_hand]."
					else
						holding = "[they_are] holding \a [M.r_hand]."
				else if (holding)
					holding += "."

			var/they_look = M.gender == "male" ? "he looks" : M.gender == "female" ? "she looks" : "they look"
			var/health_info = M.health < 75 ? " - [they_look][M.health < 25 ? " really" : null] hurt" : null
			if (!detail)
				detail = "In the photo, you can see [M][M.lying ? " lying on [get_turf(M)]" : null][health_info][holding ? ". [holding]" : "."]"

		else
			photo_image = build_composite_icon(A)
			photo_icon = getFlatIcon(A)
			title = "photo of \a [A]"
			detail = "You can see \a [A]."

		var/obj/item/photo/P = new(src, photo_image, photo_icon, title, detail)
		user.put_in_hand_or_drop(P)
		playsound(src, 'sound/machines/scan.ogg', 10, 1)
		last_photo_print = TIME

	generate_menu()
		src.menu_message = "<B>Spy Console:</B> Current location: [get_area(src)]<BR>"

		if (game)
			//var/datum/game_mode/spy_theft/game = ticker.mode

			var/refresh_time_formatted = round((game.last_refresh_time + game.bounty_refresh_interval)/10 ,1)
			refresh_time_formatted = "[round(refresh_time_formatted / 3600)]:[add_zero(round(refresh_time_formatted % 3600 / 60), 2)]:[add_zero(num2text(refresh_time_formatted % 60), 2)]"

			if (src.uses < 0 && (loops >= max_loops || !loops_allowed))
				src.menu_message += "<b>Assasinate the following targets.</b> Be warned, we expect them to be armed and dangerous.<br>"
				for (var/datum/mind/M in ticker.mode.traitors)
					if (M.current)
						src.menu_message += "<tr><td><b>[M.current.name]</b><br></td></tr>"
			else
				if (loops <= 0)
					src.menu_message += ""
					//src.menu_message += "Fulfill <B>[src.uses+1]</B> bounties to track your assasination targets.<BR><HR>"
				else
					src.menu_message += ""
					//src.menu_message += "Fulfill <B>[req_bounties()]</B> bounties receive your next reward. You have already earned your ID tracker.<BR><HR>"
				src.menu_message += "<B>Current Bounties (Next Refresh at : [refresh_time_formatted]):</B>"
				for(var/datum/bounty_item/B in game.active_bounties)
					var/atext = ""
					if (B.reveal_area && B.item && !B.claimed)
						atext = "<br>(Last Seen : [get_area(B.item)])"
					var/rtext = ""
					if (B.reward)
						if (req_bounties() <= 1)
							rtext = "<br><b>Reward</b> : [B.reward.name] [(B.hot_bounty) ? "<b>**HOT**</b>" : ""]"
						else
							rtext = "<br><b>Reward</b> : Not available. Deliver [req_bounties()] more bounties."

					src.menu_message += "<small><br><br><tr><td><b>[B.name]</b>[rtext][atext]<br>[(B.claimed) ? "(<b>CLAIMED</b>)" : "(Deliver : <b>[B.delivery_area ? B.delivery_area : "Anywhere"]</b>) [B.photo_containing ? "" : "<a href='?src=\ref[src];action=print;bounty=\ref[B]'>Print</a>"]"]</td></tr></small>"

		src.menu_message += "<HR>"

		src.menu_message += "<br><I>Each bounty is open to all spies. Be sure to satisfy the requirements before your enemies.</I><BR><BR>"
		src.menu_message += "<br><I>A **HOT** bounty indicates that the payout will be higher in value.</I><BR><BR>"
		src.menu_message += "<I>Stand in the Deliver Area and touch a bountied item (or use click + drag) to this PDA. Our fancy wormhole tech can take care of the rest. Your efforts will be rewarded.</I><BR><table cellspacing=5>"

		return

	Topic(href, href_list)
		if (isnull(src.hostpda) || !src.active)
			return
		if (BOUNDS_DIST(src.hostpda, usr) > 0 || !usr.contents.Find(src.hostpda) || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (href_list["action"])
			if (href_list["action"] == "print" && href_list["bounty"])
				//print photo of item or mob owner
				src.print_photo(locate(href_list["bounty"]) , usr)

		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

#define PLAYERS_PER_UPLINK_POINT 20

/obj/item/device/nukeop_commander_uplink
	name = "nuclear commander uplink"
	desc = "A nifty device used by the commander to order powerful equipment for their team."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "uplink_commander"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = W_CLASS_SMALL
	item_state = "uplink_commander"
	throw_speed = 4
	throw_range = 20
	var/points = 2
	var/list/commander_buylist = list()
	var/datum/syndicate_buylist/reading_about = null
	/// Bitflags for what items this uplink can buy (see `_std/defines/uplink.dm` for flags)
	var/purchase_flags = UPLINK_NUKE_COMMANDER

	New()
		..()
		var/num_players
		for(var/client/C in clients)
			var/mob/client_mob = C.mob
			if (!istype(client_mob))
				continue
			num_players++
		points = max(2, round(num_players / PLAYERS_PER_UPLINK_POINT))
		SPAWN(1 SECOND)
			if (src && istype(src) && (!length(src.commander_buylist)))
				src.setup()

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/remote/reinforcement_beacon))
			var/obj/item/remote/reinforcement_beacon/R = W
			if(R.uses >= 1 && !R.anchored)
				R.force_drop(user)
				sleep(1 DECI SECOND)
				boutput(user, "<span class='alert'>The [src] accepts the [R], warping it away.</span>")
				src.points += 2
				qdel(R)
		else
			..()

	proc/setup()
		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			if ((istype(S, /datum/syndicate_buylist/commander) || (S.can_buy & purchase_flags)) && !(S in src.commander_buylist))
				src.commander_buylist.Add(S)

		var/list/names = list()
		var/list/namecounts = list()
		if (length(src.commander_buylist))
			var/list/sort1 = list()

			for (var/datum/syndicate_buylist/S in src.commander_buylist)
				var/name = S.name
				if (name in names) // sanity check
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort1[name] = S

			src.commander_buylist = sortList(sort1, /proc/cmp_text_asc)

	attack_self(mob/user)
		return ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ComUplink")
			ui.open()

	ui_data(mob/user)
		. = list(
			"points" = points,
		)

	ui_static_data(mob/user)
		. = list("stock" = list())

		for (var/datum/syndicate_buylist/SB as anything in commander_buylist)
			var/datum/syndicate_buylist/I = commander_buylist[SB]
			.["stock"] += list(list(
				"ref" = "\ref[I]",
				"name" = I.name,
				"description" = I.desc,
				"cost" = I.cost,
				"category" = I.category,
			))

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if ("redeem")
				for(var/datum/syndicate_buylist/SB as anything in commander_buylist)
					if(istype(commander_buylist[SB], locate(params["ref"])))
						var/datum/syndicate_buylist/B = commander_buylist[SB]
						if (src.points >= B.cost)
							src.points -= B.cost
							var/atom/A = new B.item(get_turf(src))
							if(B.item2)
								new B.item2(get_turf(src))
							if(B.item3)
								new B.item3(get_turf(src))

							B.run_on_spawn(A, usr, FALSE, src)
							logTheThing(LOG_STATION, usr, "bought a [initial(B.item.name)] from a [src] at [log_loc(usr)].")
							var/loadnum = world.load_intra_round_value("Nuclear-Commander-[initial(B)]-Purchased")
							if(isnull(loadnum))
								loadnum = 0
							world.save_intra_round_value("NuclearCommander-[initial(B)]-Purchased", loadnum + 1)
							. = TRUE
							break

#undef PLAYERS_PER_UPLINK_POINT
///////////////////////////////////////// Wizard's spellbook ///////////////////////////////////////////////////

/obj/item/SWF_uplink
	name = "Spellbook"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "spellbook"
	item_state = "spellbook"
	var/wizard_key = ""
	var/temp = null
	var/uses = 6
	var/selfdestruct = 0
	var/traitor_frequency = 0
	var/obj/item/device/radio/origradio = null
	var/list/spells = list()
	flags = FPRINT | ONBELT | TABLEPASS
	throwforce = 5
	health = 5
	w_class = W_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	var/vr = 0

	New(var/in_vr = 0)
		..()
		if (in_vr)
			vr = 1
			uses *= 2

		//Kubius spellbook upgrade: autonomous compendium of SWF uplink datums
		for(var/D in (childrentypesof(/datum/SWFuplinkspell)))
			src.spells += new D(src)

/datum/SWFuplinkspell
	var/name = "Spell"
	var/eqtype = "Spell"
	var/desc = "This is a spell."
	var/cost = 1
	var/cooldown = null
	var/assoc_spell = null
	var/vr_allowed = 1
	var/obj/item/assoc_item = null

	proc/SWFspell_CheckRequirements(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		if (!user || !book)
			return 999 // unknown error
		if (book.vr && !src.vr_allowed)
			return 3
		if (src.assoc_spell)
			if (user.abilityHolder.getAbility(assoc_spell))
				return 2
		if (book.uses < src.cost)
			return 1 // ran out of points

	proc/SWFspell_Purchased(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		if (!user || !book)
			return
		logTheThing(LOG_DEBUG, null, "[constructTarget(user)] purchased the spell [src.name] using the [book] uplink.")
		if (src.assoc_spell)
			user.abilityHolder.addAbility(src.assoc_spell)
			user.abilityHolder.updateButtons()
		if (src.assoc_item)
			var/obj/item/I = new src.assoc_item(user.loc)
			if (istype(I, /obj/item/staff) && user.mind && !isvirtual(user))
				var/obj/item/staff/S = I
				S.wizard_key = user.mind.key
		book.uses -= src.cost

/datum/SWFuplinkspell/soulguard
	name = "Soulguard"
	eqtype = "Enchantment"
	vr_allowed = 0
	desc = "Soulguard is basically a one-time do-over that teleports you back to the wizard shuttle and restores your life in the event that you die. However, the enchantment doesn't trigger if your body has been gibbed or otherwise destroyed. Also note that you will respawn completely naked."

	SWFspell_CheckRequirements(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		. = ..()
		if (user.spell_soulguard) return 2

	SWFspell_Purchased(var/mob/living/carbon/human/user,var/obj/item/SWF_uplink/book)
		..()
		user.spell_soulguard = 1

/datum/SWFuplinkspell/staffofcthulhu
	name = "Staff of Cthulhu"
	eqtype = "Equipment"
	desc = "The crew will normally steal your staff and run off with it to cripple your casting abilities, but that doesn't work so well with this version. Any non-wizard dumb enough to touch or pull the Staff of Cthulhu takes massive brain damage and is knocked down for quite a while, and hiding the staff in a closet or somewhere else is similarly ineffective given that you can summon it to your active hand at will. It also makes a much better bludgeoning weapon than the regular staff, hitting harder and occasionally inflicting brain damage."
	assoc_spell = /datum/targetable/spell/summon_staff
	assoc_item = /obj/item/staff/cthulhu
	cost = 2

/datum/SWFuplinkspell/staffofthunder
	name = "Staff of Thunder"
	eqtype = "Equipment"
	desc = "A special staff attuned to electical energies. Able to conjure three lightning bolts to strike down foes before being recharged. Capable of being summoned magically, which recharges the wand. Take care, as you're not immune to your own thunder!"
	assoc_spell = /datum/targetable/spell/summon_thunder_staff
	assoc_item = /obj/item/staff/thunder
	cost = 2

/datum/SWFuplinkspell/bull
	name = "Bull's Charge"
	eqtype = "Offensive"
	desc = "Records your movement for 4 seconds, after which a massive bull charges along the recorded path, smacking anyone unfortunate to get in its way (excluding yourself) and dealing a significant amount of brute damage in the process. Watch your head for loose items, they are thrown around too."
	assoc_spell = /datum/targetable/spell/bullcharge
/*
/datum/SWFuplinkspell/shockwave
	name = "Shockwave"
	eqtype = "Offensive"
	desc = "This spell will violently throw back any nearby objects or people.<br>Cooldown:"
	assoc_spell = /datum/targetable/spell/shockwave
*/
/datum/SWFuplinkspell/fireball
	name = "Fireball"
	eqtype = "Offensive"
	desc = "This spell allows you to fling a fireball at a nearby target of your choice. The fireball will explode, knocking down and burning anyone too close, including you."
	assoc_spell = /datum/targetable/spell/fireball
	cost = 2

/datum/SWFuplinkspell/prismatic_spray
	name = "Prismatic Spray"
	eqtype = "Offensive"
	desc = "This spell allows you to launch a spray of colorful and wildly innaccurate projectiles outwards in a cone aimed roughly at a nearby target."
	assoc_spell = /datum/targetable/spell/prismatic_spray
	cost = 2

/*
/datum/SWFuplinkspell/shockinggrasp
	name = "Shocking Grasp"
	eqtype = "Offensive"
	desc = "This spell cannot be used on a moving target due to the need for a very short charging sequence, but will instantly kill them, destroy everything they're wearing, and vaporize their body."
	assoc_spell = /datum/targetable/spell/kill
*/
/datum/SWFuplinkspell/shockingtouch
	name = "Shocking Touch"
	eqtype = "Offensive"
	desc = "This spell cannot be used on a moving target due to the need for a very short charging sequence, but will instantly put them in critical condition, and shock and stun anyone close to them."
	assoc_spell = /datum/targetable/spell/shock

/datum/SWFuplinkspell/iceburst
	name = "Ice Burst"
	eqtype = "Offensive"
	desc = "This spell fires freezing cold projectiles that will temporarily freeze the floor beneath them, and slow down targets on contact."
	assoc_spell = /datum/targetable/spell/iceburst

/datum/SWFuplinkspell/blind
	name = "Blind"
	eqtype = "Offensive"
	desc = "This spell temporarily blinds and stuns a target of your choice."
	assoc_spell = /datum/targetable/spell/blind

/datum/SWFuplinkspell/clownsrevenge
	name = "Clown's Revenge"
	eqtype = "Offensive"
	desc = "This spell turns an adjacent target into an idiotic, horrible, and useless clown."
	assoc_spell = /datum/targetable/spell/cluwne
	cost = 2

/datum/SWFuplinkspell/balefulpolymorph
	name = "Baleful Polymorph"
	eqtype = "Offensive"
	desc = "This spell turns an adjacent target into some kind of an animal."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/animal
	cost = 2

/datum/SWFuplinkspell/rathensecret
	name = "Rathen's Secret"
	eqtype = "Offensive"
	desc = "This spell summons a shockwave that rips the arses off of your foes. If you're lucky, the shockwave might even sever an arm or leg."
	assoc_spell = /datum/targetable/spell/rathens
	cost = 2

/*/datum/SWFuplinkspell/lightningbolt
	name = "Lightning Bolt"
	eqtype = "Offensive"
	desc = "Fires a bolt of electricity in a cardinal direction. Causes decent damage, and can go through thin walls and solid objects. You need special HAZARDOUS robes to cast this!"
	assoc_verb = */

/datum/SWFuplinkspell/forcewall
	name = "Forcewall"
	eqtype = "Defensive"
	desc = "This spell creates an unbreakable wall from where you stand that extends to your sides. It lasts for 30 seconds."
	assoc_spell = /datum/targetable/spell/forcewall

/datum/SWFuplinkspell/blink
	name = "Blink"
	eqtype = "Defensive"
	vr_allowed = 0
	desc = "This spell teleports you a short distance forwards. Useful for evasion or getting into areas."
	assoc_spell = /datum/targetable/spell/blink

/datum/SWFuplinkspell/teleport
	name = "Teleport"
	eqtype = "Defensive"
	desc = "This spell teleports you to an area of your choice, but requires a short time to charge up."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/teleport
	cost = 2

/datum/SWFuplinkspell/warp
	name = "Warp"
	eqtype = "Defensive"
	desc = "This spell teleports a visible foe away from you."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/warp

/datum/SWFuplinkspell/spellshield
	name = "Spell Shield"
	eqtype = "Defensive"
	desc = "This spell encases you in a magical shield that protects you from melee attacks and projectiles for 10 seconds. It also absorbs some of the blast of explosions."
	assoc_spell = /datum/targetable/spell/magshield

/datum/SWFuplinkspell/doppelganger
	name = "Doppelganger"
	eqtype = "Defensive"
	desc = "This spell projects a decoy in the direction you were moving while rendering you invisible and capable of moving through solid matter for a few moments."
	assoc_spell = /datum/targetable/spell/doppelganger
	cost = 2

/datum/SWFuplinkspell/knock
	name = "Knock"
	eqtype = "Utility"
	desc = "This spell opens all doors, lockers, and crates up to five tiles away. It also blows open cyborg head compartments, damaging them and exposing their brains."
	assoc_spell = /datum/targetable/spell/knock

/datum/SWFuplinkspell/empower
	name = "Empower"
	eqtype = "Utility"
	desc = "This spell causes you to turn into a hulk, and gain passive wrestling powers for a short while."
	assoc_spell = /datum/targetable/spell/mutate

/datum/SWFuplinkspell/summongolem
	name = "Summon Golem"
	eqtype = "Utility"
	desc = "This spell allows you to turn a reagent you currently hold (in a jar, bottle or other container) into a golem. Golems will attack your enemies, and release their contents as chemical smoke when destroyed."
	assoc_spell = /datum/targetable/spell/golem
	cost = 2

/datum/SWFuplinkspell/stickstosnakes
	name = "Sticks to Snakes"
	eqtype = "Utility"
	desc = "This spell allows you to turn an item into a snake. If you target a person the item in their hand will transform instead. When destroyed the snake reverts back to the original item."
	assoc_spell = /datum/targetable/spell/stickstosnakes

/datum/SWFuplinkspell/animatedead
	name = "Animate Dead"
	eqtype = "Utility"
	desc = "This spell infuses an adjacent human corpse with necromantic energy, creating a durable skeleton minion that seeks to pummel your enemies into oblivion."
	assoc_spell = /datum/targetable/spell/animatedead

/datum/SWFuplinkspell/pandemonium
	name = "Pandemonium"
	eqtype = "Miscellaneous"
	desc = "This spell causes random effects to happen. Best used only by skilled wizards."
	vr_allowed = 0
	assoc_spell = /datum/targetable/spell/pandemonium



/obj/item/SWF_uplink/proc/explode()
	var/turf/location = get_turf(src.loc)
	location.hotspot_expose(700, 125)

	explosion(src, location, 0, 0, 2, 4)

	qdel(src.master)
	qdel(src)
	return

/obj/item/SWF_uplink/attack_self(mob/user as mob)
	if(!user.mind || (user.mind && user.mind.key != src.wizard_key))
		boutput(user, "<span class='alert'><b>The spellbook is magically attuned to someone else!</b></span>")
		return
	src.add_dialog(user)
	var/html = {"
[(user.client && !user.client.use_chui) ? "<!doctype html>\n<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><meta http-equiv=\"pragma\" content=\"no-cache\"><style type='text/css'>body { font-family: Tahoma, sans-serif; font-size: 10pt; }</style><title>Wizard Spellbook</title></head><body>" : ""]

<style type="text/css">
	.spell {
		position: relative;
	}

	.spell:hover {
		background: #ddd;
	}
	.spell div {
		display: none;
		position: absolute;
		right: 0;
		top: -1em;
		background: #ddd;
		color: black;
		padding: 0.1em 0.3em;
		width: 50%;
		font-size: 80%;
		z-index: 9999;
	}
	.spell:hover div {
		display: block;
	}
	.cantbuy {
		opacity: 0.7;
	}

	.buyme, .owned {
		font-weight: bold;
	}

	.owned {
		background: rgba(0, 255, 0, 0.3);
	}
	.spell em {
		color: #888;
		margin-left: 1em;
		font-size: 90%;
		}
	.spelllink { font-weight: bold; }
</style>
	<h3>[user.real_name]'s Spellbook</h3>
	Spell slots remaining: [src.uses]
	"}
	var/list/spell_group = list()
	var/rowclass = ""
	var/rowtext = ""
	var/link = ""
	var/unusable = 0
	for (var/datum/SWFuplinkspell/SP in src.spells)
		var/cooldown = null

		if (SP.assoc_spell && ispath(SP.assoc_spell, /datum/targetable/spell))
			var/datum/targetable/spell/SPdatum = SP.assoc_spell
			cooldown = initial(SPdatum.cooldown)

		unusable = SP.SWFspell_CheckRequirements(user, src)
		switch (unusable)
			if (1)
				rowclass = "cantbuy"
				rowtext = ""
			if (2)
				rowclass = "owned"
				rowtext = "Acquired!"
			if (3)
				rowclass = "vr"
				rowtext = "Unavailable in VR"
			if (999)
				rowclass = "cantbuy"
				rowtext = "Error???"
			else
				rowclass = "buyme"
				rowtext = ""

		if (!spell_group[SP.eqtype])
			spell_group[SP.eqtype] = list("<center><b>[SP.eqtype]</b></center>")

		if (!unusable)
			link = "<a href='byond://?src=\ref[src];buyspell=\ref[SP]'><span class='spelllink [rowclass]'>[SP.name] - cost: [SP.cost]</span></a>"
		else
			link = "<span class='spelllink [rowclass]'>[SP.name] - cost: [SP.cost]</span>"

		spell_group[SP.eqtype] += "<div class='spell'>[link]<em>[rowtext]</em><div>[SP.desc][cooldown ? "<br><b>Cooldown: [cooldown / 10] sec.</b>" : ""]</div></div>"


	for (var/L in spell_group)
		html += jointext(spell_group[L], "")

	user.Browse(jointext(html, ""), "window=radio")
	onclose(user, "radio")
	return

/obj/item/SWF_uplink/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( ishuman(H)))
		return 1
	if ((usr.contents.Find(src) || (in_interact_range(src,usr) && istype(src.loc, /turf))))
		src.add_dialog(usr)

		if (href_list["buyspell"])
			var/datum/SWFuplinkspell/SP = locate(href_list["buyspell"])
			switch(SP.SWFspell_CheckRequirements(usr,src))
				if(1) boutput(usr, "<span class='alert'>You have no more magic points to spend.</span>")
				if(2) boutput(usr, "<span class='alert'>You already have this spell.</span>")
				if(3) boutput(usr, "<span class='alert'>This spell isn't availble in VR.</span>")
				if(999) boutput(usr, "<span class='alert'>Unknown Error.</span>")
				else
					SP.SWFspell_Purchased(usr,src)

		else if (href_list["aboutspell"])
			var/datum/SWFuplinkspell/SP = locate(href_list["aboutspell"])
			src.temp = "[SP.desc]"
			if (SP.cooldown)
				src.temp += "<BR>It takes [SP.cooldown] seconds to recharge after use."

		else if (href_list["lock"] && src.origradio)
			// presto chango, a regular radio again! (reset the freq too...)
			src.remove_dialog(usr)
			usr.Browse(null, "window=radio")
			var/obj/item/device/radio/T = src.origradio
			var/obj/item/SWF_uplink/R = src
			R.set_loc(T)
			T.set_loc(usr)
			// R.layer = initial(R.layer)
			R.layer = 0
			usr.u_equip(R)
			usr.put_in_hand_or_drop(T)
			R.set_loc(T)
			T.set_frequency(initial(T.frequency))
			T.attack_self(usr)
			return

		else if (href_list["selfdestruct"])
			src.temp = "<A href='byond://?src=\ref[src];selfdestruct2=1'>Self-Destruct</A>"

		else if (href_list["selfdestruct2"])
			src.selfdestruct = 1
			SPAWN(10 SECONDS)
				explode()
				return
		else
			if (href_list["temp"])
				src.temp = null

		if (ismob(src.loc))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)

	//if (istype(H.wear_suit, /obj/item/clothing/suit/wizrobe))
	//	H.wear_suit.check_abilities()
	return
