TYPEINFO(/obj/machinery/communications_dish)
	mats = 25

/obj/machinery/communications_dish
	name = "Communications dish"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "def_radar"
	anchored = ANCHORED
	density = 1
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/list/terminals = list() //list of netIDs of connected terminals.
	var/net_id = null
	var/obj/machinery/power/data_terminal/link = null
	//Radio inter-dish communications
	var/frequency = FREQ_COMM_DISH
	var/list/cargo_logs = list()

	deconstruct_flags = DECON_NONE

	New()
		..()
		START_TRACKING
		SPAWN(0.6 SECONDS)
			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

	disposing()
		STOP_TRACKING
		if (link)
			link.master = null
		link = null
		..()

	proc
		add_centcom_report(var/title, var/message)
			if (!message)
				return

			if (src.status & (BROKEN|NOPOWER) )
				return

			if (!title)
				title = "Cent. Com. Report"

			messagetitle += title
			messagetext += message

			if (!src.link)
				return

			var/list/report_content = list(title) + splittext(message, "<BR>")

			for (var/listener_netid in src.terminals)
				var/datum/computer/file/record/report = new ()
				report.fields = report_content.Copy()
				report.name = "report[messagetext.len]"

				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.transmission_method = TRANSMISSION_WIRE
				signal.data["command"] = "term_file"
				signal.data["data"] = "command=add_report"
				signal.data_file = report

				signal.data["address_1"] = listener_netid
				signal.data["sender"] = src.net_id

				src.link.post_signal(src, signal)

		transmit_to_centcom(var/title, var/message, var/user)
			var/sound_to_play = 'sound/misc/announcement_1.ogg'
			command_alert(message, title, sound_to_play, alert_origin = "Transmission to Central Command")
			message_admins("[user ? user : "Someone"] sent a message to Central Command:<br>[title]<br><br>[message]")
			var/ircmsg[] = new()
			//discord can do their own encoding, bite me
			ircmsg["msg"] = "[user ? user : "Unknown"] sent a message to Central Command:\n**[title]**\n[html_decode(message)]"
			ircbot.export_async("admin", ircmsg)

		transmit_to_partner_station(var/title, var/message, var/user)
			var/sound_to_play = 'sound/misc/announcement_1.ogg'
			command_alert(message, title, sound_to_play, alert_origin = "Transmission to Partner Station")
			var/ircmsg[] = new()
			var/sent = game_servers.get_buddy() ? "sent" : "failed to send"
			ircmsg["msg"] = "[user ? user : "Unknown"] [sent] a message to __[game_servers.get_buddy()?.name]__:\n**[title]**\n[message]"
			ircbot.export_async("admin", ircmsg)
			if(game_servers.get_buddy())
				return game_servers.send_to_buddy("announce", title, message)

		add_cargo_logs(var/atom/A)
			if (!A)
				return

			if (src.status & (BROKEN|NOPOWER))
				return

			if (length(cargo_logs) > 20)
				cargo_logs.len = 10

			var/shiftTime = round(ticker.round_elapsed_ticks / 600)
			cargo_logs += "LOST : \[ [A.name] \]  at [shiftTime] minute[shiftTime == 1 ? "" : "s"]"

		post_status(var/target_id, var/key, var/value, var/key2, var/value2, var/key3, var/value3)
			if(!src.link || !target_id)
				return

			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.transmission_method = TRANSMISSION_WIRE
			signal.data[key] = value
			if(key2)
				signal.data[key2] = value2
			if(key3)
				signal.data[key3] = value3

			signal.data["address_1"] = target_id
			signal.data["sender"] = src.net_id

			src.link.post_signal(src, signal)

		post_reply(error_text, target_id, key3, value3)
			if(!error_text || !target_id)
				return
			SPAWN(0.3 SECONDS)
				src.post_status(target_id, "command", "device_reply", "status", error_text, key3, value3)
			return

		parse_string(string) //Parse commands the same way a c3 does, for terminal control.
			var/list/sort1 = list()
			sort1 = splittext(string,";")
			for(var/x in sort1)
				var/list/sorted = list()
				sorted = splittext(x," ")
				return sorted

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		//They don't need to target us specifically to ping us.
		//Otherwise, ff they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", "PNET_COM_ARRAY", "netid", src.net_id)

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("call", "recall") //Time to call/cancel a shuttle!
				switch(signal.data["shuttle_id"])
					if("emergency")
						if(signal.data["acc_code"] != netpass_heads) //Cool dudes with head codes only thanks.
							return //Otherwise you have every jerk calling the shuttle from medbay or some shit.

						var/call_reason = ""
						if(signal.data["reason"])
							call_reason = signal.data["reason"]

						if(emergency_shuttle.location!=0)
							src.post_reply("SHUTL_E_DIS", target)
							return

						if(sigcommand == "call")
							//don't spam call it you buttes
							if(emergency_shuttle.online || call_shuttle_proc(signal.author, call_reason=call_reason)) //Returns 1 on failure
								src.post_reply("SHUTL_E_DIS", target)
								return
							src.post_reply("SHUTL_E_SEN", target)
						else if(sigcommand == "recall")
							if(!emergency_shuttle.online || cancel_call_proc(signal.author))
								src.post_reply("SHUTL_E_DIS", target)
								return
							src.post_reply("SHUTL_E_RET", target)
					else
						; //to-do: error reply
			if("transmit")
				if(signal.data["acc_code"] != netpass_heads)
					return
				if(signal.data["transmit_type"] == "centcom")
					if(ON_COOLDOWN(global, "transmit_centcom", 10 MINUTES))
						src.post_reply("TRANSMIT_E_COOLDOWN", target, "time", ON_COOLDOWN(global, "transmit_centcom", 0))
						return
					src.transmit_to_centcom(signal.data["title"], signal.data["data"], signal.data["user"])
					src.post_reply("TRANSMIT_E_SUCCESS", target)
				else if(signal.data["transmit_type"] == "station")
					if(ON_COOLDOWN(global, "transmit_station", 5 MINUTES))
						src.post_reply("TRANSMIT_E_COOLDOWN", target, "time", ON_COOLDOWN(global, "transmit_station", 0))
						return
					if(src.transmit_to_partner_station(signal.data["title"], signal.data["data"], signal.data["user"]))
						src.post_reply("TRANSMIT_E_SUCCESS", target)
					else
						global.cooldowns["transmit_station"] = 0
						src.post_reply("TRANSMIT_E_FAILURE", target)
			if("term_connect") //Terminal interface stuff.
				if(target in src.terminals)
					//something might be wrong here, disconnect them!
					src.terminals.Remove(target)
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				src.terminals.Add(target) //Accept the connection!
				src.post_status(target, "command","term_connect","data","noreply","device","PNET_COM_ARRAY")
				src.updateUsrDialog()
				SPAWN(0.2 SECONDS) //Hello!
					src.post_status(target,"command","term_message","data","command=register")
				return

			if("term_message")
				if(!(target in src.terminals)) //Ignore mystery jerks who aren't connected.
					return

				var/list/commandList = params2list(signal.data["data"])
				if (!commandList || !length(commandList))
					return

				switch (commandList["command"])
					if ("list")
						. = list()
						for(var/x, x <= src.messagetitle.len, x++)
							var/mtitle = src.messagetitle[x]
							if(isnull(mtitle)) continue

							.["[add_zero("[x]",2)]"] = "[mtitle]"

						SPAWN(0.3 SECONDS)
							src.post_status(target, "command","term_message","data",list2params(.),"render","multiline")
						return

					if ("download")
						var/msg_id = round(text2num_safe(commandList["message"]))

						if(!msg_id || msg_id > src.messagetext.len)
							return

						var/to_send = src.messagetext[msg_id]
						if(!to_send) return

						//post status doesn't cover file attachments, so we do it here
						if(!src.link || !target)
							return

						var/datum/computer/file/text/sendfile = new
						sendfile.name = "temp"
						sendfile.data = to_send

						var/datum/signal/filesig = new()
						filesig.source = src
						filesig.transmission_method = TRANSMISSION_WIRE

						filesig.data_file = sendfile
						filesig.data["command"] = "term_file"
						filesig.data["data"] = ""
						filesig.data["address_1"] = target
						filesig.data["sender"] = src.net_id

						SPAWN(0.3 SECONDS)
							src.link.post_signal(src, filesig)

/*
				var/termcommand = lowertext(signal.data["data"])
				if(!termcommand) return
				var/list/termlist = parse_string(termcommand)
				termcommand = termlist[1]
				termlist -= termlist[1]

				switch(termcommand)
					if("list")
						var/listdat = null
						for(var/x, x <= src.messagetitle.len, x++)
							var/mtitle = src.messagetitle[x]
							if(isnull(mtitle)) continue

							listdat += "MSG:\[[add_zero("[x]",2)]] [mtitle]|n"

						if(!listdat)
							listdat = "No messages available."

						SPAWN(0.3 SECONDS)
							src.post_status(target, "command","term_message","data",listdat,"render","multiline")
						return

					if("download")
						var/msg_id = 0
						if(termlist.len)
							msg_id = round(text2num_safe(termlist[1]))

						if(!msg_id || msg_id > src.messagetext.len)
							return

						var/to_send = src.messagetext[msg_id]
						if(!to_send) return

						//post status doesn't cover file attachments, so we do it here
						if(!src.link || !target)
							return

						var/datum/computer/file/text/sendfile = new
						sendfile.name = "temp"
						sendfile.data = to_send

						var/datum/signal/filesig = new()
						filesig.source = src
						filesig.transmission_method = TRANSMISSION_WIRE

						filesig.data_file = sendfile
						filesig.data["command"] = "term_file"
						filesig.data["address_1"] = target
						filesig.data["sender"] = src.net_id

						SPAWN(0.3 SECONDS)
							src.link.post_signal(src, filesig)
*/
				return

			if("term_ping")
				if(!(target in terminals))
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				//src.timeout = initial(src.timeout)
				//src.timeout_alert = 0 //no really please stay zero
				return

			if("term_disconnect")
				if(target in src.terminals)
					src.terminals -= target

				return


		return
