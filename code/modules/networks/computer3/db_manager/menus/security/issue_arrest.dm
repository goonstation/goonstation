/datum/db_manager_menu/issue_citation/arrest
	VAR_PRIVATE/target = null

/datum/db_manager_menu/issue_citation/arrest/load(target)
	src.target = target

	var/text = ""

	text += "<b>Issuing Warrant For:</b> "
	if (src.target)
		text += src.target

	text += "<br><b>General Record:</b>      "
	if (src.target)
		text += global.data_core.general.find_record("name", src.target) ? "On Record" : "NONE"

	text += "<br><b>Security Record:</b>     "
	if (src.target)
		text += global.data_core.security.find_record("name", src.target) ? "On Record" : "NONE"

	if (!src.target)
		text += "<br><br>Input arrest warrant suspect. Enter '0' to return."

	else
		text += "<br><br>Input reason. Enter '0' to re-select suspect."

	src.parent.print_text(text)

/datum/db_manager_menu/issue_citation/arrest/unload()
	src.target = null

/datum/db_manager_menu/issue_citation/arrest/input_text(text)
	if (!src.target)
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("manage_citations")
			return

		var/datum/db_record/personnel/security/R = global.data_core.security.find_record("name", text)
		if (!istype(R))
			src.parent.print_text("<b>Error:</b> Could not locate security record for \"[text]\".")
			return

		src.parent.switch_menu_to("issue_arrest", text)

	else
		text = trimtext(strip_html(text))

		if (text == "0")
			src.parent.switch_menu_to("issue_arrest")
			return

		var/datum/db_record/citation/arrest/arrest = new(
			target = src.target,
			issuer = src.parent.authenticated,
			issuer_job = src.parent.account.assignment,
			reason = text,
		)
		global.data_core.arrests.add_record(arrest)

		src.parent.current_record_group = src.record_group
		src.parent.switch_menu_to("record_view", arrest)
