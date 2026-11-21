/datum/targetable/ai/program/issue_citation
	name = "Issue Citation"
	desc = "Issue a ticket, fine, or arrest warrant."
	icon_state = "citation"
	targeted = TRUE

	cast(atom/target)
		. = ..()
		if (.)
			return .

		if (!ismob(src.holder.owner))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/mob/M = src.holder.owner

		var/thing_to_issue = tgui_input_list(M, "Select citation type:", "Citation Type", list("Ticket", "Fine", "Warrant"))
		if (!thing_to_issue)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/reason = tgui_input_text(M, "Input reason for the [thing_to_issue]:", "Input Reason")
		if (!reason)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		var/target_name = target.name
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			target_name = H.face_visible() ? H.real_name : H.name

		var/issuer = "AIUSR"
		var/issuer_job = "Station AI"
		var/list/access = list()
		var/obj/item/card/id/ID = M.get_id()
		if (istype(ID))
			issuer = ID.registered
			issuer_job = ID.assignment
			access = ID.access

		if (!target_name || target_name == "")
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN

		switch(thing_to_issue)
			if ("Ticket")
				var/datum/db_record/citation/ticket/ticket = new(
					authority = "Nanotrasen Corporate Security",
					target = target_name,
					issuer = issuer,
					issuer_job = issuer_job,
					reason = reason,
				)
				global.data_core.tickets.add_record(ticket)

			if ("Fine")
				var/amount = tgui_input_number(src.holder.owner, "Input fine amount:", "Fine Amount")
				if (!amount)
					return CAST_ATTEMPT_FAIL_NO_COOLDOWN

				var/datum/db_record/citation/fine/fine = new(
					authority = "Nanotrasen Corporate Security",
					target = target_name,
					amount = amount,
					issuer = issuer,
					issuer_job = issuer_job,
					reason = reason,
				)
				global.data_core.fines.add_record(fine)
				fine.attempt_approve(issuer, issuer_job, access)

			if ("Warrant")
				var/datum/db_record/citation/arrest/arrest = new(
					target = target_name,
					issuer = issuer,
					issuer_job = issuer_job,
					reason = reason,
				)
				global.data_core.arrests.add_record(arrest)
