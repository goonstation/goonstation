/datum/record_field/object
	permit_null_default = TRUE
	VAR_PROTECTED/object_type = null

/datum/record_field/object/New(name, value, object_type)
	if (ispath(object_type))
		src.object_type = object_type

	. = ..()

/datum/record_field/object/get_display_value()
	return isnull(src.value) ? "None" : "On File"

/datum/record_field/object/validate(value)
	if (!istype(value, object_type))
		return "Value \[[value]\] is not an instance of type \[[src.object_type]\]."


/datum/record_field/object/photo
	object_type = /datum/computer/file/image

/datum/record_field/object/photo/input_load(datum/db_manager_menu/field_input/menu)
	menu.parent.print_text("<b>Commands:</b><br>(1) View<br>(2) Print<br>(3) Delete<br>(0) Back")

/datum/record_field/object/photo/input_text(datum/db_manager_menu/field_input/menu, text)
	var/command = global.text2num_safe(menu.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))

	switch (index_number)
		if (0)
			return TRUE

		if (1)
			var/datum/computer/file/image/IMG = src.value
			if (!istype(IMG) || !IMG.ourIcon)
				menu.parent.print_text("Photo data is corrupt!")
				return

			menu.parent.print_text(replacetext(IMG.asText(), "|n", "<br>"))

		if (2)
			var/datum/computer/file/image/IMG = src.value
			if (!istype(IMG) || !IMG.ourIcon)
				menu.parent.print_text("Photo data is corrupt!")
				return

			if (menu.parent.network_print_photo(IMG))
				menu.parent.print_text("<b>Error:</b> No printer detected.")
			else
				menu.parent.print_text("Print instruction sent.")

		if (3)
			src.set_value(null)
			return TRUE
