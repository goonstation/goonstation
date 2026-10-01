/datum/db_manager_menu/issue_ticket
	VAR_PRIVATE/target = null

/datum/db_manager_menu/issue_ticket/load(target)
	src.target = target

	var/text = ""

	text += "<b>Issuing Ticket To:</b> "
	if (src.target)
		text += src.target

	text += "<br><b>General Record:</b>    "
	if (src.target)
		text += global.data_core.general.find_record("name", src.target) ? "On Record" : "NONE"

	if (!src.target)
		text += "<br><br>Input ticket recipient. Enter '0' to return."

	else
		text += "<br><br>Input reason. Enter '0' to re-select recipient."

	src.parent.print_text(text)

/datum/db_manager_menu/issue_ticket/unload()
	src.target = null

/datum/db_manager_menu/issue_ticket/input_text(text)
	if (!src.target)
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("manage_citations")
			return

		src.parent.switch_menu_to("issue_ticket", text)

	else
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("issue_ticket")
			return

		var/datum/db_record/citation/ticket/ticket = new(
			authority = "Nanotrasen Corporate Security",
			target = src.target,
			issuer = src.parent.authenticated,
			issuer_job = src.parent.account.assignment,
			reason = text,
		)
		global.data_core.tickets.add_record(ticket)

		src.parent.switch_menu_to("record_view", ticket)
