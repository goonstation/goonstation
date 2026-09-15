/datum/record_field/number/wage
	lower = 0
	upper = 10000

/datum/record_field/number/wage/get_display_value()
	return "[src.value]" + CREDIT_SIGN

/datum/record_field/number/wage/input_text(datum/db_manager_menu/field_input/menu, text)
	var/old_value = src.value
	. = ..()
	if (!.)
		return

	logTheThing(LOG_STATION, usr, "set wage for [menu.record["name"]] from [old_value][CREDIT_SIGN] to [src.value][CREDIT_SIGN].")
