/datum/datacore
	var/name = "datacore"
	var/datum/record_database/medical = new(list("name", "id"))
	var/datum/record_database/general = new(list("name", "id"))
	var/datum/record_database/security = new(list("name", "id"))
	var/datum/record_database/bank = new(list("name", "id"))
	var/list/datum/fine/fines = list()
	var/list/datum/ticket/tickets = list()
	var/obj/machinery/networked/mainframe/mainframe = null

/datum/datacore/proc/addManifest(mob/living/carbon/human/H as mob, sec_note = "", med_note = "", pda_net_id = null, synd_int_note = "")
	if (!H || !H.mind)
		return

	var/datum/db_record/G = new
	var/datum/db_record/M = new
	var/datum/db_record/S = new
	var/datum/db_record/B = new

	if (H.mind.assigned_role)
		G["rank"] = H.mind.assigned_role
	else
		G["rank"] = "Unassigned"

	G["name"] = H.real_name
	G["full_name"] = H.real_name
	if (H.client && H.client.preferences && length(H.client.preferences.name_middle))
		var/list/namecheck = splittext(H.real_name, " ")
		if (length(namecheck) >= 2)
			namecheck.Insert(2, H.client.preferences.name_middle)
			G["full_name"] = jointext(namecheck, " ")
	G["id"] = "[add_zero(num2hex(rand(1, 0xffffff), 0), 6)]"
	M["name"] = G["name"]
	M["id"] = G["id"]
	S["name"] = G["name"]
	S["id"] = G["id"]

	H.datacore_id = G["id"]

	B["name"] = G["name"]
	B["id"] = G["id"]

	if (H.gender == FEMALE)
		G["sex"] = "Female"
	else
		G["sex"] = "Male"

	G["pronouns"] = H.get_pronouns().name

	G["age"] ="[H.bioHolder.age]"
	G["fingerprint"] = "[H.bioHolder.fingerprints]"
	G["dna"] = H.bioHolder.Uid
	G["p_stat"] = "Active"
	G["m_stat"] = "Stable"
	SPAWN(2 SECONDS)
		if (H && G)
			var/icon/I = H.build_flat_icon(SOUTH)
			H.flat_icon = I
			if (istype(I))
				var/datum/computer/file/image/IMG = new()
				IMG.ourIcon = I
				IMG.img_name = "photo of [H.real_name]"
				IMG.img_desc = "You can see [H.real_name] in the photo."
				G["file_photo"] = IMG

	if(!length(synd_int_note))
		G["syndint"] = null
	else
		G["syndint"] = synd_int_note

	M["bioHolder.bloodType"] = "[H.bioHolder.bloodType]"
	M["mi_dis"] = "None"
	M["mi_dis_d"] = MEDREC_DISABILITY_MINOR_DEFAULT
	M["ma_dis"] = "None"
	M["ma_dis_d"] = MEDREC_DISABILITY_MAJOR_DEFAULT
	M["alg"] = "None"
	M["alg_d"] = MEDREC_ALLERGY_DEFAULT
	M["cdi"] = "None"
	M["cdi_d"] = MEDREC_DISEASE_DEFAULT
	M["cl_def"] = MEDREC_CLONE_DEFECT_DEFAULT
	M["cl_def_d"] = "None"
	M["h_imp"] = MEDREC_NO_IMPLANT

	if(!length(med_note))
		M["notes"] = "No notes."
	else
		M["notes"] = med_note

	M["dnasample"] = create_new_dna_sample_file(H)

	var/list/minorDisabilities = list()
	var/list/minorDisabilityDesc = list()
	var/list/majorDisabilities = list()
	var/list/majorDisabilityDesc = list()

	if(H.traitHolder)
		for(var/id in H.traitHolder.traits)
			var/datum/trait/T = H.traitHolder.traits[id]

			if (istype(T, /datum/trait/random_allergy))
				var/datum/trait/random_allergy/AT = T
				if (M["alg"] == "None") //is it in its default state?
					M["alg"] = reagent_id_to_name(AT.allergen)
					M["alg_d"] = "Allergy information imported from CentCom database."
				else
					M["alg"] += ", [reagent_id_to_name(AT.allergen)]"
				continue

			switch(T.disability_type)
				if (TRAIT_DISABILITY_MAJOR)
					majorDisabilities.Add(T.disability_name)
					majorDisabilityDesc.Add(T.disability_desc)
				if (TRAIT_DISABILITY_MINOR)
					minorDisabilities.Add(T.disability_name)
					minorDisabilityDesc.Add(T.disability_desc)

	if(length(minorDisabilities))
		M["mi_dis"] = jointext(minorDisabilities, ", ")
		M["mi_dis_d"] = jointext(minorDisabilityDesc, ". ")
	if(length(majorDisabilities))
		M["ma_dis"] = jointext(majorDisabilities, ", ")
		M["ma_dis_d"] = jointext(majorDisabilityDesc, ". ")

	if(!length(sec_note))
		S["notes"] = "No notes."
	else
		S["notes"] = sec_note

	if(H.traitHolder.hasTrait("jailbird"))
		S["criminal"] = ARREST_STATE_ARREST
		S["mi_crim"] = global.pick_crime(H)
		S["mi_crim_d"] = "No details provided."
		S["ma_crim"] = global.pick_crime(H, is_major = TRUE)
		S["ma_crim_d"] = "No details provided."
		H.update_arrest_icon()


		var/randomNote = pick("Huge nerd.", "Total jerkface.", "Absolute dingus.", "Insanely endearing.", "Worse than clown.", "Massive crapstain.");
		if(S["notes"] == "No notes.")
			S["notes"] = randomNote
		else
			S["notes"] += " [randomNote]"

		boutput(H, SPAN_NOTICE("You are currently on the run because you've committed the following crimes:"))
		boutput(H, SPAN_NOTICE("- [S["mi_crim"]]"))
		boutput(H, SPAN_NOTICE("- [S["ma_crim"]]"))

		H.mind.store_memory("You've committed the following crimes before arriving on the station:")
		H.mind.store_memory("- [S["mi_crim"]]")
		H.mind.store_memory("- [S["ma_crim"]]")
	else
		if (H.mind?.assigned_role == "Clown")
			S["criminal"] = ARREST_STATE_CLOWN
			S["mi_crim"] = "Clown"
			H.update_arrest_icon()
		else
			S["criminal"] = ARREST_STATE_NONE
			S["mi_crim"] = "None"

		S["mi_crim_d"] = "No minor crime convictions."
		S["ma_crim"] = "None"
		S["ma_crim_d"] = "No major crime convictions."

	S["sec_flag"] = "None"


	B["current_money"] = 100
	B["pda_net_id"] = pda_net_id
	B["notes"] = "No notes."

	// If it exists for a job give them the correct wage
	var/wageMult = 1
	if(H.traitHolder.hasTrait("unionized"))
		wageMult = 1.5

	var/datum/job/J
	if (H.job != null && istext(H.job))
		J = find_job_in_controller_by_string(H.job)
	else
		J = find_job_in_controller_by_string(H.mind.assigned_role)
	if (J?.wages)
		B["wage"] = round(J.wages * wageMult)
	else
		B["wage"] = 0

	src.general.add_record(G)
	src.medical.add_record(M)
	src.security.add_record(S)
	src.bank.add_record(B)
	wagesystem.payroll_stipend += B["wage"] * 1.1

	//Add email group
	if ("[H.mind.assigned_role]" in job_mailgroup_list)
		var/mailgroup = job_mailgroup_list["[H.mind.assigned_role]"]
		if (!mailgroup)
			return

		var/username = format_username(H.real_name)
		if (!src.mainframe || !src.mainframe.hd || !(src.mainframe.hd in src.mainframe))
			for (var/obj/machinery/networked/mainframe/newMainframe as anything in machine_registry[MACHINES_MAINFRAMES])
				if (newMainframe.z != 1 || newMainframe.status)
					continue

				if (newMainframe.hd)
					src.mainframe = newMainframe
					break

		if (src.mainframe && src.mainframe.hd && src.mainframe.hd.root) //ZeWaka: Fix for null.root
			for (var/datum/computer/folder/folder in src.mainframe.hd.root.contents)
				if (ckey(folder.name) == "etc")
					for (var/datum/computer/folder/folder2 in folder.contents)
						if (ckey(folder2.name) == "mail")
							for (var/datum/computer/file/record/groups in folder2.contents)
								if (ckey(groups.name) != "groups")
									continue

								if (!groups.fields)
									break

								for (var/mailgroupEntry in groups.fields)
									if (dd_hasprefix(mailgroupEntry, "[mailgroup]:"))
										groups.fields -= mailgroupEntry
										groups.fields += "[mailgroupEntry][username],"
										break

								groups.fields += "[mailgroup]:[username],"
								break

						break

					break

			return
		return

///Returns the crew manifest, but sorted according to the individual's rank. include_cryo includes a list of individuals in cryogenic storage
///Set `synd_int_request_device` to the object calling the proc to get Syndicate Intelligence.
/proc/get_manifest(include_cryo = TRUE, obj/synd_int_request_device = null)
	var/list/sorted_manifest
	var/list/Command = list()
	var/list/Security = list()
	var/list/Engineering = list()
	var/list/Medsci = list()
	var/list/Service = list()
	var/list/Unassigned = list()
	var/medsci_integer = 0 // Used to check if one of medsci's two heads has already been added to the manifest
	for(var/datum/db_record/staff_record as anything in data_core.general.records)
		if (staff_record["p_stat"] == "In Cryogenic Storage")
			continue
		var/rank = staff_record["rank"]
		if(synd_int_request_device && !length(staff_record["syndint"]))
			continue
		var/entry = "[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info</a>" : ""]<br>"
		if(rank in command_jobs)
			if(rank == "Captain")
				Command.Insert(1, entry)
				continue // Only Continue as Captain, as non-captain command staff appear both in the command section and their departmental section
			else
				Command.Add(entry)
				if(rank == "Communications Officer")
					continue

		if((rank in security_jobs) || (rank in security_gimmicks))
			if(rank in command_jobs)
				Security.Insert(1, "<b>[entry]</b>")
			else if(rank in command_gimmicks)
				Security.Insert(2, "<b>[entry]</b>")
			else
				Security.Add(entry)
			continue

		if((rank in engineering_jobs) || (rank in engineering_gimmicks))
			if(rank in command_jobs)
				Engineering.Insert(1, "<b>[entry]</b>")
			else if(rank in command_gimmicks)
				Engineering.Insert(2, "<b>[entry]</b>")
			else
				Engineering.Add(entry)
			continue
		if((rank in medsci_jobs) || (rank in medsci_gimmicks))
			if(rank in command_jobs)
				Medsci.Insert(1, "<b>[entry]</b>")
				medsci_integer++
			else if(rank in command_gimmicks)
				Medsci.Insert(medsci_integer + 1, "<b>[entry]</b>") // If there are two heads, both an MD and RD, medsci_integer will be at two, thus the Head Surgeon gets placed at 3 in the manifest
			else
				Medsci.Add(entry)
			continue

		if((rank in service_jobs) || (rank in service_gimmicks))
			if(rank in command_jobs)
				Service.Insert(1, "<b>[entry]</b>")
			else if(rank in command_gimmicks)
				Service.Insert(2, "<b>[entry]</b>") //Future proofing, just in case
			else
				Service.Add(entry)
			continue
#ifdef MAP_OVERRIDE_OSHAN // Radio host is on Oshan
		if(rank == "Radio Show Host" || rank == "Talk Show Host")
			Service.Add(entry)
#endif
			continue
		Unassigned += entry

	if(length(Command))
		sorted_manifest += "<b><u>Station Command:</u></b><br>"
		for(var/crew in Command)
			sorted_manifest += crew
	if(length(Security))
		sorted_manifest += "<b><u>Station Security:</u></b><br>"
		for(var/crew in Security)
			sorted_manifest += crew
	if(length(Engineering))
		sorted_manifest += "<b><u>Engineering and Supply:</u></b><br>"
		for(var/crew in Engineering)
			sorted_manifest += crew
	if(length(Medsci))
		sorted_manifest += "<b><u>Medical and Research:</u></b><br>"
		for(var/crew in Medsci)
			sorted_manifest += crew
	if(length(Service))
		sorted_manifest += "<b><u>Crew Service:</u></b><br>"
		for(var/crew in Service)
			sorted_manifest += crew
	if(length(Unassigned))
		sorted_manifest += "<b><u>Unassigned and Civilians:</u></b><br>"
		for(var/crew in Unassigned)
			sorted_manifest += crew

	if (include_cryo)
		var/stored = ""
		if(length(by_type[/obj/cryotron]))
			var/obj/cryotron/cryo_unit = pick(by_type[/obj/cryotron])
			for(var/L as anything in cryo_unit.stored_crew_names)
				stored += "<i>- [L]<i><br>"
		if(length(stored))
			sorted_manifest += "<br><b>In Cryogenic Storage:</b><hr>[stored]<br>"

	return sorted_manifest

/datum/ticket
	var/name = "ticket"
	var/target = null
	var/reason = null
	var/issuer = null
	var/issuer_job = null
	var/text = null
	var/target_byond_key = null
	var/issuer_byond_key = null

	New()
		..()
		SPAWN(1 SECOND)
			var/datum/eventRecord/Ticket/ticketEvent = new()
			ticketEvent.buildAndSend(src, usr)


/datum/fine
	var/ID = null
	var/name = "fine"
	var/target = null
	var/reason = null
	var/amount = 0
	var/issuer = null
	var/issuer_job = null
	var/approver = null
	var/approver_job = null
	var/paid_amount = 0
	var/paid = 0
	var/datum/db_record/bank_record = null
	var/target_byond_key = null
	var/issuer_byond_key = null
	var/approver_byond_key = null

	New()
		..()
		generate_ID()
		SPAWN(1 SECOND)
			bank_record = data_core.bank.find_record("name", target)
			if(!bank_record) qdel(src)
			var/datum/eventRecord/Fine/fineEvent = new()
			fineEvent.buildAndSend(src, usr)

/datum/fine/proc/approve(var/approved_by,var/their_job)
	if(approver || paid) return
	if (amount > MAX_FINE_NO_APPROVAL && !(JOBS_CAN_TICKET_BIG)) return
	if (!(their_job in JOBS_CAN_TICKET_SMALL)) return

	approver = approved_by
	approver_job = their_job
	approver_byond_key = get_byond_key(approver)
	logTheThing(LOG_ADMIN, usr, "approved a fine using [approver]([their_job])'s PDA. It is a [amount] credit fine on <b>[target]</b> with the reason: [reason].")

	if (bank_record["pda_net_id"])
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"=bank_record["pda_net_id"], "command"="text_message", "sender_name"="FINE-MAILBOT", "sender"="00000000", "message"="Notification: You have been fined [amount] credits by [issuer] for [reason].")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

	if(bank_record["current_money"] >= amount)
		bank_record["current_money"] -= amount
		wagesystem.station_budget += amount
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record["current_money"]
		wagesystem.station_budget += bank_record["current_money"]
		bank_record["current_money"] = 0
		SPAWN(30 SECONDS) process_payment()

/datum/fine/proc/process_payment()
	if(bank_record["current_money"] >= (amount-paid_amount))
		bank_record["current_money"] -= (amount-paid_amount)
		wagesystem.station_budget += (amount-paid_amount)
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record["current_money"]
		wagesystem.station_budget += bank_record["current_money"]
		bank_record["current_money"] = 0
		SPAWN(30 SECONDS) process_payment()

/datum/fine/proc/generate_ID()
	if(!ID) ID = (data_core.fines.len + 1)
