/datum/db_manager_menu/field_input
	var/datum/db_record/record = null
	VAR_PRIVATE/key = null
	VAR_PRIVATE/datum/record_field/field = null

/datum/db_manager_menu/field_input/load(datum/db_record/record, key)
	src.key = key
	src.record = record
	src.field = src.record.get_field_datum(src.key)

	src.parent.print_text({"\
		<b>Editing [src.record.to_display_string()]</b><br>\
		<b>Field:</b>  [src.field.name]<br>\
		<b>Value:</b>  [src.field.get_display_value()]<br>\
	"})

	src.field.input_load(src)

/datum/db_manager_menu/field_input/unload()
	src.record = null
	src.field = null

/datum/db_manager_menu/field_input/input_text(text)
	var/old_value = src.field.get_value()

	if (src.field.input_text(src, text))
		var/new_value = src.field.get_value()
		if (old_value != new_value)
			src.parent.on_field_update(src.record, src.key, old_value, new_value)

		src.parent.switch_menu_to("record_view", src.record["id"])
