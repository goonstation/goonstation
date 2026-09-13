//A packet sniffer!!

/obj/item/device/net_sniffer
	name = "Packet Sniffer"
	desc = "An electronic device designed to intercept network transmissions."
	icon_state = "sniffer0"
	item_state = "electronics"
	w_class = W_CLASS_BULKY
	rand_pos = 0
	var/mode = 0
	var/obj/machinery/power/data_terminal/link = null
	var/filter_id = null
	var/list/sniffFilters = list()
	var/last_intercept = 0
	var/list/packet_logs = list()
	var/captured_packets = 0
	var/max_logs = 8

	New()
		..()
		if (global.current_state < GAME_STATE_PLAYING)
			new /obj/item/paper/packets(src.loc)

	attack_ai(mob/user as mob)
		if(mode)
			src.ui_interact(user)
		return

	attack_hand(mob/user)
		if(mode)
			src.ui_interact(user)
			return

		else
			..()

	attackby(var/obj/item/I, var/mob/user)
		if (isscrewingtool(I))
			if (!mode)
				var/turf/T = loc
				if(isturf(T) && !T.intact)
					var/obj/machinery/power/data_terminal/test_link = locate() in T
					if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
						src.link = test_link
						src.link.master = src

						anchored = ANCHORED
						mode = 1
						user.visible_message("[user] attaches the [src] to the data terminal.","You attach the [src] to the data terminal.")

						icon_state = "sniffer1"

					else

						boutput(user, SPAN_ALERT("The [src] couldn't be attached here!"))
						return

				else
					boutput(user, "Device must be placed over a free data terminal to attach to it.")
					return
			else
				anchored = UNANCHORED
				mode = 0
				user.visible_message("[user] detaches the [src] from the data terminal.","You detach the [src] from the data terminal.")
				icon_state = "sniffer0"
				src.link?.master = null
				src.link = null
				return
		else
			..()

	attack_self(mob/user as mob)
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "PacketSniffer")
			ui.open()

	ui_data(mob/user)
		. = list(
			"connected" = !!(src.mode && src.link),
			"packet_logs" = src.packet_logs,
			"captured_packets" = src.captured_packets,
			"max_logs" = src.max_logs,
			"filter" = src.filter_id,
		)

	ui_act(action, params, datum/tgui/ui)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("set_filter")
				src.set_filter(ui.user)
			if ("set_filter_direct")
				var/filter_id = params["filter"]
				if (istext(filter_id) && length(filter_id) == 8 && \
					is_hex(filter_id))
					src.filter_id = filter_id
			if ("clear_filter")
				src.filter_id = null
			if ("clear_logs")
				src.packet_logs = list()

	proc/set_filter(mob/user)
		var/filt_id = tgui_input_text(user, "Please enter new 8 digit hex value filter net id", \
			src.name, src.filter_id, 8)
		if (isnull(filt_id))
			return
		if (length(filt_id) != 8 || !is_hex(filt_id))
			src.filter_id = null
			return

		src.filter_id = filt_id

	receive_signal(datum/signal/signal)
		if(!mode || !src.link)
			return
		if(!signal || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]
		if(src.filter_id && src.filter_id != target)
			return

		var/badcheck = 0
		for(var/check in src.sniffFilters)
			if(!(check in signal.data) || signal.data[check] != src.sniffFilters[check])
				badcheck = 1
				break
		if(badcheck)
			return

		if(!src.last_intercept || src.last_intercept + 40 <= world.time)
			playsound(src.loc, 'sound/machines/twobeep.ogg', 25, 1)

		var/list/packet_fields = list()
		var/payload_length = 0
		for (var/i in signal.data)
			var/field_key = "[i]"
			var/field_value = isnull(signal.data[i]) ? null : \
				"[signal.data[i]]"
			packet_fields += list(list(
				"key" = field_key,
				"value" = field_value,
			))
			payload_length += length(field_key) + length(field_value)

		var/device_tag = signal.data["device"]
		if (!device_tag && istype(signal.source, /obj/machinery/networked))
			var/obj/machinery/networked/network_device = signal.source
			device_tag = network_device.device_tag
		else if (!device_tag && istype(signal.source, /obj/item/peripheral/network/powernet_card))
			device_tag = "PNET_ADAPTER"
		else if (!device_tag && istype(signal.source, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/manufacturer = signal.source
			device_tag = manufacturer.device_tag
		else if (!device_tag && istype(signal.source, /obj/machinery/communications_dish))
			device_tag = "PNET_COM_ARRAY"

		src.captured_packets++
		var/list/packet_record = list(
			"sequence" = src.captured_packets,
			"stamp" = "\[[time2text(world.timeofday,"mm:ss")]:[(world.timeofday%10)]\]",
			"device" = device_tag ? "[device_tag]" : null,
			"fields" = packet_fields,
			"payload_length" = payload_length,
		)

		if (signal.data_file)
			var/file_text = signal.data_file.asText()
			packet_record["file"] = list(
				"name" = "[signal.data_file.name]",
				"extension" = "[signal.data_file.extension]",
				"content" = isnull(file_text) ? null : "[file_text]",
				"size" = signal.data_file.size,
			)

		src.packet_logs += list(packet_record)
		if (length(src.packet_logs) > src.max_logs)
			src.packet_logs.Cut(1, 2)
		src.last_intercept = world.time
		return
