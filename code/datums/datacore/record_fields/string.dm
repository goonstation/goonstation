/datum/record_field/string
	permit_null_default = TRUE
	VAR_PROTECTED/regex_string = null
	VAR_PROTECTED/regex/validation_regex = null

/datum/record_field/string/New(name, value, regex_string)
	src.regex_string = regex_string
	if (src.regex_string)
		src.validation_regex = regex("^" + src.regex_string + "$")

	. = ..()

/datum/record_field/string/validate(value)
	if (!istext(value))
		return "Value \[[value]\] is not a string."

	if (src.validation_regex && !findtext(value, src.validation_regex))
		return "Value \[[value]\] does not match validation regex /[src.regex_string]/."

/datum/record_field/string/input_load(datum/db_manager_menu/field_input/menu)
	menu.parent.print_text("Please enter a new value:")

/datum/record_field/string/input_text(datum/db_manager_menu/field_input/menu, text)
	var/error = src.validate(text)
	if (istext(error))
		menu.parent.print_text("<b>Error:</b> [error]")
		return

	src.set_value(text)
	return TRUE
