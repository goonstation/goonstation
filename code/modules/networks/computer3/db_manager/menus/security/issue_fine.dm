/datum/db_manager_menu/issue_fine
	VAR_PRIVATE/target = null
	VAR_PRIVATE/amount = null

/datum/db_manager_menu/issue_fine/load(target, amount)
	src.target = target
	src.amount = amount

	var/text = ""

	text += "<b>Issuing Fine To:</b> "
	if (src.target)
		text += src.target

	text += "<br><b>General Record:</b>  "
	if (src.target)
		text += global.data_core.general.find_record("name", src.target) ? "On Record" : "NONE"

	text += "<br><b>Bank Record:</b>     "
	if (src.target)
		text += global.data_core.bank.find_record("name", src.target) ? "On Record" : "NONE"

	text += "<br><b>Fine Amount:</b>     "
	if (src.amount)
		text += "[src.amount]" + CREDIT_SIGN

	if (!src.target)
		text += "<br><br>Input fine recipient. Enter '0' to return."

	else if (!src.amount)
		text += "<br><br>Input fine amount. Enter '0' to re-select recipient."

	else
		text += "<br><br>Input reason. Enter '0' to re-select amount."

	src.parent.print_text(text)

/datum/db_manager_menu/issue_fine/unload()
	src.target = null
	src.amount = null

/datum/db_manager_menu/issue_fine/input_text(text)
	if (!src.target)
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("manage_citations")
			return

		var/datum/db_record/personnel/bank/R = global.data_core.bank.find_record("name", text)
		if (!istype(R))
			src.parent.print_text("<b>Error:</b> Could not locate bank record for \"[text]\".")
			return

		src.parent.switch_menu_to("issue_fine", text)

	else if (!src.amount)
		var/command = global.text2num_safe(src.parent.parse_string(text)[1])
		var/amount = round(command)

		if (amount == 0)
			src.parent.switch_menu_to("issue_fine")
			return

		if (amount < 0)
			src.parent.print_text("<b>Error:</b> Cannot issue a negative fine.")
			return

		src.parent.switch_menu_to("issue_fine", src.target, amount)

	else
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("issue_fine", src.target)
			return

		var/datum/db_record/citation/fine/fine = new(
			target = src.target,
			amount = src.amount,
			issuer = src.parent.authenticated,
			issuer_job = src.parent.account.assignment,
			reason = text,
		)
		global.data_core.citation.add_record(fine)

		fine.attempt_approve(src.parent.authenticated, src.parent.account.assignment, src.parent.account.access)
		src.parent.switch_menu_to("record_view", fine)
