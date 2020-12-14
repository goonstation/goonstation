/datum/datacore
	var/name = "datacore"
	var/list/medical = list(  )
	var/list/general = list(  )
	var/list/security = list(  )
	var/list/bank = list (  )
	var/list/fines = list (  )
	var/list/tickets = list (  )
	var/obj/machinery/networked/mainframe/mainframe = null

/datum/datacore/proc/addManifest(var/mob/living/carbon/human/H as mob, var/sec_note = "", var/med_note = "")
	if (!H || !H.mind)
		return

	var/datum/data/record/G = new /datum/data/record(  )
	var/datum/data/record/M = new /datum/data/record(  )
	var/datum/data/record/S = new /datum/data/record(  )
	var/datum/data/record/B = new /datum/data/record(  )

	if (H.mind.assigned_role)
		G.fields["rank"] = H.mind.assigned_role
	else
		G.fields["rank"] = "Unassigned"

	G.fields["name"] = H.real_name
	G.fields["full_name"] = H.real_name
	if (H.client && H.client.preferences && length(H.client.preferences.name_middle))
		var/list/namecheck = splittext(H.real_name, " ")
		if (namecheck.len >= 2)
			namecheck.Insert(2, H.client.preferences.name_middle)
			G.fields["full_name"] = jointext(namecheck, " ")
	G.fields["id"] = "[add_zero(num2hex(rand(1, 1.6777215E7), 0), 6)]"
	M.fields["name"] = G.fields["name"]
	M.fields["id"] = G.fields["id"]
	S.fields["name"] = G.fields["name"]
	S.fields["id"] = G.fields["id"]

	B.fields["name"] = G.fields["name"]
	B.fields["id"] = G.fields["id"]

	if (H.gender == FEMALE)
		G.fields["sex"] = "Female"
	else
		G.fields["sex"] = "Male"

	G.fields["age"] ="[H.bioHolder.age]"
	G.fields["fingerprint"] = "[H.bioHolder.uid_hash]"
	G.fields["dna"] = H.bioHolder.Uid
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	SPAWN_DBG(2 SECONDS)
		if (H && G)
			var/icon/I = H.build_flat_icon(SOUTH)
			H.flat_icon = I
			if (istype(I))
				var/datum/computer/file/image/IMG = new()
				IMG.ourIcon = I
				IMG.img_name = "photo of [H.real_name]"
				IMG.img_desc = "You can see [H.real_name] in the photo."
				G.fields["file_photo"] = IMG

	M.fields["bioHolder.bloodType"] = "[H.bioHolder.bloodType]"
	M.fields["mi_dis"] = "None"
	M.fields["mi_dis_d"] = "No minor disabilities have been declared."
	M.fields["ma_dis"] = "None"
	M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	M.fields["alg"] = "None"
	M.fields["alg_d"] = "No allergies have been detected in this patient."
	M.fields["cdi"] = "None"
	M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."

	M.fields["h_imp"] = "No health implant detected."

	if(!length(med_note))
		M.fields["notes"] = "No notes."
	else
		M.fields["notes"] = med_note

	M.fields["dnasample"] = create_new_dna_sample_file(H)

	var/traitStr = ""
	if(H.traitHolder)
		for(var/X in H.traitHolder.traits)
			var/obj/trait/T = getTraitById(X)
			if(length(traitStr)) traitStr += " | [T.cleanName]"
			else traitStr = T.cleanName
			if (istype(T, /obj/trait/random_allergy))
				var/obj/trait/random_allergy/AT = T
				if (M.fields["notes"] == "No notes.") //is it in its default state?
					M.fields["notes"] = "[G.fields["name"]] has an allergy to [AT.allergic_players[H]]."
				else
					M.fields["notes"] += " [G.fields["name"]] has an allergy to [AT.allergic_players[H]]."

	M.fields["traits"] = traitStr

	if(!length(sec_note))
		S.fields["notes"] = "No notes."
	else
		S.fields["notes"] = sec_note

	if(H.traitHolder.hasTrait("jailbird"))
		S.fields["criminal"] = "*Arrest*"
		S.fields["mi_crim"] = pick(\
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
								"Rampant idiocy.")
		S.fields["mi_crim_d"] = "No details provided."
		S.fields["ma_crim"] = pick(\
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
								"Caused multiple seemingly unrelated accidents.")
		S.fields["ma_crim_d"] = "No details provided."

		var/randomNote = pick("Huge nerd.", "Total jerkface.", "Absolute dingus.", "Insanely endearing.", "Worse than clown.", "Massive crapstain.");
		if(S.fields["notes"] == "No notes.")
			S.fields["notes"] = randomNote
		else
			S.fields["notes"] += " [randomNote]"

		boutput(H, "<span class='notice'>You are currently on the run because you've committed the following crimes:</span>")
		boutput(H, "<span class='notice'>- [S.fields["mi_crim"]]</span>")
		boutput(H, "<span class='notice'>- [S.fields["ma_crim"]]</span>")

		H.mind.store_memory("You've committed the following crimes before arriving on the station:")
		H.mind.store_memory("- [S.fields["mi_crim"]]")
		H.mind.store_memory("- [S.fields["ma_crim"]]")
	else
		S.fields["criminal"] = "None"
		S.fields["mi_crim"] = "None"
		S.fields["mi_crim_d"] = "No minor crime convictions."
		S.fields["ma_crim"] = "None"
		S.fields["ma_crim_d"] = "No major crime convictions."


	B.fields["job"] = H.job
	B.fields["current_money"] = 100.0
	B.fields["notes"] = "No notes."

	// If it exists for a job give them the correct wage
	var/wageMult = 1
	if(H.traitHolder.hasTrait("unionized"))
		wageMult = 1.5

	if(wagesystem.jobs[H.job])
		B.fields["wage"] = round(wagesystem.jobs[H.job] * wageMult)
	// Otherwise give them a default wage
	else
		var/datum/job/J = find_job_in_controller_by_string(G.fields["rank"])
		if (J?.wages)
			B.fields["wage"] = round(J.wages * wageMult)
		else
			B.fields["wage"] = 0

	src.general += G
	src.medical += M
	src.security += S
	src.bank += B

	//Add email group
	if ("[H.mind.assigned_role]" in job_mailgroup_list)
		var/mailgroup = job_mailgroup_list["[H.mind.assigned_role]"]
		if (!mailgroup)
			return

		var/username = format_username(H.real_name)
		if (!src.mainframe || !src.mainframe.hd || !(src.mainframe.hd in src.mainframe))
			for (var/obj/machinery/networked/mainframe/newMainframe as() in machine_registry[MACHINES_MAINFRAMES])
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
		SPAWN_DBG(1 SECOND)
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
	var/datum/data/record/bank_record = null
	var/target_byond_key = null
	var/issuer_byond_key = null
	var/approver_byond_key = null

	New()
		..()
		generate_ID()
		SPAWN_DBG(1 SECOND)
			for(var/datum/data/record/B in data_core.bank) //gross
				if(B.fields["name"] == target)
					bank_record = B
					break
			if(!bank_record) qdel(src)
			statlog_fine(src, usr)

/datum/fine/proc/approve(var/approved_by,var/their_job)
	if(approver || paid) return
	if(!(their_job in list("Captain","Head of Security","Head of Personnel"))) return

	approver = approved_by
	approver_job = their_job
	approver_byond_key = get_byond_key(approver)

	if(bank_record.fields["current_money"] >= amount)
		bank_record.fields["current_money"] -= amount
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record.fields["current_money"]
		bank_record.fields["current_money"] = 0
		SPAWN_DBG(30 SECONDS) process_payment()

/datum/fine/proc/process_payment()
	if(bank_record.fields["current_money"] >= (amount-paid_amount))
		bank_record.fields["current_money"] -= (amount-paid_amount)
		paid = 1
		paid_amount = amount
	else
		paid_amount += bank_record.fields["current_money"]
		bank_record.fields["current_money"] = 0
		SPAWN_DBG(30 SECONDS) process_payment()

/datum/fine/proc/generate_ID()
	if(!ID) ID = (data_core.fines.len + 1)
