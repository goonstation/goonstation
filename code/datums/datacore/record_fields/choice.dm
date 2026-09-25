/datum/record_field/choice
	VAR_PROTECTED/list/choices = null
	VAR_PROTECTED/leading_zero_count = null

/datum/record_field/choice/New(name, value, list/choices)
	src.choices = list()
	for (var/choice as anything in choices)
		src.choices[choice] = TRUE

	src.leading_zero_count = length("[length(src.choices)]")
	. = ..()

/datum/record_field/choice/validate(value)
	if (!src.choices[value])
		return "Value \[[value]\] not present in choices."

/datum/record_field/choice/input_load(datum/db_manager_menu/field_input/menu)
	var/text = "Please select:"
	for (var/i in 1 to length(src.choices))
		text += "<br>    ([global.add_zero(i, src.leading_zero_count)]) [src.choices[i]]"

	text += "<br>    ([global.add_zero(0, src.leading_zero_count)]) Back"
	menu.parent.print_text(text)

/datum/record_field/choice/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		return TRUE

	if (index_number > length(src.choices))
		menu.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	src.set_value(src.choices[index_number])
	return TRUE
