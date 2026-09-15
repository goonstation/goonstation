ABSTRACT_TYPE(/datum/computer/file/terminal_program/db_manager)
/datum/computer/file/terminal_program/db_manager
	name = "DBMan"
	size = 12

	var/tmp/connected = FALSE
	var/tmp/server_netid = null
	var/tmp/potential_server_netid = null
	var/tmp/list/known_printers = null
	var/tmp/selected_printer = null

	VAR_PRIVATE/tmp/alist/menus = null
	VAR_PRIVATE/tmp/datum/db_manager_menu/current_menu = null
	VAR_PRIVATE/tmp/list/menu_journey_map = null
	var/tmp/datum/db_record_group/current_record_group = null

/datum/computer/file/terminal_program/db_manager/New()
	. = ..()
	src.menus = src.get_menus()

/datum/computer/file/terminal_program/db_manager/disposing()
	src.current_menu?.unload()
	src.current_menu = null
	src.menu_journey_map = null

	for (var/datum/db_manager_menu/menu as anything in src.menus)
		qdel(menu)

	src.menus = null
	. = ..()

/datum/computer/file/terminal_program/db_manager/initialize()
	if (..())
		return TRUE

	src.menu_journey_map = list()
	src.switch_menu_to("main")

/datum/computer/file/terminal_program/db_manager/input_text(text)
	if (..() || !src.current_menu?.accept_commands)
		return

	src.current_menu.input_text(text)

/datum/computer/file/terminal_program/db_manager/receive_command(obj/source, command, datum/signal/signal)
	if ((..()) || !signal)
		return

	if (!src.connected)
		if (!src.potential_server_netid \
			&& (signal.data["command"] == "ping_reply") \
			&& (signal.data["device"] == "PNET_MAINFRAME") \
			&& is_hex(signal.data["sender"]) \
		)
			src.potential_server_netid = signal.data["sender"]

		else if (signal.data["command"] == "term_connect")
			src.server_netid = ckey(signal.data["sender"])
			src.connected = TRUE
			src.potential_server_netid = null

			if (signal.data["data"] == "noreply")
				return

			var/datum/signal/reply = global.get_free_signal()
			reply.data["address_1"] = signal.data["sender"]
			reply.data["command"] = "term_connect"
			reply.data["device"] = "SRV_TERMINAL"
			reply.data["data"] = "noreply"

			src.peripheral_command("transmit", reply, ref(src.find_peripheral("NET_ADAPTER")))

		return

	if (signal.data["sender"] != src.server_netid)
		return

	if (!src.server_netid)
		src.connected = FALSE
		return

	switch (lowertext(signal.data["command"]))
		if ("term_message", "term_file")
			var/list/data = params2list(signal.data["data"])
			if (!data || !data["command"])
				return

			var/list/command_list = splittext(data["command"], "|n")
			var/list_length = length(command_list)
			if (!list_length || (command_list[1] != "print_index"))
				return

			if (list_length > 1)
				src.known_printers = command_list.Copy(2)
			else
				src.known_printers = null

		if ("term_disconnect")
			src.connected = FALSE
			src.server_netid = null
			src.print_text("Connection closed by printserver.")

		if ("term_ping")
			if (signal.data["data"] != "reply")
				return

			var/datum/signal/reply = get_free_signal()
			reply.data["address_1"] = signal.data["sender"]
			reply.data["command"] = "term_ping"

			src.peripheral_command("transmit", reply, ref(src.find_peripheral("NET_ADAPTER")))

/datum/computer/file/terminal_program/db_manager/proc/get_menus()
	RETURN_TYPE(/alist)
	return alist(
		"record_view"		= new /datum/db_manager_menu/record_view(src),
		"record_new"		= new /datum/db_manager_menu/record_new(src),
		"record_delete"		= new /datum/db_manager_menu/record_delete(src),
		"field_input"		= new /datum/db_manager_menu/field_input(src),
		"search_results"	= new /datum/db_manager_menu/search_results(src),
		"settings"			= new /datum/db_manager_menu/settings(src),
		"printer_list"		= new /datum/db_manager_menu/printer_list(src),
	)

/datum/computer/file/terminal_program/db_manager/proc/switch_menu_to(menu_id)
	SHOULD_NOT_OVERRIDE(TRUE)

	if (!src.menus[menu_id])
		CRASH("Invalid menu ID: [menu_id]")

	src.current_menu?.unload()
	src.master.temp = null

	var/i = src.menu_journey_map.Find(menu_id)
	if (i)
		src.menu_journey_map.Cut(i + 1)
	else
		src.menu_journey_map += menu_id

	var/list/arguments = args.Copy(2)
	src.current_menu = src.menus[menu_id]
	src.current_menu.accept_commands = TRUE
	src.current_menu.load(arglist(arguments))

/datum/computer/file/terminal_program/db_manager/proc/switch_to_previous_menu(steps = 1)
	var/journey_length = length(src.menu_journey_map)
	if (!journey_length)
		return

	var/i = max(1, journey_length - steps)
	src.switch_menu_to(src.menu_journey_map[i])

/datum/computer/file/terminal_program/db_manager/proc/connect_server(address)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (src.connected)
		return TRUE

	var/obj/item/peripheral/net_card = src.find_peripheral("NET_ADAPTER")
	if (!net_card)
		return TRUE

	var/datum/signal/signal = global.get_free_signal()
	signal.data["address_1"] = address
	signal.data["command"] = "term_connect"
	signal.data["device"] = "SRV_TERMINAL"

	var/datum/computer/file/user_data/user_data = src.account
	if (istype(user_data))
		var/userid = global.format_username(user_data.registered)
		var/access = list2params(user_data.access)
		if (!userid || !access)
			return TRUE

		var/datum/computer/file/record/udat = new()
		udat.fields["userid"] = userid
		udat.fields["access"] = access
		udat.fields["service"] = "print"
		signal.data_file = udat

	src.peripheral_command("transmit", signal, ref(net_card))
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/disconnect_server()
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!src.server_netid)
		return TRUE

	var/obj/item/peripheral/net_card = src.find_peripheral("NET_ADAPTER")
	if (!net_card)
		return TRUE

	var/datum/signal/signal = global.get_free_signal()
	signal.data["address_1"] = src.server_netid
	signal.data["command"] = "term_disconnect"

	src.peripheral_command("transmit", signal, ref(net_card))
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/ping_server()
	SHOULD_NOT_OVERRIDE(TRUE)
	if (src.connected)
		return TRUE

	var/obj/item/peripheral/net_card = src.find_peripheral("NET_ADAPTER")
	if (!net_card)
		return TRUE

	src.potential_server_netid = null
	src.peripheral_command("ping", null, ref(net_card))
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/message_server(message, datum/computer/file/to_send)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!src.connected || !src.server_netid || !message)
		return TRUE

	var/obj/item/peripheral/net_card = src.find_peripheral("NET_ADAPTER")
	if (!net_card)
		return TRUE

	var/datum/signal/signal = global.get_free_signal()
	signal.data["address_1"] = src.server_netid
	signal.data["data"] = message
	signal.data["command"] = "term_message"
	if (to_send)
		signal.data_file = to_send

	src.peripheral_command("transmit", signal, ref(net_card))
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/network_print(record_id)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!src.connected || !src.selected_printer || !src.server_netid)
		return TRUE

	var/datum/computer/file/record/print_record = new()
	print_record.fields += "title=Record"
	print_record.fields += src.current_record_group.get_record(record_id, src.current_record_group.get_all_databases(), TRUE)

	src.message_server("command=print&args=print [src.selected_printer]", print_record)
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/network_print_photo(datum/computer/file/image/IMG)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!src.connected || !src.selected_printer || !src.server_netid || !IMG)
		return TRUE

	var/datum/computer/file/record/print_record = new()
	print_record.fields += "title=File Photo"
	print_record.fields += "<font face='Consolas'>"
	print_record.fields += replacetext(IMG.asText(), "|n", "<br>")
	print_record.fields += "</font>"

	src.message_server("command=print&args=print [src.selected_printer]", print_record)
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/local_print(record_id)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/obj/item/peripheral/printer = src.find_peripheral("LAR_PRINTER")
	if (!printer)
		return TRUE

	var/datum/signal/signal = global.get_free_signal()
	signal.data["data"] = src.current_record_group.get_record(record_id, src.current_record_group.get_all_databases(), TRUE).Join()
	signal.data["title"] = "Record"
	src.peripheral_command("print", signal, ref(printer))
	return FALSE

/datum/computer/file/terminal_program/db_manager/proc/on_field_update(datum/db_record/record, key, old_value, new_value)
	return
