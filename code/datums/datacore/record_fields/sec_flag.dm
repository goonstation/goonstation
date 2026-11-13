/datum/record_field/string/sec_flag

/datum/record_field/string/sec_flag/New(parent, key, name, value, regex_string)
	value = "None"
	. = ..(parent, key, name, value, regex_string)

/datum/record_field/string/sec_flag/input_load(datum/db_manager_menu/field_input/menu)
	if (!length(global.data_core.get_open_arrests(id = src.parent["id"])))
		return ..()

	var/text = "SecHUD Flag field cannot be altered while subject has open arrest warrants. Warrants may be accessed and closed from the citations list."
	text += "<br><b>Options:</b>"
	text += "<br>(1) Issue another arrest warrant."
	text += "<br>(2) View citations."
	text += "<br>(0) Back."
	menu.parent.print_text(text)

/datum/record_field/string/sec_flag/input_text(datum/db_manager_menu/field_input/menu, text)
	var/datum/db_record/personnel/general/record = global.data_core.get_general_record(id = src.parent["id"])
	if (!istype(record))
		CRASH("Attempted to edit field on headless record.")

	var/target_name = record["name"]
	if (!length(global.data_core.get_open_arrests(target_name)))
		return ..()

	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))

	switch (index_number)
		if (0)
			return TRUE
		if (1)
			menu.parent.switch_menu_to("issue_arrest", target_name)
		if (2)
			menu.parent.switch_menu_to("field_input", menu.record, "citations")
