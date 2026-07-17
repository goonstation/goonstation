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
		if (!src.vr_check(usr))
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

		var/categorised_data = src.get_categorised_item_data()
		for(var/category in categorised_data)
			src.menu_message += "</table><B>[category]:</B><BR><table cellspacing=5>"
			for(var/item_data in categorised_data[category])
				var/name_text = "<A href='byond://?src=\ref[src];buy_item=[item_data["ref"]]'>[item_data["name"]]</A>"
				var/desc_text = "<A href='byond://?src=\ref[src];abt_item=[item_data["ref"]]'>About</A>"
				var/purchased_amount = src.purchase_log[item_data["type"]] ? src.purchase_log[item_data["type"]] : 0
				var/purchase_limit_text = item_data["purchase_limit"] == INFINITY ? "" : "([purchased_amount]/[item_data["purchase_limit"]])"
				src.menu_message += "<tr><td> [name_text]([item_data["cost"]])</td><td> [desc_text] [purchase_limit_text]</td>"
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
		if (!src.vr_check(usr))
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
	uplink_ui_type = UPLINK_UI_TGUI
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

	lock(mob/user)
		. = ..()
		if(!.) return //Failed to lock, don't continue.
		if (!isnull(src.origradio) && istype(src.origradio, /obj/item/device/radio))
			var/obj/item/device/radio/T = src.origradio
			src.set_loc(T)
			T.set_loc(user)
			user.u_equip(src)
			user.put_in_hand_or_drop(T)
			src.set_loc(T)
			T.set_frequency(initial(T.frequency))
			T.AttackSelf(user)

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
