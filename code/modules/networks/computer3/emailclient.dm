//CONTENTS
//Email client!!


#define MENU_MAIN 0 //Fun reminder that Byond does not have enums and probably never will.
#define MENU_SETTINGS 1
#define MENU_SETTING_INPUT 2
#define MENU_MAIL_INDEX 3
#define MENU_MAIL_SELECT 4
#define MENU_MAIL_VIEW 5
#define MENU_WAIT 6
#define MENU_EDIT 7

#define MAIL_MODE_VIEW "V"
#define MAIL_MODE_DELETE "D"
#define MAIL_MODE_FORWARD "F"
#define MAIL_MODE_REPLY "R"

#define EDIT_MODE_TARGET 1
#define EDIT_MODE_SUBJ 2
#define EDIT_MODE_BODY 3
#define EDIT_MODE_REPLYBODY 4
#define EDIT_MODE_FWD_TARGET 5

#define MAX_MAIL_TITLE_LEN 32

/datum/computer/file/terminal_program/email
	name = "ViewPoint"
	size = 4

	// No special permissions required, but authentication is required to send email as *someone* and obviously
	// to recieve email
	req_access = list(access_fuck_all)
	var/tmp/obj/item/peripheral/network/netCard = null
	var/tmp/server_netid = null
	var/tmp/potential_server_netid = null
	var/tmp/connected = 0
	var/tmp/menu = MENU_MAIN
	var/tmp/list/mail_index = null
	var/tmp/list/mail_temp = null
	var/tmp/list/header_temp = null
	var/tmp/header_text = null
	var/tmp/setting_input = 0
	var/tmp/mail_mode = MAIL_MODE_VIEW
	var/tmp/edit_mode = EDIT_MODE_TARGET
	var/tmp/user_address = null

	var/tmp/edit_mail_address = null
	var/tmp/edit_mail_subject = null
	var/tmp/edit_mail_group = null

	var/max_lines = 16
	var/signature = null

	var/defaultDomain = "NT13"

	initialize()
		if (..())
			return TRUE
		src.netCard = null
		src.menu = 0
		var/introdat = "ViewPoint Email Client V1.5<br>Copyright 2051 Thinktronic Systems, LTD.<br>"

		src.netCard = find_peripheral("NET_ADAPTER")
		if (!src.netCard || !istype(src.netCard))
			src.netCard = null
			src.print_text("<b> Error:</b>No network card detected.  Quitting...")

			src.server_netid = null
			src.master.unload_program(src)
			return TRUE

		else
			introdat += mainmenu_text()

		src.master.temp = null
		src.print_text(introdat)

	input_text(text)
		if(..())
			return

		var/list/command_list = parse_string(text)
		var/command = command_list[1]
		command_list -= command_list[1]

		switch(menu)
			if (MENU_MAIN)
				switch (command)
					if ("0")
						src.print_text("Quitting...")
						if (connected)
							connected = 0
							disconnect_server()
						src.master.unload_program(src)
						return
					if ("1") //(dis)connect
						if (connected)
							disconnect_server()
							src.connected = 0
							src.master.temp = null
							src.print_text(mainmenu_text(1))
							return
						else
							if (server_netid)
								//Attempt to connect to server
								src.menu = -1
								connect_server(server_netid, 1)
								if (connected)
									src.print_text("Connection established to \[[server_netid]]!<br>[mainmenu_text(0)]")
									src.menu = MENU_MAIN
									return

								src.menu = MENU_MAIN
								src.print_text("Connection failed.")
								return
							else
								//Attempt to autodetect server & connect
								src.menu = -1
								src.print_text("Searching for mailserver...")
								if (ping_server(1))
									src.print_text("Unable to detect mailserver!")
									src.menu = MENU_MAIN
									return

								src.print_text("Mailserver detected at \[[potential_server_netid]]<br>Connecting...")
								connect_server(potential_server_netid, 1)

								src.menu = MENU_MAIN
								if (connected)
									src.print_text("Connection established to \[[server_netid]]!<br>[mainmenu_text(0)]")
									return

								src.print_text("Connection failed.")
								return
					if ("2") //Settings
						//todo: List all settings
						src.master.temp = null
						var/menuText = "Options:<br><br> (1) Set Mailserver Address<br> (2) Set Max Printed Lines Before Prompt \[[max_lines]]<br> (3) Set signature<br> (0) Go Back."
						src.print_text(menuText)
						src.menu = MENU_SETTINGS
						return
					if ("3") //Receive mail
						message_server("command=mail&args=index")
						return

					if ("4") //View mailbox

						src.menu = MENU_MAIL_INDEX
						src.master.temp = null
						src.print_text(mailbox_text())
						return

					if ("5") //Compose new email

						src.menu = MENU_EDIT
						src.edit_mode = EDIT_MODE_TARGET
						src.print_text("Please enter target address. \"AddressName--MailGroup\" or 0 to return.")

						return

			if (MENU_SETTINGS)
				switch (command)
					if ("1")
						if (src.connected)
							src.print_text("This cannot be changed while connected.")
							return

						src.print_text("Current value: [server_netid ? server_netid : "AUTO"]<br>Please enter new value.")
						src.setting_input = 1
						src.menu = MENU_SETTING_INPUT

					if ("2")
						src.print_text("Please enter new value (1-64).")
						src.setting_input = 2
						src.menu = MENU_SETTING_INPUT

					if ("3")
						src.print_text("Current value: [signature ? signature : "OFF"]<br>Please enter new value, *NONE to clear, or 0 to return.")
						src.setting_input = 3
						src.menu = MENU_SETTING_INPUT

					if ("0")
						src.menu = MENU_MAIN
						src.master.temp = null
						src.print_text(mainmenu_text())
						return

				return

			if (MENU_SETTING_INPUT)
				switch (setting_input)
					if (1)
						var/new_netid = ckey(command)
						if (new_netid == "auto")
							src.print_text("Automatic mailserver location enabled.")
							server_netid = null
						else if (!new_netid || !is_hex(new_netid) || length(new_netid) != 8)
							src.print_text("Invalid value.")
						else
							server_netid = new_netid
							src.print_text("New mailserver address set.")

					if (2)
						var/new_max_lines = round(text2num_safe(command))
						if (new_max_lines < 1 || new_max_lines > 64)
							src.print_text("Invalid value.")
						else
							max_lines = new_max_lines
							src.print_text("New line maximum set.")

					if (3)
						var/new_signature = copytext( strip_html(text), 1, 129 )
						if (new_signature != "0")
							if (ckey(new_signature) && lowertext(new_signature) != "*none")
								src.signature = new_signature

							else
								src.signature = null

							src.print_text("New signature set.")

				src.menu = MENU_SETTINGS
				src.setting_input = 0
				return

			if (MENU_MAIL_INDEX)
				switch (lowertext(command))
					if ("v")
						src.mail_mode = MAIL_MODE_VIEW
						src.print_text("Mode set to: View Mail Entry.")
					if ("d")
						src.mail_mode = MAIL_MODE_DELETE
						src.print_text("Mode set to: Delete Mail Entry.")
					if ("f")
						src.mail_mode = MAIL_MODE_FORWARD
						src.print_text("Mode set to: Forward Mail Entry.")
					if ("r")
						src.mail_mode = MAIL_MODE_REPLY
						src.print_text("Mode set to: Reply to Mail Entry.")

					else
						var/index_number = round( max( text2num_safe(command), 0) )
						if (index_number == 0)
							src.menu = MENU_MAIN
							src.master.temp = null
							src.print_text(mainmenu_text())
							return

						if (!istype(mail_index) || index_number > mail_index.len)
							src.print_text("Invalid mail entry.")
							return

						if (!connected)
							src.print_text("Not connected to mailserver.")
							return

						switch (mail_mode)
							if (MAIL_MODE_VIEW)
								//steps: request mail from server -> load mail -> display in sections
								src.mail_temp = null
								src.header_temp = null
								message_server("command=mail&args=get [index_number]") //Request mail
								src.menu = -1
								sleep(0.8 SECONDS)
								if (istype(mail_temp))
									var/dat = ""
									var/end_max = clamp(length(mail_temp), 8, max_lines) - 8
									for (var/i = 1, i <= end_max, i++)
										dat += "<br>[mail_temp[i]]"

									src.master.temp = null
									if (end_max < mail_temp.len)
										print_text("[header_text][dat]<br> ([mail_temp.len-end_max]) lines remaining. Any key to show more, 0 to return.")
										src.menu = MENU_MAIL_VIEW
										src.mail_temp.Cut(1,end_max+1)
										return

									print_text("[header_text][dat]<br>|---------| Press 0 to Return |---------|")
									src.menu = MENU_WAIT
									return

								src.print_text("Error retrieving mail.")
								sleep(1 SECOND)
								src.menu = MENU_MAIL_INDEX
								src.print_text(mainmenu_text())
								return
							if (MAIL_MODE_DELETE)
								src.menu = -1
								message_server("command=mail&args=delete [index_number]")

								src.mail_index = null
								message_server("command=mail&args=index")
								sleep(0.8 SECONDS)
								if (istype(src.mail_index))
									src.master.temp = null
									src.print_text(mailbox_text())
									src.menu = MENU_MAIL_INDEX
									return

								src.print_text("Unable to refresh mailbox.")
								sleep(1 SECOND)
								src.menu = MENU_MAIL_INDEX
								src.print_text(mainmenu_text())
								return
							if (MAIL_MODE_FORWARD)
								//steps: request mail from server -> load mail -> request new target -> send to new target
								src.mail_temp = null
								message_server("command=mail&args=get [index_number]") //Request mail
								src.menu = -1
								sleep(0.8 SECONDS)
								if (istype(mail_temp))
									src.print_text("Please enter new target address. \"AddressName--MailGroup\"")
									src.menu = MENU_EDIT
									src.edit_mode = EDIT_MODE_FWD_TARGET
									return

								src.print_text("Error retrieving mail.")
								sleep(1 SECOND)
								src.menu = MENU_MAIL_INDEX
								src.print_text(mainmenu_text())
								return
							if (MAIL_MODE_REPLY)
								src.mail_temp = null
								message_server("command=mail&args=get [index_number]")
								src.menu = -1
								sleep(0.8 SECONDS)
								if (istype(mail_temp))
									src.print_text("Please enter body text, \"!send\" to send,<br>\"!del\" to remove last line or JUST 0 to return.")
									if (src.mail_temp)
										src.mail_temp.len = 0
									src.menu = MENU_EDIT
									src.edit_mode = EDIT_MODE_REPLYBODY
									return

								src.print_text("Error retrieving mail.")
								sleep(1 SECOND)
								src.menu = MENU_MAIL_INDEX
								src.print_text(mainmenu_text())
								return

			if (MENU_MAIL_VIEW)
				if (command == "0" || (!src.mail_temp || !length(src.mail_temp)))
					src.menu = MENU_MAIL_INDEX
					src.master.temp = null
					src.print_text(mailbox_text())
					return

				if (istype(mail_temp))
					var/dat = ""
					var/end_max = min(mail_temp.len, max_lines)
					for (var/i = 1, i <= end_max, i++)
						dat += "<br>[mail_temp[i]]"

					if (end_max < mail_temp.len)
						print_text("[dat]<br> ([mail_temp.len-end_max]) lines remaining. Any key to show more, 0 to return.")
						src.mail_temp.Cut(1,end_max+1)
						return

					print_text("[dat]<br>|---------| Press 0 to Return |---------|")
					src.menu = MENU_WAIT
					return

			if (MENU_WAIT)
				if (command == "0")
					src.menu = MENU_MAIL_INDEX
					src.master.temp = null
					src.print_text(mailbox_text())

				return

			if (MENU_EDIT)
				switch (edit_mode)
					if (EDIT_MODE_TARGET)
						if (command == "0")
							src.menu = MENU_MAIL_INDEX
							src.master.temp = null
							src.print_text(mailbox_text())
							return

						var/attemptAddress = copytext( ckeyEx(uppertext(text)), 1, 33)
						if (!attemptAddress)
							return

						var/mailgroupName = null
						var/mailgroupPoint = findtext(attemptAddress, "--")
						if (mailgroupPoint)
							mailgroupName = copytext(attemptAddress, mailgroupPoint+2)
							attemptAddress = copytext(attemptAddress, 1, mailgroupPoint)
							if (!attemptAddress && ckey(mailgroupName))
								attemptAddress = "GENERIC@[defaultDomain]"
							else if (!ckey(mailgroupName) || findtext(attemptAddress, "--"))
								src.print_text("Invalid mailgroup specification. Try \"Address--mailGroupName\"")
								return

						if (!findtext(attemptAddress, "@"))
							attemptAddress += "@[defaultDomain]"

						src.edit_mode = EDIT_MODE_SUBJ
						src.edit_mail_address = attemptAddress
						src.edit_mail_group = mailgroupName
						src.print_text("Target Address set to \"[edit_mail_address]\"[mailgroupName ? "<br>Target Mailgroup set to \"[mailgroupName]\"" : null]<br>Please enter subject line, or 0 to go back to address entry.")
						return

					if (EDIT_MODE_SUBJ)
						if (command == "0")
							src.edit_mode = EDIT_MODE_TARGET
							src.print_text("Please enter new target address. \"AddressName--MailGroup\" or 0 to return.")
							return

						var/attemptSubj = copytext( strip_html(text), 1, 33 )
						if (!ckey(attemptSubj))
							return

						src.edit_mode = EDIT_MODE_BODY
						if (src.mail_temp)
							src.mail_temp.len = 0
						else
							src.mail_temp = list()

						src.edit_mail_subject = attemptSubj
						src.print_text("Subject Line set to \"[edit_mail_subject]\"<br>Please enter body text, \"!send\" to send,<br>\"!del\" to remove last line or JUST 0 to go back to subject entry.")
						return

					if (EDIT_MODE_BODY, EDIT_MODE_REPLYBODY)
						if (command == "0")
							if (edit_mode == EDIT_MODE_BODY)
								src.edit_mode = EDIT_MODE_SUBJ
								src.print_text("Please enter subject line, or 0 to go back.")

							else
								src.menu = MENU_MAIL_INDEX
								src.master.temp = null
								src.print_text(mailbox_text())

							return

						else if (copytext(command,1,2) == "!")
							switch (lowertext(command))
								if ("!send")

									src.menu = -1
									if (edit_mode == EDIT_MODE_REPLYBODY && header_temp)
										header_temp["subj"] = copytext("RE: [header_temp["subj"]]", 1, 33)
										src.edit_mail_group = "*NONE"
									else
										header_temp = list()
										header_temp["mailnet"] = "PUBLIC_NT"
										header_temp["priority"] = "STANDARD"
										header_temp["subj"] = src.edit_mail_subject
									header_temp["target"] =src.edit_mail_address
									header_temp["group"] = src.edit_mail_group ? uppertext(src.edit_mail_group) : "*NONE"
									header_temp["sender"] = user_address ? user_address : "???"
									mail_temp.Insert(1, list2params(header_temp))

									if (src.signature)
										mail_temp += "-[src.signature]"

									var/datum/computer/file/record/outgoingMail = new
									outgoingMail.name = "mail"
									outgoingMail.fields = mail_temp
									src.mail_temp = null
									header_temp = null
									message_server("command=mail&args=send", outgoingMail)
									src.print_text("Sending message...")

									src.mail_index = null
									message_server("command=mail&args=index")
									sleep(0.8 SECONDS)
									if (istype(src.mail_index))
										src.master.temp = null
										src.print_text(mailbox_text())
										src.menu = MENU_MAIL_INDEX
										return

									src.print_text("Unable to refresh mailbox.")
									sleep(1 SECOND)
									src.menu = MENU_MAIL_INDEX
									src.print_text(mainmenu_text())
									return

								if ("!del")
									if (!istype(src.mail_temp) || !length(src.mail_temp))
										return

									src.mail_temp.len--
									src.print_text("Line removed.")
									return

							return

						if (!src.mail_temp)
							src.mail_temp = list()

						var/toAdd = copytext( strip_html(text), 1, MAX_MESSAGE_LEN)
						if (!ckeyEx(toAdd) || length(src.mail_temp) >= 99)
							return

						src.mail_temp += toAdd
						src.print_text("\[[add_zero("[src.mail_temp.len]", 2)]] [toAdd]")

						return

					if (EDIT_MODE_FWD_TARGET)
						if (command == "0" || !istype(mail_temp) || !length(mail_temp))
							src.menu = MENU_MAIL_INDEX
							src.master.temp = null
							src.print_text(mailbox_text())
							return

						var/attemptAddress = copytext( ckeyEx(uppertext(text)), 1, 33)
						if (!attemptAddress)
							return

						var/mailgroupName = null
						var/mailgroupPoint = findtext(attemptAddress, "--")
						if (mailgroupPoint)
							mailgroupName = copytext(attemptAddress, mailgroupPoint+2)
							attemptAddress = copytext(attemptAddress, 1, mailgroupPoint)
							if (!attemptAddress && ckey(mailgroupName))
								attemptAddress = "GENERIC@[defaultDomain]"
							else if (!ckey(mailgroupName) || findtext(attemptAddress, "--"))
								src.print_text("Invalid mailgroup specification. Try \"address--mailGroupName\"")
								return

						if (!findtext(attemptAddress, "@"))
							attemptAddress += "@[defaultDomain]"

						if (length(header_temp)) //email from grandma, FWD: RE: FWD: FWD: Space-President Jordan WQIT'XFWQ' Wilkins actually syndicate martian infiltrator!!
							src.menu = -1
							header_temp["subj"] = "FWD: [header_temp["subj"]]"
							header_temp["target"] = attemptAddress
							header_temp["group"] = mailgroupName ? uppertext(mailgroupName) : "*NONE"
							header_temp["sender"] = user_address ? user_address : "???"
							mail_temp.Insert(1, list2params(header_temp))

							var/datum/computer/file/record/outgoingMail = new
							outgoingMail.name = "mail"
							outgoingMail.fields = mail_temp
							src.mail_temp = null
							header_temp = null
							message_server("command=mail&args=send", outgoingMail)
							src.print_text("Forwarding message...")

							src.mail_index = null
							message_server("command=mail&args=index")
							sleep(0.8 SECONDS)
							if (istype(src.mail_index))
								src.master.temp = null
								src.print_text(mailbox_text())
								src.menu = MENU_MAIL_INDEX
								return

						src.print_text("Unable to refresh mailbox.")
						sleep(1 SECOND)
						src.menu = MENU_MAIL_INDEX
						src.print_text(mainmenu_text())
						return

	receive_command(obj/source, command, datum/signal/signal)
		if ((..()) || (!signal))
			return

		if (!connected)
			if (signal.data["command"] == "ping_reply" && !potential_server_netid)

				if (signal.data["device"] == "PNET_MAINFRAME" && signal.data["sender"] && is_hex(signal.data["sender"]))
					potential_server_netid = signal.data["sender"]
					return

			else if (signal.data["command"] == "term_connect")
				server_netid = ckey(signal.data["sender"])
				connected = 1
				potential_server_netid = null
				if(signal.data["data"] != "noreply")
					var/datum/signal/termsignal = get_free_signal()

					termsignal.data["address_1"] = signal.data["sender"]
					termsignal.data["command"] = "term_connect"
					termsignal.data["device"] = "SRV_TERMINAL"
					termsignal.data["data"] = "noreply"

					src.peripheral_command("transmit", termsignal, "\ref[netCard]")

			return
		else
			if (signal.data["sender"] != server_netid)
				return

			if (!server_netid)
				connected = 0
				return

			switch(lowertext(signal.data["command"]))
				if ("term_message")
					var/list/data = params2list(signal.data["data"])
					if(!data || !data["command"])
						return

					switch (lowertext(data["command"]))
						if ("mail_index")
							src.mail_index = null
							return
					//todo
					return

				if ("term_file")
					var/list/data = params2list(signal.data["data"])
					if(!data || !data["command"])
						return

					switch (lowertext(data["command"]))
						if ("mail_index")
							var/datum/computer/file/record/indexRecord = signal.data_file
							if (!istype(indexRecord))
								return

							src.mail_index = indexRecord.fields.Copy()

						if ("mail_entry")
							var/datum/computer/file/record/entryRecord = signal.data_file
							if (!istype(entryRecord))
								return

							if (src.mail_temp)
								src.mail_temp = null

							var/list/headerList = params2list(entryRecord.fields[1])
							if (!headerList || !length(headerList))
								return

							src.header_temp = headerList
							entryRecord.fields.Cut(1,2)
							src.mail_temp = entryRecord.fields.Copy()
							if (!mail_temp)
								mail_temp = list("--No Message Body--")

							header_text = {"-----------------|HEAD|-----------------<br>
MAILNET: [ckeyEx(headerList["mailnet"]) ? copytext(uppertext(ckeyEx(headerList["mailnet"])), 1, 33) : "???"]<br>
WORKGROUP: [ckeyEx(headerList["group"]) ? copytext(uppertext(headerList["group"]), 1, 33) : "???"]<br>
FROM: [ckeyEx(headerList["sender"]) ? copytext(uppertext(headerList["sender"]), 1, 33) : "???"]<br>
TO: [ckeyEx(headerList["target"]) ? copytext(uppertext(headerList["target"]), 1, 33) : "???"]<br>
PRIORITY: [ckeyEx(headerList["priority"]) ? copytext(uppertext(ckeyEx(headerList["priority"])), 1, 9) : "???"]<br>
SUBJECT: [ckeyEx(headerList["subj"]) ? copytext(uppertext(headerList["subj"]), 1, 33) : "???"]<br>
----------------------------------------"}

					return

				if ("term_disconnect")
					src.connected = 0
					src.user_address = null
					src.print_text("Connection closed by mailserver.")

				if("term_ping")
					if(signal.data["data"] == "reply")
						var/datum/signal/termsignal = get_free_signal()

						termsignal.data["address_1"] = signal.data["sender"]
						termsignal.data["command"] = "term_ping"

						src.peripheral_command("transmit", termsignal, "\ref[netCard]")


		return

	proc
		connect_server(var/attempted_netid, delayCaller=0)
			if (connected || !netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = attempted_netid
			signal.data["command"] = "term_connect"
			signal.data["device"] = "SRV_TERMINAL"
			var/datum/computer/file/record/udat = null
			if (istype(src.account))
				udat = new

				var/userid = format_username(src.account.registered)

				udat.fields["userid"] = userid
				src.user_address = "[userid]@[defaultDomain]"
				//udat.fields["assignment"] = src.account.assignment
				udat.fields["access"] = list2params(src.account.access)
				if (!udat.fields["access"] || !udat.fields["userid"])
					//qdel(udat)
					udat.dispose()
					return 1

				udat.fields["service"] = "mail"

			if (udat)
				signal.data_file = udat

			src.peripheral_command("transmit", signal, "\ref[netCard]")
			if (delayCaller)
				sleep(0.8 SECONDS)
				return 0

			return 0

		disconnect_server()
			if (!server_netid || !netCard)
				return 1

			var/datum/signal/signal = get_free_signal()

			signal.data["address_1"] = server_netid
			signal.data["command"] = "term_disconnect"

			src.peripheral_command("transmit", signal, "\ref[netCard]")

			return 0

		message_server(var/message, var/datum/computer/file/toSend)
			if (!connected || !server_netid || !netCard || !message)
				return 1

			var/datum/signal/termsignal = get_free_signal()

			termsignal.data["address_1"] = server_netid
			termsignal.data["data"] = message
			termsignal.data["command"] = "term_message"
			if (toSend)
				termsignal.data_file = toSend

			src.peripheral_command("transmit", termsignal, "\ref[netCard]")
			return 0

		ping_server(delayCaller=0)
			if (connected || !netCard)
				return 1

			potential_server_netid = null
			src.peripheral_command("ping", null, "\ref[netCard]")

			if (delayCaller)
				sleep(0.8 SECONDS)
				return (potential_server_netid == null)

			return 0

		mainmenu_text(display_server=1)
			. = null
			if (display_server)
				. = "<b>Mail Server</b>: "
				if (server_netid)
					. += "\[[server_netid]] ([connected ? null : "Not "]Connected)<br>Your address is: \[[user_address ? user_address : "???"]]<br><br>"
				else
					. += "None Set<br><br>"

			. += "Please Select an Option:<br> (1) [connected ? "Disconnect from" : "Connect to"] Mailserver.<br> (2) Mailserver Settings."
			if (connected)
				. += "<br> (3) Receive Mail<br> (4) View Mailbox.<br> (5) Compose Mail."

			. += "<br> (0) Quit"


		mailbox_text()
			. = "Message List:"
			if (istype(mail_index) && length(mail_index))
				var/leadingZeroCount = length("[mail_index.len]")
				for (var/i = 1, i <= mail_index.len, i++)
					var/iTitle = mail_index[i]
					if (length(iTitle) > MAX_MAIL_TITLE_LEN)
						iTitle = "[copytext(iTitle, 1,MAX_MAIL_TITLE_LEN+1)]..."

					. += "<br> \[[add_zero("[i]", leadingZeroCount)]] [iTitle]"
			else
				. += "<br> No Messages."

			. += "<br><br>Modes: (V) View (R) Reply (F) Forward (D) Delete<br>Current Mode: ([src.mail_mode])<br>Enter mail number or 0 to return."


#undef MENU_MAIN
#undef MENU_SETTINGS
#undef MENU_SETTING_INPUT
#undef MENU_MAIL_INDEX
#undef MENU_MAIL_SELECT
#undef MENU_MAIL_VIEW
#undef MENU_WAIT
#undef MENU_EDIT

#undef MAIL_MODE_VIEW
#undef MAIL_MODE_DELETE
#undef MAIL_MODE_FORWARD
#undef MAIL_MODE_REPLY

#undef EDIT_MODE_TARGET
#undef EDIT_MODE_SUBJ
#undef EDIT_MODE_BODY
#undef EDIT_MODE_REPLYBODY
#undef EDIT_MODE_FWD_TARGET

#undef MAX_MAIL_TITLE_LEN
