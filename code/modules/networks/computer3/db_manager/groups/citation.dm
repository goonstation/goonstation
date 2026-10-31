/datum/db_record_group/citation
	main_menu = "manage_citations"
	record_list_prompt = "Please select a record:<br><br>%DUMMY_INDEX<b>Time      Type    Status   Recipient</b>"
	search_input_prompt = "Please enter ID, citation type, status, target name, or issuer name:"
	can_add_and_remove_records = FALSE
	field_data = list(
		"Ticket" = list(
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "time",			write = FALSE,	search = FALSE),
			alist(key = "authority",	write = FALSE,	search = FALSE),
			alist(key = "type",			write = FALSE,	search = TRUE),
			alist(key = "target",		write = FALSE,	search = TRUE),
			alist(key = "issuer",		write = FALSE,	search = TRUE),
			alist(key = "issuer_job",	write = FALSE,	search = FALSE),
			alist(key = "reason",		write = FALSE,	search = FALSE),
		),
		"Fine" = list(
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "time",			write = FALSE,	search = FALSE),
			alist(key = "authority",	write = FALSE,	search = FALSE),
			alist(key = "type",			write = FALSE,	search = TRUE),
			alist(key = "target",		write = FALSE,	search = TRUE),
			alist(key = "status",		write = FALSE,	search = TRUE),
			alist(key = "amount",		write = FALSE,	search = FALSE),
			alist(key = "paid_amount",	write = FALSE,	search = FALSE),
			alist(key = "issuer",		write = FALSE,	search = TRUE),
			alist(key = "issuer_job",	write = FALSE,	search = FALSE),
			alist(key = "approver",		write = FALSE,	search = FALSE),
			alist(key = "approver_job",	write = FALSE,	search = FALSE),
			alist(key = "reason",		write = FALSE,	search = FALSE),
		),
		"Arrest Warrant" = list(
			alist(key = "id",			write = FALSE,	search = TRUE),
			alist(key = "time",			write = FALSE,	search = FALSE),
			alist(key = "time_closed",	write = FALSE,	search = FALSE),
			alist(key = "authority",	write = FALSE,	search = FALSE),
			alist(key = "type",			write = FALSE,	search = TRUE),
			alist(key = "target",		write = FALSE,	search = TRUE),
			alist(key = "status",		write = FALSE,	search = TRUE),
			alist(key = "issuer",		write = FALSE,	search = TRUE),
			alist(key = "issuer_job",	write = FALSE,	search = FALSE),
			alist(key = "reason",		write = FALSE,	search = FALSE),
			alist(key = "closer",		write = FALSE,	search = FALSE),
			alist(key = "closer_job",	write = FALSE,	search = FALSE),
			alist(key = "resolution",	write = FALSE,	search = FALSE),
		),
	)
	var/mode = "ALL"

/datum/db_record_group/citation/get_records()
	switch (src.mode)
		if ("ALL")
			var/list/datum/db_record/citation/citations = list()
			citations += global.data_core.tickets.records
			citations += global.data_core.fines.records
			citations += global.data_core.arrests.records

			return global.sortList(citations, GLOBAL_PROC_REF(cmp_citations))

		if ("TICKETS")
			return global.data_core.tickets.records

		if ("FINES")
			return global.data_core.fines.records

		if ("ARRESTS")
			return global.data_core.arrests.records

/datum/db_record_group/citation/get_linked_records(datum/db_record/citation/citation)
	switch (citation.type)
		if (/datum/db_record/citation/ticket)
			return list("Ticket" = citation)
		if (/datum/db_record/citation/fine)
			return list("Fine" = citation)
		if (/datum/db_record/citation/arrest)
			return list("Arrest Warrant" = citation)

/datum/db_record_group/citation/get_main_database()
	CRASH("(/datum/db_record_group/citation) has no main database.")

/datum/db_record_group/citation/get_all_databases()
	return list(
		"Ticket" = global.data_core.tickets,
		"Fine" = global.data_core.fines,
		"Arrest Warrant" = global.data_core.arrests,
	)

/datum/db_record_group/citation/get_commands(datum/db_record/citation/citation)
	var/options = "<br>(R) Redraw<br>(P) Print Record<br>(Q) Print Citation"

	if (astype(citation, /datum/db_record/citation/arrest)?["status"] == "OPEN")
		options += "<br>(C) Close"
	else if (astype(citation, /datum/db_record/citation/fine)?["status"] == "PENDING")
		options += "<br>(A) Approve"

	options += "<br>(0) Return to index."
	return options

/datum/db_record_group/citation/input_command(datum/db_manager_menu/record_view/menu, datum/db_record/citation/citation, command)
	switch (command)
		if ("r")
			menu.parent.switch_menu_to("record_view", citation)

		if ("p")
			var/datum/computer/file/record/print_record = new()
			print_record.fields += "title=Citation [citation["id"]]"
			print_record.fields += src.get_record(citation, TRUE)

			if (menu.parent.print_file(print_record))
				menu.parent.print_text("Print instruction sent.")
			else
				menu.parent.print_text("<b>Error:</b> No printer detected.")

		if ("q")
			if (astype(citation, /datum/db_record/citation/fine)?["status"] == "PENDING")
				menu.parent.print_text("<b>Error:</b> Cannot print unapproved fines.")
				return TRUE

			var/obj/item/paper/paper = citation.build_citation()
			var/datum/computer/file/record/print_record = new()
			print_record.fields += "title=[paper.name]"
			print_record.fields += paper.info

			if (menu.parent.print_file(print_record))
				menu.parent.print_text("Print instruction sent.")
			else
				menu.parent.print_text("<b>Error:</b> No printer detected.")

		if ("a")
			var/datum/db_record/citation/fine/fine = citation
			if (!istype(fine) || (fine["status"] != "PENDING"))
				return

			switch (fine.attempt_approve(menu.parent.authenticated, menu.parent.account.assignment, menu.parent.account.access))
				if (SECURITY::TICKET::ERR::FINE_LARGE)
					menu.parent.print_text("<b>Error:</b> Insufficient access to approve large fines.")
				if (SECURITY::TICKET::ERR::FINE_SMALL)
					menu.parent.print_text("<b>Error:</b> Insufficient access to approve small fines.")
				if (SECURITY::TICKET::ERR::SUCCESS)
					menu.parent.switch_menu_to("record_view", fine)

		if ("c")
			var/datum/db_record/citation/arrest/arrest = citation
			if (!istype(arrest) || (arrest["status"] == "CLOSED"))
				return

			menu.parent.switch_menu_to("close_arrest", arrest)

		else
			return FALSE

	return TRUE

/datum/db_record_group/citation/record
	var/datum/db_record/personnel/security/record = null

/datum/db_record_group/citation/record/New(datum/db_record/personnel/security/record)
	. = ..()
	src.record = record

/datum/db_record_group/citation/record/get_records()
	var/name = src.record["name"]
	var/list/datum/db_record/citation/citations = list()
	citations += global.data_core.tickets.find_records("target", name)
	citations += global.data_core.fines.find_records("target", name)
	citations += global.data_core.arrests.find_records("target", name)

	return global.sortList(citations, GLOBAL_PROC_REF(cmp_citations))


/// Compare the issue date and time of two citations.
/proc/cmp_citations(datum/db_record/citation/a, datum/db_record/citation/b)
	return sorttext(b["time"], a["time"])
