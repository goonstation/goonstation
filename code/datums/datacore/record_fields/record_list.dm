/datum/record_field/record_list
	permit_null_default = TRUE
	var/datum/db_record_group/record_group = null

/datum/record_field/record_list/get_value()
	return src.record_group.get_records()

/datum/record_field/record_list/get_display_value()
	var/entries = length(src.record_group.get_records())
	if (entries == 1)
		return "1 entry"
	else
		return "[entries] entries"

/datum/record_field/record_list/set_value(value)
	CRASH("Record list record fields are read-only!")

/datum/record_field/record_list/validate(value)
	return "Record list record fields are read-only!"

/datum/record_field/record_list/input_load(datum/db_manager_menu/field_input/menu)
	menu.parent.current_record_group = src.record_group
	menu.parent.switch_menu_to("record_list")

/datum/record_field/record_list/input_text(datum/db_manager_menu/field_input/menu, text)
	CRASH("Record list record fields are read-only!")
