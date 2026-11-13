/datum/record_field/choice/criminal

/datum/record_field/choice/criminal/New(parent, key, name, value, list/choices)
	value = SECURITY::ARREST::STATE::NONE
	choices = list(
		SECURITY::ARREST::STATE::ARREST,
		SECURITY::ARREST::STATE::DETAIN,
		SECURITY::ARREST::STATE::NONE,
		SECURITY::ARREST::STATE::SUSPECT,
		SECURITY::ARREST::STATE::INCARCERATED,
		SECURITY::ARREST::STATE::PAROLE,
		SECURITY::ARREST::STATE::RELEASED,
		SECURITY::ARREST::STATE::CLOWN,
	)
	. = ..(parent, key, name, value, choices)

/datum/record_field/choice/criminal/input_load(datum/db_manager_menu/field_input/menu)
	if (!length(global.data_core.get_open_arrests(id = src.parent["id"])))
		return ..()

	var/text = "Criminal status field cannot be altered while subject has open arrest warrants. Warrants may be accessed and closed from the citations list."
	text += "<br><b>Options:</b>"
	text += "<br>(1) Issue another arrest warrant."
	text += "<br>(2) View citations."
	text += "<br>(0) Back."
	menu.parent.print_text(text)

/datum/record_field/choice/criminal/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		return TRUE

	var/datum/db_record/personnel/general/record = global.data_core.get_general_record(id = src.parent["id"])
	if (!istype(record))
		CRASH("Attempted to edit field on headless record.")

	var/target_name = record["name"]
	if (length(global.data_core.get_open_arrests(target_name)))
		switch (index_number)
			if (1)
				menu.parent.switch_menu_to("issue_arrest", target_name)
			if (2)
				menu.parent.switch_menu_to("field_input", menu.record, "citations")

		return

	if (index_number > length(src.choices))
		menu.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	var/choice = src.choices[index_number]
	if (choice == SECURITY::ARREST::STATE::ARREST)
		menu.parent.switch_menu_to("issue_arrest", target_name)
		return

	src.set_value(choice)
	return TRUE
