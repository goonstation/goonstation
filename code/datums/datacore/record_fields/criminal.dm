/datum/record_field/choice/criminal

/datum/record_field/choice/criminal/New(parent, name, value, list/choices)
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
	. = ..(parent, name, value, choices)

/datum/record_field/choice/criminal/set_value(value)
	. = ..()

	var/target_name = src.parent["name"]
	for_by_tcl(H, /mob/living/carbon/human)
		if ((H.real_name == target_name) || (H.name == target_name))
			H.update_arrest_icon()

/datum/record_field/choice/criminal/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		return TRUE

	var/target_name = src.parent["name"]
	if (length(global.data_core.get_open_arrests(target_name)))
		menu.parent.print_text("<b>Error:</b> Cannot alter criminal status while subject has open arrest warrants.")
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
