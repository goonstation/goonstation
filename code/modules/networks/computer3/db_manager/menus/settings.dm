/datum/db_manager_menu/settings

/datum/db_manager_menu/settings/load()
	var/text = "<b>Options:</b>"
	if (src.parent.connected)
		text += "<br>(1) Disconnect from print server."
		text += "<br>(2) Select printer."
	else
		text += "<br>(1) Connect to print server."

	text += "<br>(0) Back."

	src.parent.print_text(text)

/datum/db_manager_menu/settings/input_text(text)
	var/command = global.text2num_safe(src.parent.parse_string(text)[1])
	var/index_number = round(max(command, 0))

	switch (index_number)
		if (0)
			src.parent.switch_menu_to("main")

		if (1)
			if (src.parent.connected)
				src.parent.disconnect_server()
			else
				src.connect_to_printserver()
				src.wait(2 SECONDS)

			src.parent.switch_menu_to("settings")

		if (2)
			if (!src.parent.connected)
				return

			src.parent.switch_menu_to("printer_list")

/datum/db_manager_menu/settings/proc/connect_to_printserver()
	if (src.parent.server_netid)
		src.parent.connect_server(src.parent.server_netid)

	else
		src.parent.print_text("Searching for printserver...")

		src.parent.ping_server()
		src.wait(0.8 SECONDS)
		if (isnull(src.parent.potential_server_netid))
			src.parent.print_text("Unable to detect printserver!")
			return

		src.parent.print_text("Printserver detected at \[[src.parent.potential_server_netid]\]<br>Connecting...")
		src.parent.connect_server(src.parent.potential_server_netid)

	src.wait(0.8 SECONDS)
	if (src.parent.connected)
		src.parent.print_text("Connection established to \[[src.parent.server_netid]\].")
	else
		src.parent.print_text("Connection failed.")
