/datum/datacore
	var/name = "datacore"
	var/obj/machinery/networked/mainframe/mainframe = null
	var/datum/record_database/general = null
	var/datum/record_database/medical = null
	var/datum/record_database/security = null
	var/datum/record_database/bank = null
	var/list/datum/fine/fines = null
	var/list/datum/ticket/tickets = null

/datum/datacore/New()
	. = ..()

	src.general = new(list("name", "id"))
	src.medical = new(list("name", "id"))
	src.security = new(list("name", "id"))
	src.bank = new(list("name", "id"))
	src.fines = list()
	src.tickets = list()

/datum/datacore/proc/addManifest(mob/living/carbon/human/H as mob, sec_note = "", med_note = "", pda_net_id = null, synd_int_note = "")
	if (!H?.mind)
		return

	H.datacore_id = src.generate_id()

	src.general.add_record(new /datum/db_record/personnel/general(H))
	src.medical.add_record(new /datum/db_record/personnel/medical(H))
	src.security.add_record(new /datum/db_record/personnel/security(H))
	src.bank.add_record(new /datum/db_record/personnel/bank(H))

	var/datum/job/J = global.find_job_in_controller_by_string(H.job || H.mind.assigned_role)
	if (!J?.email_group)
		return

	if (!src.mainframe?.hd || !(src.mainframe.hd in src.mainframe))
		for (var/obj/machinery/networked/mainframe/new_mainframe as anything in global.machine_registry[MACHINES_MAINFRAMES])
			if (!isonstationz(new_mainframe.z) || new_mainframe.status || !new_mainframe.hd)
				continue

			src.mainframe = new_mainframe
			break

	if (!src.mainframe?.os)
		return

	var/datum/computer/file/record/groups = src.mainframe.os.parse_directory("/etc/mail/groups")
	if (!groups?.fields)
		return

	var/username = global.format_username(H.real_name)
	for (var/i in 1 to length(groups.fields))
		var/mailgroup = groups.fields[i]
		if (!dd_hasprefix(mailgroup, "[J.email_group]:"))
			continue

		groups.fields[i] += "[username],"
		return

	groups.fields += "[J.email_group]:[username],"

/datum/datacore/proc/generate_id()
	return global.add_zero(num2hex(rand(1, 0xffffff), 0), 6)

/datum/datacore/proc/forensic_search(search_input)
	var/list/datum/db_record/record_matches = null

	// First search for exact matches on name, DNA, or fingerprints.
	record_matches = src.forensic_search_subjects(search_input)
	if (length(record_matches) > 0)
		var/result = SPAN_SUCCESS("<li>Records matching \"[search_input]\"</li>")

		var/match_num = ""
		if (length(record_matches) > 1)
			match_num = " (1/[length(record_matches)])"

		var/match_count = 1
		for (var/datum/db_record/R as anything in record_matches)
			result += "<li>[SPAN_NOTICE("Match[match_num]:<b> [R["name"]]</b>")]" + " ([R["rank"]])</li>"

			var/fprint_r = R["fingerprint_right"]
			var/fprint_l = R["fingerprint_left"]
			if (fprint_r == fprint_l)
				result += "<li style='margin-left:15px;list-style-type:none'><i>Fingerprints:</i> [fprint_r]</li>"
			else
				result += "<li style='margin-left:15px;list-style-type:none'><i>Fingerprint (R):</i> [fprint_r]</li>"
				result += "<li style='margin-left:15px;list-style-type:none'><i>Fingerprint (L):</i> [fprint_l]</li>"

			result += "<li style='margin-left:15px;list-style-type:none'><i>Blood DNA:</i> [R["dna"]]</li>"
			match_num = " ([++match_count]/[length(record_matches)])"

		return result

	// Search for partial matches on fingerprints.
	record_matches = src.forensic_search_fingerprint_partial(search_input)
	if (length(record_matches) > 0)
		var/result = SPAN_SUCCESS("<li>Potential matches for \"[search_input]\"</li>")

		for (var/datum/db_record/R as anything in record_matches)
			result += SPAN_NOTICE("<li style='margin-left:15px;list-style-type:none'>["<b>[R["name"]]</b>"]")

			var/fprint_r = R["fingerprint_right"]
			var/fprint_l = R["fingerprint_left"]
			if (fprint_r == fprint_l)
				result += ": [fprint_r]</li>"
			else
				result += ": [fprint_r]  |  [fprint_l]</li>"

		return result

	return SPAN_ALERT("No match found in security records for \"[search_input]\".")

/datum/datacore/proc/forensic_search_subjects(search_input)
	RETURN_TYPE(/list/datum/db_record)
	return src.general.adv_find_records(list("name", "dna", "fingerprint_left", "fingerprint_right"), regex(REGEX_QUOTE(search_input), "i"))

/datum/datacore/proc/forensic_search_fingerprint_partial(search_input)
	RETURN_TYPE(/list/datum/db_record)
	. = list()

	var/static/regex/invalid_character_regex = regex(@"[^a-z0-9\?\.\-]", "gi")
	var/static/regex/anything_regex = regex(@"(^\?(?=-))|((?<=-)\?(?=-))|((?<=-)\?$)|(^\?$)|(\.+)", "g")

	search_input = replacetext(search_input, invalid_character_regex, "")
	search_input = replacetext(search_input, anything_regex, ".*")
	search_input = replacetext(search_input, "?", ".")
	search_input = replacetext(search_input, "-", @"\-")
	if (!search_input)
		return

	return src.general.adv_find_records(list("fingerprint_left", "fingerprint_right"), regex(search_input))





/// Returns the crew manifest, but sorted according to the individual's rank.
/// `include_cryo` includes a list of individuals in cryogenic storage.
/// Set `synd_int_request_device` to the object calling the proc to get Syndicate Intelligence.
/proc/get_manifest(include_cryo = TRUE, obj/synd_int_request_device = null)
	var/list/section_command = list()
	var/list/section_security = list()
	var/list/section_engineering = list()
	var/list/section_research = list()
	var/list/section_medical = list()
	var/list/section_service = list()
	var/list/section_unassigned = list()
	var/list/section_cryo = list()

	for (var/datum/db_record/record as anything in global.data_core.general.records)
		if (record["p_stat"] == "In Cryogenic Storage")
			section_cryo += "<i>- [record["name"]]</i><br>"
			continue

		if (synd_int_request_device && !length(record["syndint"]))
			continue

		var/insert_index = 0
		var/rank = record["rank"]
		var/entry = "[record["name"]] - [rank][synd_int_request_device ? " - <a href='byond://?src=\ref[synd_int_request_device];select_exp=\ref[record]'>Info</a>" : ""]<br>"

		if (rank in global.command_jobs)
			if (rank == "Captain")
				section_command.Insert(1, entry)
				continue // The Captain only appears in the command section.

			section_command.Add(entry)
			insert_index = 1
			entry = "<b>[entry]</b>"

		else if (rank in global.command_gimmicks)
			insert_index = 2
			entry = "<b>[entry]</b>"

		// Insert the entry into the appropriate manifest section.
		if ((rank in global.security_jobs) || (rank in global.security_gimmicks))
			section_security.Insert(insert_index, entry)

		else if ((rank in global.engineering_jobs) || (rank in global.engineering_gimmicks))
			section_engineering.Insert(insert_index, entry)

		else if ((rank in global.science_jobs) || (rank in global.science_gimmicks))
			section_research.Insert(insert_index, entry)

		else if ((rank in global.medical_jobs) || (rank in global.medical_gimmicks))
			section_medical.Insert(insert_index, entry)

		else if ((rank in global.service_jobs) || (rank in global.service_gimmicks))
			section_service.Insert(insert_index, entry)

#ifdef MAP_OVERRIDE_OSHAN // Radio host on Oshan.
		else if ((rank == "Radio Show Host") || (rank == "Talk Show Host"))
			section_service.Add(entry)
#endif

		else
			section_unassigned += entry

	// Assemble the manifest.
	. = ""
	if (length(section_command))
		. += "<b><u>Station Command:</u></b><br>"
		. += section_command.Join()
	if (length(section_security))
		. += "<b><u>Station Security:</u></b><br>"
		. += section_security.Join()
	if (length(section_engineering))
		. += "<b><u>Engineering and Supply:</u></b><br>"
		. += section_engineering.Join()
	if (length(section_research))
		. += "<b><u>Research:</u></b><br>"
		. += section_research.Join()
	if (length(section_medical))
		. += "<b><u>Medical:</u></b><br>"
		. += section_medical.Join()
	if (length(section_service))
		. += "<b><u>Crew Service:</u></b><br>"
		. += section_service.Join()
	if (length(section_unassigned))
		. += "<b><u>Unassigned and Civilians:</u></b><br>"
		. += section_unassigned.Join()
	if (include_cryo && length(section_cryo))
		. += "<br><b>In Cryogenic Storage:</b><hr>"
		. += section_cryo.Join()





/datum/ticket
	var/name = "ticket"
	var/target = null
	var/reason = null
	var/issuer = null
	var/issuer_job = null
	var/text = null
	var/target_byond_key = null
	var/issuer_byond_key = null

/datum/ticket/New()
	. = ..()
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

/datum/fine/New()
	. = ..()
	src.generate_ID()
	SPAWN(1 SECOND)
		src.bank_record = global.data_core.bank.find_record("name", src.target)
		if (!src.bank_record)
			qdel(src)

		var/datum/eventRecord/Fine/fineEvent = new()
		fineEvent.buildAndSend(src, usr)

/datum/fine/proc/approve(approved_by, their_job, ticket_level)
	if (src.approver || src.paid)
		return

	if ((src.amount > SECURITY::TICKET::MAX_FINE_NO_APPROVAL) && (ticket_level < SECURITY::TICKET::LEVEL::FINE_LARGE))
		return

	if (ticket_level < SECURITY::TICKET::LEVEL::FINE_SMALL)
		return

	src.approver = approved_by
	src.approver_job = their_job
	src.approver_byond_key = global.get_byond_key(src.approver)
	logTheThing(LOG_ADMIN, usr, "approved a fine using [src.approver]([their_job])'s PDA. It is a [src.amount] credit fine on <b>[src.target]</b> with the reason: [src.reason].")

	if (src.bank_record["pda_net_id"])
		var/datum/signal/signal = global.get_free_signal()
		signal.data["address_1"] = src.bank_record["pda_net_id"]
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "FINE-MAILBOT"
		signal.data["sender"] = "00000000"
		signal.data["message"] = "Notification: You have been fined [src.amount] credits by [src.issuer] for [src.reason]."
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	src.process_payment()

/datum/fine/proc/process_payment()
	var/to_pay = src.amount - src.paid_amount
	if (src.bank_record["current_money"] >= to_pay)
		src.bank_record["current_money"] -= to_pay
		global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += to_pay
		src.paid = TRUE
		src.paid_amount = src.amount

	else
		src.paid_amount += src.bank_record["current_money"]
		global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += src.bank_record["current_money"]
		src.bank_record["current_money"] = 0

		SPAWN(30 SECONDS)
			src.process_payment()

/datum/fine/proc/generate_ID()
	src.ID ||= (length(global.data_core.fines) + 1)
