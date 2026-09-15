/datum/record_field
	var/name = null
	VAR_PROTECTED/value = null
	VAR_PROTECTED/default_value = null
	VAR_PROTECTED/permit_null_default = FALSE

/datum/record_field/New(name, value)
	. = ..()
	src.name = name
	src.value = value
	src.default_value = value

	if (!isnull(src.value) || !src.permit_null_default)
		var/error = src.validate(src.value)
		if (istext(error))
			CRASH(error)

/datum/record_field/proc/get_value()
	return src.value

/datum/record_field/proc/get_display_value()
	return src.value

/datum/record_field/proc/set_value(value)
	if (isnull(value))
		src.value = src.default_value
		return

	var/error = src.validate(value)
	if (istext(error))
		CRASH(error)
	else
		src.value = value

/datum/record_field/proc/validate(value)
	return

/datum/record_field/proc/input_load(datum/db_manager_menu/field_input/menu)
	return

/datum/record_field/proc/input_text(datum/db_manager_menu/field_input/menu, text)
	return
