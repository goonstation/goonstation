/datum/db_manager_menu/issue_citation/close_arrest
	VAR_PRIVATE/datum/db_record/citation/arrest/arrest = null

/datum/db_manager_menu/issue_citation/close_arrest/load(datum/db_record/citation/arrest/arrest)
	src.arrest = arrest

	var/text = ""
	text += "<b>Arrest Warrant ID:</b> [arrest["id"]]"
	text += "<br><b>Warrant Suspect:</b>   [arrest["target"]]"
	text += "<br><br>Input resolution. Enter '0' to return."

	src.parent.print_text(text)

/datum/db_manager_menu/issue_citation/close_arrest/unload()
	src.arrest = null

/datum/db_manager_menu/issue_citation/close_arrest/input_text(text)
	text = trimtext(strip_html(text))

	if (text == "0")
		src.parent.current_record_group = src.record_group
		src.parent.switch_menu_to("record_view", src.arrest)
		return

	src.arrest.close(src.parent.authenticated, src.parent.account.assignment, text)
	src.parent.current_record_group = src.record_group
	src.parent.switch_menu_to("record_view", src.arrest)
