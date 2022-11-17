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
		if (namecheck.len >= 2)
			namecheck.Insert(2, H.client.preferences.name_middle)
			G["full_name"] = jointext(namecheck, " ")
	G["id"] = "[add_zero(num2hex(rand(1, 1.6777215E7), 0), 6)]"
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
		G["notes"] = null
	else
		G["notes"] = synd_int_note

	M["bioHolder.bloodType"] = "[H.bioHolder.bloodType]"
	M["mi_dis"] = "None"
	M["mi_dis_d"] = "No minor disabilities have been declared."
	M["ma_dis"] = "None"
	M["ma_dis_d"] = "No major disabilities have been diagnosed."
	M["alg"] = "None"
	M["alg_d"] = "No allergies have been detected in this patient."
	M["cdi"] = "None"
	M["cdi_d"] = "No diseases have been diagnosed at the moment."

	M["h_imp"] = "No health implant detected."

	if(!length(med_note))
		M["notes"] = "No notes."
	else
		M["notes"] = med_note

	M["dnasample"] = create_new_dna_sample_file(H)

	var/traitStr = ""
	if(H.traitHolder)
		for(var/id in H.traitHolder.traits)
			var/datum/trait/T = H.traitHolder.traits[id]
			if(length(traitStr)) traitStr += " | [T.name]"
			else traitStr = T.name
			if (istype(T, /datum/trait/random_allergy))
				var/datum/trait/random_allergy/AT = T
				if (M["alg"] == "None") //is it in its default state?
					M["alg"] = reagent_id_to_name(AT.allergen)
					M["alg_d"] = "Allergy information imported from CentCom database."
				else
					M["alg"] += ", [reagent_id_to_name(AT.allergen)]"

	M["traits"] = traitStr

	if(!length(sec_note))
		S["notes"] = "No notes."
	else
		S["notes"] = sec_note

	if(H.traitHolder.hasTrait("jailbird"))
		S["criminal"] = "*Arrest*"
		S["mi_crim"] = pick(\
								"Public urination.",\
								"Reading highly confidential private information.",\
								"Vandalism.",\
								"Illegal manufacturing of space goods.",\
								"Tresspassing.",\
								"Killing a monkey.",\
								"Negligence.",\
								"Pushing down and farting on a member of security.",\
								"Throwing a toolbox at a member of security.",\
								"Being drunk.",\
								"Being high.",\
								"Excessive force.",\
								"Impersonating a security officer.",\
								"Stealing shoes.",\
								"Littering.",\
								"Existing.",\
								"Illegal haircutting.",\
								"Staring at a bee for over an hour.",\
								"Not showering before entering pool.",\
								"Rampant idiocy.",\
								"Never tipping the catering staff.",\
								"Disregarding previous tickets.",\
								"Fashion crimes.",\
								"Gambling.",\
								"Bribery.",\
								"Sleeping on the job.",\
								"Unauthorized stamp collecting.",\
								"Refusing to wash their hands.",\
								"Maintenance lurking.",\
								"Dumpster diving.",\
								"Not covering their mouth when sneezing.",\
								"Open mouth chewing.",\
								"Riding pods without a license.",\
								"Breathing loudly.",\
								"Riding a segway directly into the captain.",\
								"Wearing their shirt backwards.",\
								"Excessive swearing",\
								"Cutting in line.",\
								"Tying the captain's shoelaces together.",\
								"Forgetting the captain's birthday.")
		S["mi_crim_d"] = "No details provided."
		S["ma_crim"] = pick(\
								"Grand theft apidae.",\
								"Bee murder.",\
								"Superfarted on the captain.",\
								"Released the singularity.",\
								"Stole the captain's spare ID.",\
								"Arson, murder, jaywalking.",\
								"Arson.",\
								"Murder.",\
								"Jaywalking.",\
								"Skating right through the bounds of real-space. Wicked sick, but highly illegal.",\
								"Being a really really bad surgeon.",\
								"Distributing meth.",\
								"Dismemberment and decapitation.",\
								"Running around with a chainsaw.",\
								"Throwing explosive tomatoes at people.",\
								"Caused multiple seemingly unrelated accidents.",\
								"Dabbing.",\
								"Assembling explosives.",\
								"Being in the wrong place at the wrong time.",\
								"Assault.",\
								"Tossing someone in space.",\
								"Over-escalation.",\
								"Manslaughter",\
								"Refusing to share their meth.",\
								"Grand larceny.")
		S["ma_crim_d"] = "No details provided."


		var/randomNote = pick("Huge nerd.", "Total jerkface.", "Absolute dingus.", "Insanely endearing.", "Worse than clown.", "Massive crapstain.");
		if(S["notes"] == "No notes.")
			S["notes"] = randomNote
		else
			S["notes"] += " [randomNote]"

		boutput(H, "<span class='notice'>You are currently on the run because you've committed the following crimes:</span>")
		boutput(H, "<span class='notice'>- [S["mi_crim"]]</span>")
		boutput(H, "<span class='notice'>- [S["ma_crim"]]</span>")

		H.mind.store_memory("You've committed the following crimes before arriving on the station:")
		H.mind.store_memory("- [S["mi_crim"]]")
		H.mind.store_memory("- [S["ma_crim"]]")
	else
		if (H.mind?.assigned_role == "Clown")
			S["criminal"] = "Clown"
			S["mi_crim"] = "Clown"
		else
			S["criminal"] = "None"
			S["mi_crim"] = "None"

		S["mi_crim_d"] = "No minor crime convictions."
		S["ma_crim"] = "None"
		S["ma_crim_d"] = "No major crime convictions."

	S["sec_flag"] = "None"


	B["job"] = H.job
	B["current_money"] = 100
	B["pda_net_id"] = pda_net_id
	B["notes"] = "No notes."

	// If it exists for a job give them the correct wage
	var/wageMult = 1
	if(H.traitHolder.hasTrait("unionized"))
		wageMult = 1.5

	if(wagesystem.jobs[H.job])
		B["wage"] = round(wagesystem.jobs[H.job] * wageMult)
	// Otherwise give them a default wage
	else
		var/datum/job/J = find_job_in_controller_by_string(G["rank"])
		if (J?.wages)
			B["wage"] = round(J.wages * wageMult)
		else
			B["wage"] = 0

	src.general.add_record(G)
	src.medical.add_record(M)
	src.security.add_record(S)
	src.bank.add_record(B)
	wagesystem.payroll_stipend += B["wage"]

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
		if(synd_int_request_device && !length(staff_record["notes"]))
			continue
		if(rank in command_jobs)
			if(rank == "Captain")
				Command.Insert(1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
				continue // Only Continue as Captain, as non-captain command staff appear both in the command section and their departmental section
			else
				Command.Add("[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
				if(rank == "Communications Officer")
					continue

		if((rank in security_jobs) || (rank in security_gimmicks))
			if(rank in command_jobs)
				Security.Insert(1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
			else if(rank in command_gimmicks)
				Security.Insert(2, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
			else
				Security.Add("[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
			continue

		if((rank in engineering_jobs) || (rank in engineering_gimmicks))
			if(rank in command_jobs)
				Engineering.Insert(1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
			else if(rank in command_gimmicks)
				Engineering.Insert(2, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
			else
				Engineering.Add("[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
			continue
		if((rank in medsci_jobs) || (rank in medsci_gimmicks))
			if(rank in command_jobs)
				Medsci.Insert(1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
				medsci_integer++
			else if(rank in command_gimmicks)
				Medsci.Insert(medsci_integer + 1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>") // If there are two heads, both an MD and RD, medsci_integer will be at two, thus the Head Surgeon gets placed at 3 in the manifest
			else
				Medsci.Add("[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
			continue

		if((rank in service_jobs) || (rank in service_gimmicks))
			if(rank in command_jobs)
				Service.Insert(1, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>")
			else if(rank in command_gimmicks)
				Service.Insert(2, "<b>[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]</b><br>") //Future proofing, just in case
			else
				Service.Add("[staff_record["name"]] - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
			continue
#ifdef MAP_OVERRIDE_OSHAN // Radio host is on Oshan
		if(rank == "Radio Show Host" || rank == "Talk Show Host")
			Service.Add("<b>[staff_record["name"]]</b> - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>")
#endif
			continue
		Unassigned += "<b>[staff_record["name"]]</b> - [staff_record["rank"]][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[staff_record]'>Info" : ""]<br>"

	sorted_manifest += "<b><u>Station Command:</u></b><br>"
	for(var/crew in Command)
		sorted_manifest += crew
	sorted_manifest += "<b><u>Station Security:</u></b><br>"
	for(var/crew in Security)
		sorted_manifest += crew
	sorted_manifest += "<b><u>Engineering and Supply:</u></b><br>"
	for(var/crew in Engineering)
		sorted_manifest += crew
	sorted_manifest += "<b><u>Medical and Research:</u></b><br>"
	for(var/crew in Medsci)
		sorted_manifest += crew
	sorted_manifest += "<b><u>Crew Service:</u></b><br>"
	for(var/crew in Service)
		sorted_manifest += crew
	sorted_manifest += "<b><u>Unassigned and Civilians:</u></b><br>"
	for(var/crew in Unassigned)
		sorted_manifest += crew

	if (include_cryo)
		var/stored = ""
		if(length(by_type[/obj/cryotron]))
			var/obj/cryotron/cryo_unit = pick(by_type[/obj/cryotron])
			for(var/L as anything in cryo_unit.stored_crew_names)
				stored += "<i>- [L]<i><br>"
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
			statlog_ticket(src, usr)

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
			statlog_fine(src, usr)

/datum/fine/proc/approve(var/approved_by,var/their_job)
	if(approver || paid) return
	if(!(their_job in list("Captain","Head of Security","Head of Personnel"))) return

	approver = approved_by
	approver_job = their_job
	approver_byond_key = get_byond_key(approver)

	if(bank_record["current_money"] >= amount)
		bank_record["current_money"] -= amount
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record["current_money"]
		bank_record["current_money"] = 0
		SPAWN(30 SECONDS) process_payment()

/datum/fine/proc/process_payment()
	if(bank_record["current_money"] >= (amount-paid_amount))
		bank_record["current_money"] -= (amount-paid_amount)
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record["current_money"]
		bank_record["current_money"] = 0
		SPAWN(30 SECONDS) process_payment()

/datum/fine/proc/generate_ID()
	if(!ID) ID = (data_core.fines.len + 1)
