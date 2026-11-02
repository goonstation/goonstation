/datum/record_field/string/sec_flag

/datum/record_field/string/sec_flag/New(parent, name, value, regex_string)
	value = "None"
	. = ..(parent, name, value, regex_string)

/datum/record_field/string/sec_flag/input_text(datum/db_manager_menu/field_input/menu, text)
	if (length(global.data_core.get_open_arrests(src.parent["name"])))
		if (trimtext(strip_html(text)) == "0")
			return TRUE

		menu.parent.print_text("<b>Error:</b> Cannot alter SecHUD flag while subject has open arrest warrants.")
		return

	. = ..()
