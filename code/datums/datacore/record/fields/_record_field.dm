/datum/record_field
	/// The display name of this field.
	var/name = null
	/// The current value of this field.
	VAR_PROTECTED/value = null
	/// The default value of this field.
	VAR_PROTECTED/default_value = null
	/// Whether the value of this field is permitted to be null.
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

/// Returns the raw value of this field.
/datum/record_field/proc/get_value()
	return src.value

/// Returns the display value of this field.
/datum/record_field/proc/get_display_value()
	return src.value

/// Sets the value of this field. Errors if the new value does not pass validation.
/datum/record_field/proc/set_value(value)
	if (isnull(value))
		src.value = src.default_value
		return

	var/error = src.validate(value)
	if (istext(error))
		CRASH(error)
	else
		src.value = value

/// Returns TRUE if the passed value may be used as a value for this field.
/datum/record_field/proc/validate(value)
	return

/// Called when a database manager opens an input prompt to assign a new value to this field.
/datum/record_field/proc/input_load(datum/db_manager_menu/field_input/menu)
	return

/// Called when a database manager has a text input when attempting to assign a new value to this field.
/datum/record_field/proc/input_text(datum/db_manager_menu/field_input/menu, text)
	return
