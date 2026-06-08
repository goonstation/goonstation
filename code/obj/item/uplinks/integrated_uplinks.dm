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

	disposing()
		hostpda = null
		. = ..()

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

		if(reading_synd_int)
			src.menu_message += "<h4>Syndicate Intelligence</h4>"
			src.menu_message += get_manifest(FALSE, src)
			src.menu_message += "<br>"
			src.menu_message += "<A href='byond://?src=\ref[src];back_menu=1'>Back</A>"
			return

		else if(reading_specific_synd_int)
			var/datum/db_record/staff_record = reading_specific_synd_int
			src.menu_message += "<h4>Syndicate intelligence on [staff_record["name"]]</h4>"
			src.menu_message += replacetext(staff_record["syndint"], "\n", "<br>")
			src.menu_message += "<br>"
			src.menu_message += "<A href='byond://?src=\ref[src];back_menu=1'>Back</A>"
			return

		if (src.items_general && islist(src.items_general) && length(src.items_general))
			for (var/G in src.items_general)
				var/datum/syndicate_buylist/I1 = src.items_general[G]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_general[G]]'>[I1.name]</A> ([I1.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_general[G]]'>About</A> [I1.max_buy == INFINITY  ? "" :"([src.purchase_log[I1.type] ? src.purchase_log[I1.type] : 0]/[I1.max_buy])"]</td>"
		if (src.items_job && islist(src.items_job) && length(src.items_job))
			src.menu_message += "</table><B>Job Specific:</B><BR><table cellspacing=5>"
			for (var/J in src.items_job)
				var/datum/syndicate_buylist/I2 = src.items_job[J]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_job[J]]'>[I2.name]</A> ([I2.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_job[J]]'>About</A> [I2.max_buy == INFINITY  ? "" :"([src.purchase_log[I2.type] ? src.purchase_log[I2.type] : 0]/[I2.max_buy])"]</td>"
		if (src.items_objective && islist(src.items_objective) && length(src.items_objective))
			src.menu_message += "</table><B>Objective Specific:</B><BR><table cellspacing=5>"
			for (var/O in src.items_objective)
				var/datum/syndicate_buylist/I3 = src.items_objective[O]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_objective[O]]'>[I3.name]</A> ([I3.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_objective[O]]'>About</A> [I3.max_buy == INFINITY  ? "" :"([src.purchase_log[I3.type] ? src.purchase_log[I3.type] : 0]/[I3.max_buy])"]</td>"
		if (src.items_ammo && islist(src.items_ammo) && length(src.items_ammo))
			src.menu_message += "</table><B>Special ammunition:</B><BR><table cellspacing=5>"
			for (var/A in src.items_ammo)
				var/datum/syndicate_buylist/I4 = src.items_ammo[A]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_ammo[A]]'>[I4.name]</A> ([I4.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_ammo[A]]'>About</A> [I4.max_buy == INFINITY  ? "" :"([src.purchase_log[I4.type] ? src.purchase_log[I4.type] : 0]/[I4.max_buy])"]</td>"
		if (src.items_telecrystal && islist(src.items_telecrystal) && length(src.items_telecrystal))
			src.menu_message += "</table><B>Ejectable [syndicate_currency]:</B><BR><table cellspacing=5>"
			for (var/T in src.items_telecrystal)
				var/datum/syndicate_buylist/I5 = src.items_telecrystal[T]
				src.menu_message += "<tr><td><A href='byond://?src=\ref[src];buy_item=\ref[src.items_telecrystal[T]]'>[I5.name]</A> ([I5.cost])</td><td><A href='byond://?src=\ref[src];abt_item=\ref[src.items_telecrystal[T]]'>About</A> [I5.max_buy == INFINITY  ? "" :"([src.purchase_log[I5.type] ? src.purchase_log[I5.type] : 0]/[I5.max_buy])"]</td>"

		src.menu_message += "</table><HR>"
		if(has_synd_int && !src.is_VR_uplink)
			src.menu_message += "<A href='byond://?src=\ref[src];synd_int=1'>Syndicate Intelligence</A><BR>"
			src.menu_message += "<HR>"
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
				if (src.purchase_log[I.type] >= I.max_buy)
					boutput(usr, SPAN_ALERT("You have already bought as many of those as you can!"))
					return
				if (src.uses < I.cost)
					boutput(usr, SPAN_ALERT("The uplink doesn't have enough [syndicate_currency] left for that!"))
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
					var/obj/item = new uplink_item(get_turf(src.hostpda))
					I.run_on_spawn(item, usr, FALSE, src)
				if (src.is_VR_uplink == 0)
					var/datum/eventRecord/AntagItemPurchase/antagItemPurchaseEvent = new()
					antagItemPurchaseEvent.buildAndSend(usr, I.name, I.cost)
					if (!src.purchase_log[I.type])
						src.purchase_log[I.type] = 0
					src.purchase_log[I.type]++

		else if (href_list["abt_item"])
			var/datum/syndicate_buylist/I = locate(href_list["abt_item"])
			var/item_about = "<b>Error:</b> We're sorry, but there is no current entry for this item!<br>For full information on Syndicate Tools, call 1-555-SYN-DKIT."
			if(I.desc) item_about = I.desc

			src.print_to_host("<b>Extended Item Information:</b><hr>[item_about]<hr><A href='byond://?src=\ref[src];back=1'>Back</A>")
			return

		else if (href_list["synd_int"] && !src.is_VR_uplink)
			reading_synd_int = TRUE

		else if (href_list["select_exp"])
			var/datum/db_record/staff_record = locate(href_list["select_exp"])
			reading_specific_synd_int = staff_record
			reading_synd_int = FALSE

		else if (href_list["back_menu"])
			if(reading_synd_int)
				reading_synd_int = FALSE
			if(reading_specific_synd_int)
				reading_specific_synd_int = null
				reading_synd_int = TRUE

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

	omni
		purchase_flags = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_NUKE_OP | UPLINK_HEAD_REV | UPLINK_NUKE_COMMANDER | UPLINK_SPY_THIEF

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
				R.protected_radio = TRUE
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

	omni
		purchase_flags = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_NUKE_OP | UPLINK_HEAD_REV | UPLINK_NUKE_COMMANDER | UPLINK_SPY_THIEF
