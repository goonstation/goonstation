#define CITATION_SECTION_TICKETS "tickets"
#define CITATION_SECTION_FINES "fines"

/datum/citationRecords
	var/citation_record_data
	var/list/citation_data = list()

/datum/citationRecords/New()
	. = ..()

	src.citation_data = list(
		CITATION_SECTION_TICKETS = list(),
		CITATION_SECTION_FINES = list(),
	)
	src.generate_citation_data()

/datum/citationRecords/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/citationRecords/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/citationRecords/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CitationRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/citationRecords/ui_static_data(mob/user)
	return src.citation_record_data

/datum/citationRecords/proc/generate_citation_data()
	if(length(data_core.tickets))
		var/list/people_with_tickets = list()
		for (var/datum/ticket/T in data_core.tickets)
			people_with_tickets |= T.target

		for(var/ticket_target in people_with_tickets)
			var/list/tickets = list()
			for(var/datum/ticket/ticket in data_core.tickets)
				if(ticket.target == ticket_target)
					tickets += list(list(
						"reason" = ticket.reason,
						"issuer" = ticket.issuer,
						"issuer_job" = ticket.issuer_job
					))
			src.citation_data[CITATION_SECTION_TICKETS] += list(list(
				"target_name" = ticket_target,
				"target_tickets" = tickets,
			))

	if(length(data_core.fines))
		var/list/people_with_fines = list()
		for (var/datum/fine/F in data_core.fines)
			people_with_fines |= F.target

		for(var/fine_target in people_with_fines)
			var/list/fines = list()
			for(var/datum/fine/fine in data_core.fines)
				if(fine.target == fine_target)
					fines += list(list(
						"reason" = fine.reason,
						"issuer" = fine.issuer,
						"issuer_job" = fine.issuer_job,
						"approver" = fine.approver,
						"approver_job" = fine.approver_job,
						"paid" = fine.paid,
						"amount" = fine.amount,
					))
			src.citation_data[CITATION_SECTION_FINES] += list(list(
				"target_name" = fine_target,
				"target_fines" = fines,
			))

	src.citation_record_data = list(
		"tickets" = src.citation_data[CITATION_SECTION_TICKETS],
		"fines" = src.citation_data[CITATION_SECTION_FINES],
	)

#undef CITATION_SECTION_TICKETS
#undef CITATION_SECTION_FINES
