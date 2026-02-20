/obj/item/uplink
	name = "uplink"
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0

	var/uses = 12 // Amount of telecrystals.
	var/list/datum/syndicate_buylist/items_general = list() // See setup() and validate_spawn().
	var/list/datum/syndicate_buylist/items_job = list()
	var/list/datum/syndicate_buylist/items_objective = list()
	var/list/datum/syndicate_buylist/items_telecrystal = list()
	var/list/datum/syndicate_buylist/items_ammo = list()
	var/is_VR_uplink = 0
	var/lock_code = null
	var/lock_code_autogenerate = 0
	var/locked = 0
	var/reading_synd_int = FALSE
	var/reading_specific_synd_int = null
	var/has_synd_int = TRUE
#ifdef BONUS_POINTS
	uses = 9999
#endif

	var/use_default_GUI = 0 // Use the parent's HTML interface (less repeated code).
	var/temp = null
	var/selfdestruct = 0
	var/can_selfdestruct = 0
	var/datum/syndicate_buylist/reading_about = null

	/// Bitflags for what items this uplink can buy (see `_std/defines/uplink.dm` for flags)
	var/purchase_flags
	var/owner_ckey = null

	/// Associative list, where keys are /datum/syndicate_buylist instances and values are the number of purchases.
	var/list/purchase_log = list()

	// Spawned uplinks for which setup() wasn't called manually only get the standard (generic) items.
	New()
		..()
		if (istype(get_area(src), /area/sim/gunsim))
			src.is_VR_uplink = TRUE
		SPAWN(1 SECOND)
			if (src && istype(src) && (!length(src.items_general) && !length(src.items_job) && !length(src.items_objective) && !length(src.items_telecrystal) && !length(src.items_ammo)))
				src.setup()

	disposing()
		reading_specific_synd_int = null
		reading_about = null
		..()

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
		if (!islist(src.items_ammo))
			src.items_ammo = list()

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
					if (!isnukeop(ownermind.current) && istype(S, /datum/syndicate_buylist/traitor))
						if (!S.objective && !S.job && !src.items_general.Find(S))
							src.items_general.Add(S)
						if (S.ammo)
							src.items_ammo.Add(S)
							src.items_general.Remove(S)


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

		if (length(src.items_ammo))
			var/list/sort4 = list()

			for (var/datum/syndicate_buylist/S4 in src.items_ammo)
				var/name = S4.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort4[name] = S4

			src.items_ammo = sortList(sort4, /proc/cmp_text_asc)

		if (length(src.items_telecrystal))
			var/list/sort5 = list()

			for (var/datum/syndicate_buylist/S5 in src.items_telecrystal)
				var/name = S5.name
				if (name in names)
					namecounts[name]++
					name = text("[] ([])", name, namecounts[name])
				else
					names.Add(name)
					namecounts[name] = 1

				sort5[name] = S5

			src.items_telecrystal = sortList(sort5, /proc/cmp_text_asc)

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
		if(src.locked)
			return
		if (istype(W, /obj/item/uplink_telecrystal/trick))
			boutput(user, SPAN_ALERT("The [W] explodes!"))
			var/turf/T = get_turf(W.loc)
			if(T)
				T.hotspot_expose(700,125)
				explosion(W, T, -1, -1, 2, 3) //about equal to a PDA bomb
			W.set_loc(user.loc)
			qdel(W)
		else if (istype(W, /obj/item/uplink_telecrystal))
			var/crystal_amount = W.amount
			uses = uses + crystal_amount
			boutput(user, "You insert [crystal_amount] [syndicate_currency] into the [src].")
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

		else if(reading_synd_int)
			dat += "<h4>Syndicate Intelligence</h4>"
			dat += get_manifest(FALSE, src)
			dat += "<br>"
			dat += "<A href='byond://?src=\ref[src];back=1'>Back</A>"
			dat += "<br>"

		else if(reading_specific_synd_int)
			var/datum/db_record/staff_record = reading_specific_synd_int
			dat += "<h4>Syndicate intelligence on [staff_record["name"]]</h4>"
			dat += staff_record["syndint"]
			dat += "<br>"
			dat += "<A href='byond://?src=\ref[src];back=1'>Back</A>"
			dat += "<br>"

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
					dat += "<I>Each item costs a number of [syndicate_currency] as indicated by the number following their name, and if it has a maximum number of times it can be purchased, that will follow the cost. </I><BR><table cellspacing=5>"
				if (src.items_telecrystal && islist(src.items_telecrystal) && length(src.items_telecrystal))
					dat += "</table><B>Ejectable [syndicate_currency]:</B><BR><table cellspacing=5>"
					for (var/T in src.items_telecrystal)
						var/datum/syndicate_buylist/I4 = src.items_telecrystal[T]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_telecrystal[T]]'>[I4.name]</A> ([I4.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_telecrystal[T]]'>About</A> [I4.max_buy == INFINITY  ? "" :"([src.purchase_log[I4.type] ? src.purchase_log[I4.type] : 0]/[I4.max_buy])"]</td>"
				if (src.items_objective && islist(src.items_objective) && length(src.items_objective))
					dat += "</table><B>Objective Specific:</B><BR><table cellspacing=5>"
					for (var/O in src.items_objective)
						var/datum/syndicate_buylist/I3 = src.items_objective[O]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_objective[O]]'>[I3.name]</A> ([I3.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_objective[O]]'>About</A> [I3.max_buy == INFINITY  ? "" :"([src.purchase_log[I3.type] ? src.purchase_log[I3.type] : 0]/[I3.max_buy])"]</td>"
				if (src.items_job && islist(src.items_job) && length(src.items_job))
					dat += "</table><B>Job Specific:</B><BR><table cellspacing=5>"
					for (var/J in src.items_job)
						var/datum/syndicate_buylist/I2 = src.items_job[J]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_job[J]]'>[I2.name]</A> ([I2.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_job[J]]'>About</A> [I2.max_buy == INFINITY  ? "" :"([src.purchase_log[I2.type] ? src.purchase_log[I2.type] : 0]/[I2.max_buy])"]</td>"
				if (src.items_general && islist(src.items_general) && length(src.items_general))
					dat += "</table><B>Standard Equipment:</B><BR><table cellspacing=5>"
					for (var/G in src.items_general)
						var/datum/syndicate_buylist/I1 = src.items_general[G]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_general[G]]'>[I1.name]</A> ([I1.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_general[G]]'>About</A> [I1.max_buy == INFINITY  ? "" :"([src.purchase_log[I1.type] ? src.purchase_log[I1.type] : 0]/[I1.max_buy])"]</td>"
				if (src.items_ammo && islist(src.items_ammo) && length(src.items_ammo))
					dat += "</table><B>Special ammunition:</B><BR><table cellspacing=5>"
					for (var/A in src.items_ammo)
						var/datum/syndicate_buylist/I5 = src.items_ammo[A]
						dat += "<tr><td><A href='byond://?src=\ref[src];spawn=\ref[src.items_ammo[A]]'>[I5.name]</A> ([I5.cost])</td><td><A href='byond://?src=\ref[src];about=\ref[src.items_ammo[A]]'>About</A> [I5.max_buy == INFINITY  ? "" :"([src.purchase_log[I5.type] ? src.purchase_log[I5.type] : 0]/[I5.max_buy])"]</td>"
				dat += "</table>"
				var/do_divider = 1

				if(has_synd_int && !is_VR_uplink)
					dat += "<HR><A href='byond://?src=\ref[src];synd_int=1'>Syndicate Intelligence</A><BR>"

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

		for(var/S in items_ammo)
			if (SB == items_ammo[S])
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
					T.AttackSelf(usr)
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
					boutput(usr, SPAN_ALERT("The uplink doesn't have enough [syndicate_currency] left for that!"))
					return
				if (src.purchase_log[I.type] >= I.max_buy)
					boutput(usr, SPAN_ALERT("You have already bought as many of those as you can!"))
					return
				src.uses = max(0, src.uses - I.cost)

				if (src.purchase_flags & UPLINK_TRAITOR)
					var/datum/antagonist/traitor/antagonist_role = usr.mind?.get_antagonist(ROLE_TRAITOR)
					if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
						antagonist_role.purchased_items.Add(I)

				if (src.purchase_flags & UPLINK_HEAD_REV)
					var/datum/antagonist/head_revolutionary/antagonist_role = usr.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY)
					if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
						antagonist_role.purchased_items.Add(I)

				if (src.purchase_flags & UPLINK_NUKE_OP)
					var/datum/antagonist/nuclear_operative/antagonist_role = usr.mind?.get_antagonist(ROLE_NUKEOP) || usr.mind?.get_antagonist(ROLE_NUKEOP_COMMANDER)
					if (istype(antagonist_role) && !istype(I, /datum/syndicate_buylist/generic/telecrystal))
						antagonist_role.uplink_items.Add(I)

				logTheThing(LOG_DEBUG, usr, "bought this from [owner_ckey || "unknown"]'s uplink: [I.name] (in [src.loc])")

			if (length(I.items) > 0)
				for (var/uplink_item in I.items)
					var/obj/item = new uplink_item(get_turf(src))
					I.run_on_spawn(item, usr, FALSE, src)
				if (src.is_VR_uplink == 0)
					var/datum/eventRecord/AntagItemPurchase/antagItemPurchaseEvent = new()
					antagItemPurchaseEvent.buildAndSend(usr, I.name, I.cost)
					if (!src.purchase_log[I.type])
						src.purchase_log[I.type] = 0
					src.purchase_log[I.type]++

		else if (href_list["about"])
			reading_about = locate(href_list["about"])

		else if (href_list["back"])
			if(reading_about)
				reading_about = null
			if(reading_synd_int)
				reading_synd_int = FALSE
			if(reading_specific_synd_int)
				reading_specific_synd_int = null
				reading_synd_int = TRUE

		else if (href_list["selfdestruct"] && src.can_selfdestruct == 1)
			src.selfdestruct = 1
			SPAWN(10 SECONDS)
				if (src)
					src.explode()

		else if (href_list["synd_int"] && !src.is_VR_uplink)
			reading_synd_int = TRUE

		else if (href_list["select_exp"])
			var/datum/db_record/staff_record = locate(href_list["select_exp"])
			reading_specific_synd_int = staff_record
			reading_synd_int = FALSE

		else if (href_list["temp"])
			src.temp = null

		src.AttackSelf(usr)
		return
#undef CHECK1
#undef CHECK2
