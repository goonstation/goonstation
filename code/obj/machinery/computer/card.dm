/obj/machinery/computer/card
	name = "identification computer"
	icon_state = "id"
	circuit_type = /obj/item/circuitboard/card
	var/obj/item/card/id/scan = null
	var/obj/item/card/id/modify = null
	var/obj/item/eject = null //Overrides modify slot set_loc. sometimes we want to eject something that's not a card. like an implant!
	var/authenticated = 0
	var/mode = 0
	var/printing = null
	var/list/scan_access = null
	var/list/custom_names = list("Custom 1", "Custom 2", "Custom 3")
	var/custom_access_list = list(list(),list(),list())
	var/list/civilian_access_list = list(access_morgue, access_maint_tunnels, access_chapel_office, access_tech_storage, access_bar, access_janitor, access_crematorium, access_kitchen, access_hydro, access_ranch)
	var/list/engineering_access_list = list(access_engineering, access_engineering_storage, access_engineering_power, access_engineering_engine, access_engineering_mechanic, access_engineering_atmos, access_engineering_control)
	var/list/supply_access_list = list(access_cargo, access_supply_console, access_mining, access_mining_outpost)
	var/list/research_access_list = list(access_tox, access_tox_storage, access_research, access_chemistry, access_researchfoyer, access_artlab, access_telesci, access_robotdepot)
	var/list/medical_access_list = list(access_medical, access_medical_lockers, access_medlab, access_robotics, access_pathology)
	var/list/security_access_list = list(access_security, access_brig, access_forensics_lockers, access_maxsec, access_armory, access_securitylockers, access_carrypermit, access_contrabandpermit, access_ticket)
	var/list/command_access_list = list(access_research_director, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_engineering_chief, access_medical_director, access_head_of_personnel, access_dwaine_superuser, access_money)
	var/list/allowed_access_list
	var/departmentcomp = FALSE
	var/department = 0 //0 = standard, 1 = engineering, 2 = medical, 3 = research, 4 = security
	req_access = list(access_change_ids)
	desc = "A computer that allows an authorized user to change the identification of other ID cards."

	deconstruct_flags = DECON_MULTITOOL
	light_r = 0.7
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/card/New()
	..()
	src.allowed_access_list = civilian_access_list + engineering_access_list + supply_access_list + research_access_list + command_access_list + security_access_list - access_maxsec - access_armory
/obj/machinery/computer/card/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "id1"
/obj/machinery/computer/card/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "id2"

/obj/machinery/computer/card/portable
	name = "portable identification computer"
	icon_state = "idportC"
	density = 0
	var/obj/item/cell/cell //We have limited power! Immersion!!
	var/setup_charge_maximum = 15000
	var/deployed = 1

	New()
		..()
		src.AddComponent(/datum/component/foldable,/obj/item/objBriefcase/blue_green_stripe)
		src.cell = new /obj/item/cell(src)
		src.cell.maxcharge = setup_charge_maximum
		src.cell.charge = src.cell.maxcharge

		var/datum/component/foldable/fold_component = src.GetComponent(/datum/component/foldable) //Fold up into a briefcase the first spawn
		if(!fold_component?.the_briefcase)
			return
		var/obj/item/objBriefcase/briefcase = fold_component.the_briefcase
		if (briefcase)
			briefcase.set_loc(get_turf(src))
			src.set_loc(briefcase)

	disposing()
		if (src.cell)
			src.cell.dispose()
			src.cell = null
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/disk/data/floppy)) //IDK i just dont want to screw this up
			return

		else if (ispryingtool(W))
			if(!src.cell)
				boutput(user, SPAN_ALERT("There is no energy cell inserted!"))
				return

			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			src.cell.set_loc(get_turf(src))
			src.cell = null
			user.visible_message(SPAN_ALERT("[user] removes the power cell from [src]!."),SPAN_ALERT("You remove the power cell from [src]!"))
			src.power_change()
			return

		else if (istype(W, /obj/item/cell))
			if(src.cell)
				boutput(user, SPAN_ALERT("There is already an energy cell inserted!"))

			else
				user.drop_item()
				W.set_loc(src)
				src.cell = W
				boutput(user, "You insert [W].")
				src.power_change()
				tgui_process.update_uis(src)

			return

		else
			src.Attackhand(user)

		return

	powered()
		if(!src.cell || src.cell.charge <= 0)
			return 0

		return 1

	use_power(var/amount, var/chan=EQUIP)
		if(!src.cell || !src.deployed)
			return

		cell.use(amount / 100)

		src.power_change()
		return

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null


/obj/machinery/computer/card

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "IDComputer", name)
			ui.open()

	ui_static_data()
		. = list()

		var/list/civilian_jobs = list()
		var/list/engineering_jobs = list()
		var/list/research_jobs = list()
		var/list/medical_jobs = list()
		var/list/security_jobs = list()
		var/list/command_jobs = list()

		for (var/datum/job/job as anything in concrete_typesof(/datum/job/civilian))
			if (initial(job.name) && job != /datum/job/civilian/AI && job != /datum/job/civilian/cyborg)
				civilian_jobs.Add(initial(job.name))
		for (var/datum/job/job as anything in concrete_typesof(/datum/job/engineering))
			if (initial(job.name))
				engineering_jobs.Add(initial(job.name))
		for (var/datum/job/job as anything in concrete_typesof(/datum/job/research))
			if (initial(job.name))
				research_jobs.Add(initial(job.name))
		for (var/datum/job/job as anything in concrete_typesof(/datum/job/medical))
			if (initial(job.name))
				medical_jobs.Add(initial(job.name))
		for (var/datum/job/job as anything in concrete_typesof(/datum/job/security))
			if (initial(job.name))
				security_jobs.Add(initial(job.name))
		for (var/datum/job/job as anything in concrete_typesof(/datum/job/command))
			if (initial(job.name) && job != /datum/job/command/head_of_security)
				command_jobs.Add(initial(job.name))

		var/list/civilian_access = list()
		var/list/engineering_access = list()
		var/list/supply_access = list()
		var/list/research_access = list()
		var/list/medical_access = list()
		var/list/security_access = list()
		var/list/command_access = list()

		for(var/A in access_name_lookup)
			if (access_name_lookup[A] in civilian_access_list)
				civilian_access.Add(access_data(A))
			if (access_name_lookup[A] in engineering_access_list)
				engineering_access.Add(access_data(A))
			if (access_name_lookup[A] in supply_access_list)
				supply_access.Add(access_data(A))
			if (access_name_lookup[A] in research_access_list)
				research_access.Add(access_data(A))
			if (access_name_lookup[A] in medical_access_list)
				medical_access.Add(access_data(A))
			if (access_name_lookup[A] in security_access_list)
				security_access.Add(access_data(A))
			if (access_name_lookup[A] in command_access_list)
				command_access.Add(access_data(A))

		if (src.departmentcomp)
			switch(src.department)
				if (1) // eng
					civilian_jobs = list("Staff Assistant")
					//stock engineering_jobs are good
					medical_jobs = null
					research_jobs = null
					security_jobs = null
					command_jobs = null
				if (2) // med
					civilian_jobs = list("Staff Assistant")
					engineering_jobs = null
					// stock medical_jobs are good
					research_jobs = null
					security_jobs = null
					command_jobs = null
				if (3) // research
					civilian_jobs = list("Staff Assistant")
					engineering_jobs = null
					medical_jobs = null
					// stock research_jobs are good
					security_jobs = null
					command_jobs = null
				if (4) // sec
					civilian_jobs = list("Staff Assistant", "Clown")
					engineering_jobs = null
					medical_jobs = null
					research_jobs = null
					//stock security_jobs are good
					command_jobs = null

		.["standard_jobs"] = list(
			list(name = "Civilian", color = "blue", jobs = civilian_jobs, style="civilian"),
			list(name = "Engineering and Supply", color = "yellow", jobs = engineering_jobs, style="engineering"),
			list(name = "Research", color = "purple", jobs = research_jobs, style="research"),
			list(name = "Medical", color = "blue", jobs = medical_jobs, style="medical"),
			list(name = "Security", color = "red", jobs = security_jobs, style="security"),
			list(name = "Command", color = "green", jobs = command_jobs, style="command"),
		)

		.["accesses_by_area"] = list(
			list(name = "Civilian", color = "blue", accesses = civilian_access),
			list(name = "Engineering", color = "yellow", accesses = engineering_access),
			list(name = "Supply", color = "yellow", accesses = supply_access),
			list(name = "Science", color = "purple", accesses = research_access),
			list(name = "Medical", color = "blue", accesses = medical_access),
			list(name = "Security", color = "red", accesses = security_access),
			list(name = "Command", color = "green", accesses = command_access),
		)

		.["icons"] = list(
			list(style = "none", name = "Plain", card_look = "id", icon = getCardBase64Img("id")),
			list(style = "civilian", name = "Civilian", card_look = "id_civ", icon = getCardBase64Img("id_civ")),
			list(style = "engineering", name = "Engineering", card_look = "id_eng", icon = getCardBase64Img("id_eng")),
			list(style = "research", name = "Research", card_look = "id_res", icon = getCardBase64Img("id_res")),
			list(style = "medical", name = "Medical", card_look = "id_med", icon = getCardBase64Img("id_med")),
			list(style = "security", name = "Security", card_look = "id_sec", icon = getCardBase64Img("id_sec")),
			list(style = "command", name = "Command", card_look = "id_com", icon = getCardBase64Img("id_com")),
		)

	ui_data(mob/user)
		. = list()

		if (src.mode) // accessing crew manifest
			.["mode"] = "manifest"
			.["manifest"] = get_manifest()
		else
			var/target_name
			var/target_owner
			var/target_rank

			if(src.modify)
				target_name = src.modify.name

			if(src.modify && src.modify.registered)
				target_owner = src.modify.registered

			if(src.modify && src.modify.assignment)
				target_rank = src.modify.assignment
			else
				target_rank = "Unassigned"

			if (src.eject)
				target_name = src.eject.name

			.["target_name"] = target_name
			.["target_owner"] = target_owner
			.["target_rank"] = target_rank

			var/scan_name
			if(src.scan)
				scan_name = src.scan.name

			.["scan_name"] = scan_name

			//When both IDs are inserted
			if (src.authenticated && src.modify)
				.["mode"] = "authenticated"
				.["pronouns"] = src.modify.pronouns?.name

				.["custom_names"] = custom_names

				.["target_card_look"] = src.modify.icon_state

				.["target_accesses"] = src.modify.access
				if(!isobserver(user))
					user.unlock_medal("Identity Theft", 1)

			else
				.["mode"] = "unauthenticated"

	proc/access_data(var/A)
		. = list(list(
			name = A,
			id = access_name_lookup[A]
		))


	proc/getCardBase64Img(var/icon_state)
		var/static/base64_preview_cache = list() // Base64 preview images for item types, for use in ui interfaces.

		. = base64_preview_cache[icon_state]
		if(isnull(.))
			var/icon/result_icon = icon('icons/obj/items/card.dmi', icon_state)

			if(result_icon)
				. = icon2base64(result_icon)
			else
				. = "" // Empty but not null
			base64_preview_cache[icon_state] = .

	ui_act(action, params)
		. = ..()
		if(.)
			return

		switch(action)
			if ("modify")
				if (src.modify)
					src.modify.update_name()
					if (src.eject)
						usr.put_in_hand_or_eject(src.eject)
						src.eject = null
					else
						usr.put_in_hand_or_eject(src.modify)
					src.modify = null
				else
					var/obj/item/I = usr.equipped()
					if (!istype(I,/obj/item/card/id))
						I = get_card_from(I)
					if (istype(I, /obj/item/card/id))
						usr.drop_item()
						if (src.eject)
							src.eject.set_loc(src)
						else
							I.set_loc(src)
						src.modify = I
					else if (istype(I, /obj/item/magtractor))
						var/obj/item/magtractor/mag = I
						if (istype(mag.holding, /obj/item/card/id))
							I = mag.holding
							mag.dropItem(0)
							if (src.eject)
								src.eject.set_loc(src)
							else
								I.set_loc(src)
							src.modify = I
					if (I && !src.modify)
						boutput(usr, SPAN_NOTICE("[I] won't fit in the modify slot."))
				src.authenticated = 0
				src.scan_access = null

				try_authenticate()
			if ("scan")
				if (src.scan)
					usr.put_in_hand_or_eject(src.scan)
					src.scan = null
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/card/id))
						usr.drop_item()
						I.set_loc(src)
						src.scan = I
					else if (istype(I, /obj/item/magtractor))
						var/obj/item/magtractor/mag = I
						if (istype(mag.holding, /obj/item/card/id))
							I = mag.holding
							mag.dropItem(0)
							I.set_loc(src)
							src.modify = I
					else
						boutput(usr, SPAN_NOTICE("[I] won't fit in the authentication slot."))
				src.authenticated = 0
				src.scan_access = null

				try_authenticate()
			if("access")
				if(src.authenticated)
					var/access_type = text2num_safe(params["access"])
					var/access_allowed = text2num_safe(params["allowed"])
					if(access_type in get_all_accesses())
						if(!access_allowed)
							src.modify.access -= access_type
						else
							src.modify.access += access_type
						src.modify.name = "[src.modify.registered]'s ID Card ([src.modify.assignment])"
						logTheThing(LOG_STATION, usr, "[access_allowed ? "adds" : "removes"] [get_access_desc(access_type)] access to the ID card (<b>[src.modify.registered]</b>) using [src.scan.registered]'s ID.")

			if ("pronouns")
				if (src.authenticated && src.modify)
					if(params["pronouns"] == "next")
						if(src.modify?.pronouns)
							src.modify.pronouns = src.modify.pronouns.next_pronouns()
						else
							src.modify.pronouns = get_singleton(/datum/pronouns/theyThem)
					else if(params["pronouns"] == "remove")
						src.modify.pronouns = null

			if ("assign")
				if (src.authenticated && src.modify)
					var/t1 = params["assign"]

					if(t1 == "Head of Security")
						return

					if (t1 == "Custom Assignment")
						t1 = tgui_input_text(usr, "Enter a custom job assignment.", "Assignment")
						if(!src.modify || !src.authenticated)
							return
						t1 = strip_html(t1, 100, 1)
						logTheThing(LOG_STATION, usr, "changes the assignment on the ID card (<b>[src.modify.registered]</b>) from <b>[src.modify.assignment]</b> to <b>[t1]</b>.")
						playsound(src.loc, "keyboard", 50, 1, -15)
					else
						// preserve accesses which are otherwise unobtainable
						var/bonus_access = list()
						for (var/access in src.modify.access)
							if (!(access in get_all_accesses())) //fuck this proc name
								bonus_access += list(access)
						src.modify.access = get_access(t1) + bonus_access
						logTheThing(LOG_STATION, usr, "changes the access and assignment on the ID card (<b>[src.modify.registered]</b>) to <b>[t1]</b>.")

					//Wire: This possibly happens after the input() above, so we re-do the initial checks
					if (src.authenticated && src.modify)
						src.modify.assignment = t1

					if (params["style"])
						update_card_style(params["style"])

					src.modify.name = "[src.modify.registered]'s ID Card ([src.modify.assignment])"

			if ("reg")
				if (src.authenticated)
					var/t2 = src.modify

					var/t1 = tgui_input_text(usr, "What name?", "ID computer")
					t1 = strip_html(t1, 100, 1)

					if ((src.authenticated && src.modify == t2 && (in_interact_range(src, usr) || (issilicon(usr) || isAI(usr))) && istype(src.loc, /turf)))
						logTheThing(LOG_STATION, usr, "changes the registered name on the ID card from <b>[src.modify.registered]</b> to <b>[t1]</b>.")
						src.modify.registered = t1

						src.modify.name = "[src.modify.registered]'s ID Card ([src.modify.assignment])"

						playsound(src.loc, "keyboard", 50, 1, -15)

			if ("pin")
				if (src.authenticated)
					var/currentcard = src.modify

					var/newpin = tgui_input_pin(usr, "Enter a new PIN between [PIN_MIN] and [PIN_MAX].", "ID Computer", null, PIN_MAX, PIN_MIN)
					if (newpin && (src.authenticated && src.modify == currentcard && (in_interact_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(src.loc, /turf)))
						logTheThing(LOG_STATION, usr, "changes the pin on the ID card (<b>[src.modify.registered]</b>) to [src.modify.pin].")
						src.modify.pin = newpin
						playsound(src.loc, "keyboard", 50, 1, -15)

			if ("mode")
				src.mode = text2num_safe(params["mode"])
			if ("print")
				if (!( src.printing ))
					src.printing = 1
					sleep(5 SECONDS)
					var/obj/item/paper/P = new /obj/item/paper
					P.set_loc(src.loc)

					var/t1 = "<B>Crew Manifest:</B><hr>"
					t1 += get_manifest()
					P.info = t1
					P.name = "paper- 'Crew Manifest'"
					src.printing = null
			if ("mode")
				src.authenticated = 0
				src.scan_access = null
				src.mode = text2num_safe(params["mode"])
			if ("style")
				update_card_style(params["style"])
			if ("save")
				var/slot = text2num_safe(params["save"])
				if (!src.modify.assignment)
					src.custom_names[slot] = "Custom [slot]"
				else
					src.custom_names[slot] = src.modify.assignment
				src.custom_access_list[slot] = src.modify.access.Copy()
				src.custom_access_list[slot] &= allowed_access_list //prevent saving non-allowed accesses
				logTheThing(LOG_STATION, usr, "saves custom assignment <b>[src.custom_names[slot]]</b>.")
			if ("apply")
				var/slot = text2num_safe(params["apply"])
				src.modify.assignment = src.custom_names[slot]
				var/list/selected_access_list = src.custom_access_list[slot]
				src.modify.access = selected_access_list.Copy()
				src.modify.name = "[src.modify.registered]'s ID Card ([src.modify.assignment])"
				logTheThing(LOG_STATION, usr, "changes the access and assignment on the ID card (<b>[src.modify.registered]</b>) to custom assignment <b>[src.modify.assignment]</b>.")
			if ("modify")
				src.modify.name = "[src.modify.registered]'s ID Card ([src.modify.assignment])"
			if ("eject")
				if (istype(src.eject,/obj/item/implantcase/access))
					var/obj/item/implantcase/access/A = src.eject
					var/obj/item/implant/access/I = A.imp
					var/iassign = "None"
					if (istype(I) && I.access)
						iassign = I.access.assignment
					A.name = "glass case - 'Electronic Access' ([iassign])"
				else if (istype(src.eject, /obj/item/implant/access))
					var/obj/item/implant/access/A = src.eject
					A.name = "electronic access implant ([A.access ? A.access.assignment : "None"])"

		. = TRUE

	proc/update_card_style(band_color)
		if(src.modify.keep_icon == FALSE) // ids that are FALSE will update their icon if the job changes
			if (band_color == "none")
				src.modify.icon_state = "id"
			if (band_color == "civilian")
				src.modify.icon_state = "id_civ"
			if (band_color == "engineering")
				src.modify.icon_state = "id_eng"
			if (band_color == "research")
				src.modify.icon_state = "id_res"
			if (band_color == "medical")
				src.modify.icon_state = "id_med"
			if (band_color == "security")
				src.modify.icon_state = "id_sec"
			if (band_color == "command")
				src.modify.icon_state = "id_com"

	proc/try_authenticate()
		if ((!( src.authenticated ) && (src.scan || ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr))) && (src.modify || src.mode)))
			if (src.check_access(src.scan))
				src.authenticated = 1
				src.scan_access = src.scan.access

/obj/machinery/computer/card/attack_hand(var/mob/user)
	if(..())
		return

	ui_interact(user)

/obj/machinery/computer/card/attackby(obj/item/I, mob/user)
	//grab the ID card from an access implant if this is one
	var/modify_only = 0
	if (!istype(I,/obj/item/card/id))
		I = get_card_from(I)
		modify_only = 1

	if (modify_only && src.eject && !src.scan && src.modify)
		boutput(user, SPAN_NOTICE("[src.eject] will not work in the authentication card slot."))
		return
	else if (istype(I, /obj/item/card/id))
		if (!src.scan && !modify_only)
			boutput(user, SPAN_NOTICE("You insert [I] into the authentication card slot."))
			user.drop_item()
			I.set_loc(src)
			src.scan = I
		else if (!src.modify)
			boutput(user, SPAN_NOTICE("You insert [src.eject ? src.eject : I] into the target card slot."))
			user.drop_item()
			if (src.eject)
				src.eject.set_loc(src)
			else
				I.set_loc(src)
			src.modify = I

		try_authenticate()
		tgui_process.update_uis(src)

		return
	else
		..()

	return

/obj/machinery/computer/card/proc/get_card_from(obj/item/I as obj)
	if (istype(I, /obj/item/implantcase/access))
		src.eject = I
		var/obj/item/implantcase/access/A = I
		if (A.imp)
			return A.imp:access
	else if (istype(I, /obj/item/implant/access)) //accept access implant - get their ID
		src.eject = I
		return I:access
	return I

/obj/machinery/computer/card/department
	name = "department identification computer"
	departmentcomp = TRUE

/obj/machinery/computer/card/department/engineering
	color = "#ffffcc" // look there's a lot of icons to edit just to add a single stripe of color to these computers
	department = 1
	req_access = list(access_engineering_chief)

	civilian_access_list = list(access_maint_tunnels, access_tech_storage)
	// stock engineering_access_list
	// stock supply_access_list
	medical_access_list = null
	research_access_list = null
	security_access_list = null
	command_access_list = list(access_eva) //allow heads to give out eva access in emergencies

/obj/machinery/computer/card/department/medical
	color = "#99ccff"
	department = 2
	req_access = list(access_medical_director)

	civilian_access_list = list(access_morgue, access_maint_tunnels, access_tech_storage)
	engineering_access_list = null
	supply_access_list = null
	// stock medical_access_list
	research_access_list = null
	security_access_list = null
	command_access_list = list(access_eva)


/obj/machinery/computer/card/department/research
	color = "#cc99ff"
	department = 3
	req_access = list(access_research_director)

	civilian_access_list = list(access_maint_tunnels, access_tech_storage)
	engineering_access_list = null
	supply_access_list = null
	medical_access_list = null
	// stock research_access_list
	security_access_list = null
	command_access_list = list(access_eva)


/obj/machinery/computer/card/department/security
	color = "#ff9999"
	department = 4
	req_access = list(access_maxsec)

	civilian_access_list = list(access_morgue, access_maint_tunnels, access_tech_storage, access_bar, access_crematorium, access_kitchen, access_hydro)
	engineering_access_list = list(access_engineering, access_engineering_control)
	supply_access_list = list(access_cargo)
	medical_access_list = list(access_medical)
	research_access_list = list(access_research, access_chemistry, access_researchfoyer)
	security_access_list = list(access_security, access_brig, access_forensics_lockers, access_maxsec, access_armory, access_securitylockers, access_carrypermit, access_contrabandpermit)
	command_access_list = list(access_eva)

