//Singularity engine control program
/datum/computer/file/terminal_program/engine_control
	name = "EngineMaster"
	size = 10
	req_access = list(access_engineering_engine)
	var/log_string = null
	var/obj/item/peripheral/network/powernet_card/netcard = null
	var/obj/item/peripheral/network/radio/radiocard = null
	var/tmp/task = null //What are we doing at the moment?
	var/tmp/startup_line = 1
	var/tmp/starting_up = 0 //Are we currently starting up?
	var/list/emitter_ids = list() //Net ids of located emitters.
	var/list/fieldgen_ids = list() //Net ids of located field generators.
	var/tmp/last_event_report = 0 //When did we last report an event?

	var/setup_logdump_name = "englog"
	var/setup_mail_freq = FREQ_PDA //Which freq do we report to?
	var/setup_mailgroup = MGO_ENGINEER //The PDA mailgroup used when alerting engineer pdas.


	initialize()
		if (..())
			return TRUE
		src.task = null
		src.master.temp = null
		src.startup_line = 1

		src.netcard = locate() in src.master.peripherals
		if(!src.netcard || !istype(src.netcard))
			src.print_text("<b>Error:</b> No network card detected.<br>Quitting...")
			src.log_string += "<br>Startup Failure: No network card."
			src.master.unload_program(src)
			return TRUE

		src.radiocard = locate() in src.master.peripherals
		if(!radiocard || !istype(src.radiocard))
			src.radiocard = null
			src.print_text("<b>Warning:</b> No radio module detected.")
			src.log_string += "<br>Startup Error: No radio."

		src.log_string += "<br><b>LOGIN:</b> [src.authenticated]"

		src.ping_devices()

		var/intro_text = {"<br>EngineMaster
		<br>Automated Engine Control System
		<br><b>Commands:</b>
		<br>(Startup) to activate engine systems.
		<br>(Abort) to abort startup procedure.
		<br>(Rescan) to rescan for engine devices.
		<br>(Clear) to clear the screen.
		<br>(Quit) to exit."}
		src.print_text(intro_text)

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		src.print_text(strip_html(text))

		switch(lowertext(command))

			if("startup")
				//We're already starting, jeez give it some time
				if(src.starting_up)
					src.print_text("Startup already in progress.")
					src.master.add_fingerprint(usr)
					return

				if(!emitter_ids || length(emitter_ids) <= 0)
					src.print_text("<b>Error:</b> Insufficient emitters detected.")
					src.master.add_fingerprint(usr)
					return

				if(!fieldgen_ids || length(fieldgen_ids) < 4)
					src.print_text("<b>Error:</b> Insufficient field generators detected.")
					src.master.add_fingerprint(usr)
					return

				src.startup_line = 1
				src.starting_up = 1
				src.task = "startup-emit"
				src.log_string += "<br>Startup initiated."
				src.report_event("Engine starting up...")
				src.print_text("Startup procedure initiated.")

			if("abort")
				if(!src.starting_up)
					src.print_text("No startup procedure in progress.")
					src.master.add_fingerprint(usr)
					return

				src.startup_line = 1
				src.task = null
				src.starting_up = 0
				src.log_string += "<br>Startup aborted."
				src.print_text("Startup procedure aborted.")

			if("rescan")
				if((src.task && src.task != "scan") || src.starting_up)
					src.print_text("Unable to scan, system is busy.")
					return

				src.ping_devices()

			if("logdump")
				if(!src.log_string) //Something is wrong.
					src.print_text("<b>Error:</b> No log data to dump.")
					return

				if(src.holder.read_only)
					src.print_text("<b>Error:</b> Destination drive is read-only.")
					return

				var/datum/computer/file/text/logdump = get_file_name(setup_logdump_name, src.holding_folder)
				if(logdump && !istype(logdump) || get_folder_name(setup_logdump_name, src.holding_folder))
					src.print_text("<b>Error:</b> Name in use.")
					return

				if(logdump && istype(logdump))
					logdump.data = src.log_string
				else
					logdump = new /datum/computer/file/text
					logdump.name = setup_logdump_name
					logdump.data = src.log_string
					if(!src.holding_folder.add_file(logdump))
						//qdel(logdump)
						logdump.dispose()
						src.print_text("<b>Error:</b> Cannot save to disk.")
						return

				src.print_text("Log dumped to holding directory.")

			if("clear")
				src.master.temp = null
				src.master.temp_add = "Workspace cleared.<br>"

			if("quit")
				src.log_string += "<br><b>LOGOUT:</b> [src.authenticated]"
				src.print_text("Now quitting...")
				src.master.unload_program(src)
				return

			else
				src.print_text("Unknown command.")

		src.master.add_fingerprint(usr)
		src.master.updateUsrDialog()
		return

	process()
		if(..() || !src.task)
			return

		switch(src.task)
			if("startup-emit")
				if(startup_line > src.emitter_ids.len)
					src.task = "startup-field"
					src.startup_line = 1
					return

				post_status(src.emitter_ids[src.startup_line], "command", "activate")
				src.startup_line++

			if("startup-field")
				if(startup_line > src.fieldgen_ids.len)
					src.task = null
					src.startup_line = 1
					src.starting_up = 0
					src.print_text("Startup procedure complete.")
					return

				post_status(src.fieldgen_ids[src.startup_line], "command", "activate")
				src.startup_line++

	receive_command(obj/source, command, datum/signal/signal)
		if((..()) || !signal)
			return

		//Time to populate our lists of components.
		if(signal.data["command"] == "ping_reply" && (src.task == "scan"))
			if(!signal.data["netid"])
				return

			switch(signal.data["device"])
				if("PNET_ENG_EMITR") //Oh hey a new emitter.
					if(!(signal.data["netid"] in src.emitter_ids))
						src.emitter_ids += signal.data["netid"]
				if("PNET_ENG_FIELD")
					if(!(signal.data["netid"] in src.fieldgen_ids))
						src.fieldgen_ids += signal.data["netid"]
				else
					return

		return

	proc
		ping_devices()
			if(!src.netcard)
				return
			src.task = "scan"
			src.emitter_ids = new
			src.fieldgen_ids = new

			var/datum/signal/newsignal = get_free_signal()
			//newsignal.encryption = "\ref[src.netcard]"

			src.log_string += "<br>Scanning for devices..."
			src.print_text("Scanning for devices...")
			src.peripheral_command("ping", newsignal, "\ref[src.netcard]")

			return

		post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
			if(!src.netcard)
				return

			var/datum/signal/signal = get_free_signal()

			//signal.encryption = "\ref[src.netcard]"
			signal.data[key] = value
			if(key2)
				signal.data[key2] = value2
			if(key3)
				signal.data[key3] = value3

			signal.data["address_1"] = target_id
			src.peripheral_command("transmit", signal, "\ref[src.netcard]")

		report_event(var/event_string)
			if(!event_string || !src.radiocard)
				return

			//Unlikely that this would be a problem but OH WELL
			if(last_event_report && world.time < (last_event_report + 10))
				return

			//Set card frequency if it isn't already.
			if(src.radiocard.frequency != src.setup_mail_freq && !src.radiocard.setup_freq_locked)
				var/datum/signal/freqsignal = get_free_signal()
				//freqsignal.encryption = "\ref[src.radiocard]"
				peripheral_command("[src.setup_mail_freq]", freqsignal,"\ref[src.radiocard]")
				src.log_string += "<br>Adjusting frequency... \[[src.setup_mail_freq]]."

			var/datum/signal/signal = get_free_signal()
			//signal.encryption = "\ref[src.radiocard]"

			//Create a PDA mass-message string.
			signal.data["address_1"] = "00000000"
			signal.data["command"] = "text_message"
			signal.data["sender_name"] = "ENGINE-MAILBOT"
			signal.data["group"] = list(src.setup_mailgroup, MGA_ENGINE) //Only engineer PDAs should be informed.
			signal.data["message"] = "Notice: [event_string]"

			src.log_string += "<br>Event notification sent."
			last_event_report = world.time
			peripheral_command("transmit", signal, "\ref[src.radiocard]")
			return
