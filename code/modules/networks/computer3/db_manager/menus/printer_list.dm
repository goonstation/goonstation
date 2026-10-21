/datum/db_manager_menu/printer_list

/datum/db_manager_menu/printer_list/load()
	src.parent.print_text("Searching for printers...")
	src.parent.message_server("command=print&args=index")
	src.wait(0.8 SECONDS)

	var/text = "<br>"

	if (!length(src.parent.known_printers))
		text += "<b>Error:</b> No printers found."

	else
		text += "Please select a printer:"
		var/printer_count = length(src.parent.known_printers)
		var/leading_zero_count = length("[length(printer_count)]")
		for (var/i in 1 to printer_count)
			text += "<br><b>\[[global.add_zero(i, leading_zero_count)]\]</b>[src.parent.known_printers[i]]"

	text += "<br><br>Enter printer number, or 0 to return."
	src.parent.print_text(text)

/datum/db_manager_menu/printer_list/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))
	if (index_number == 0)
		src.parent.switch_menu_to("settings")
		return

	if (index_number > length(src.parent.known_printers))
		src.parent.print_text("<b>Error:</b> Invalid choice.")
		return

	src.parent.selected_printer = src.parent.known_printers[index_number]
	src.parent.print_text("Printer set.")
	src.wait(2 SECONDS)
	src.parent.switch_menu_to("settings")
