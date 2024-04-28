 //CONTENTS
//GPTIO interface for artifact research.
//Blathering on about that GPTIO thing.

//Interface program for general test devices
/datum/computer/file/mainframe_program/test_interface
	name = "gptio"
	size = 8
	var/tmp/response_timeout = 0
	var/tmp/silent = 0 //Do not print response messages to user.

	process()
		if (..() || !useracc)
			return

		if (response_timeout)
			if (--response_timeout < 1)
				message_user("Timed out.")
				mainframe_prog_exit
				return

		return

	message_user(var/msg, var/render=null)
		if (!silent)
			return ..(msg, render)

		return ESIG_SUCCESS

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		silent = 0

		var/list/initlist = splittext(initparams, " ")

		if (initlist.len && dd_hasprefix(initlist[1], "-"))
			var/flagString = lowertext(copytext(initlist[1], 2))
			var/flagCount = length(flagString)
			initlist.Cut(1,2)

			for (var/n = 1, n <= flagCount, n++)
				var/flag = copytext(flagString, n, n+1)
				switch (flag)
					if ("b") //Batch operation
						; //todo

					if ("s") //Silent operation
						silent = 1

					else
						silent = 0
						message_user("Invalid flag \"-[flag]\"")
						mainframe_prog_exit
						return

		if (!initparams || !length(initlist))
			message_user("Invalid commmand argument.|nValid Commands:|n \"List\" to list known devices.|n \"Info (Device ID)\"  to list device information.|n \"Poke (Device ID) (Field Name) (Value)\" to configure device variables.|n \"Peek (Device ID) (Field Name)\" to view device variables.|n \"(De)Activate (Device ID)\" to activate/deactivate device.|n \"Pulse (Device ID) (Duration)\" to activate device for specified duration.|n \"Sense (Device ID)\" to take sensor readings.|n \"Read (Device ID)\" to read sense results.|n Device name may be used in place of ID.","multiline")
			mainframe_prog_exit
			return

		var/list/testDrivers = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="test_appt", "mode"=0))
		if (!istype(testDrivers))
			return

		var/command = lowertext(initlist[1])
		initlist.Cut(1,2)
		switch(command)
			if ("list")
				var/listText = ""
				for (var/x in testDrivers)
					if (!x) continue
					listText += "| [x] | [testDrivers[x] ? "[testDrivers[x]]" : "INVALID"]|n"
				if (!listText)
					listText = "| NONE|n"
				message_user("Known Test Devices:|n+----ID----+--------DEVICE NAME--------+|n[listText]+----------+---------------------------+", "multiline")

			if ("info")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)
						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="info"))
						if (success == ESIG_SUCCESS)
							message_user("Loading...")
							response_timeout = 2
							return

						else
							message_user("Error: Unable to signal device.")

					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="info"))
								if (success == ESIG_SUCCESS)
									message_user("Loading...")
									response_timeout = 2
									return

								else
									message_user("Error: Unable to signal device.")


								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			if ("peek")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)

						if (length(initlist) >= 2)
							var/fieldName = ckey(initlist[2])
							if (fieldName)
								if(signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="peek", "field"="[fieldName]")) == ESIG_SUCCESS)
									message_user("Loading...")
									response_timeout = 2
									return
								else
									message_user("Error: Unable to signal device.")
							else
								message_user("Error: No field name specified.")
						else
							message_user("Error: No field name specified.")
					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								if (length(initlist) >= 2)
									var/fieldName = ckey(initlist[2])
									if (fieldName)
										if(signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="peek", "field"="[fieldName]")) == ESIG_SUCCESS)
											message_user("Loading...")
											response_timeout = 2
											return
										else
											message_user("Error: Unable to signal device.")
									else
										message_user("Error: No field name specified.")
								else
									message_user("Error: No field name specified.")

								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			if ("poke")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)

						if (length(initlist) >= 3)
							var/fieldName = ckey(initlist[2])
							var/newValue = ckey(initlist[3])
							if (fieldName && newValue)
								if(signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="poke", "field"="[fieldName]", "value"="[newValue]")) == ESIG_SUCCESS)
									message_user("Sending...")
									response_timeout = 2
									return
								else
									message_user("Error: Unable to signal device.")
							else
								message_user("Error: Field name or value not specified.")
						else
							message_user("Error: Field name or value not specified.")
					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								if (length(initlist) >= 3)
									var/fieldName = ckey(initlist[2])
									var/newValue = ckey(initlist[3])
									if (fieldName && newValue)
										if(signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="poke", "field"="[fieldName]", "value"="[newValue]")) == ESIG_SUCCESS)
											message_user("Sending...")
											response_timeout = 2
											return
										else
											message_user("Error: Unable to signal device.")
									else
										message_user("Error: Field name or value not specified.")
								else
									message_user("Error: Field name or value not specified.")

								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			if ("pulse")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)

						//Pulses have a duration from 1 to 255.
						var/duration = 1
						if (length(initlist) >= 2)
							duration = text2num_safe(initlist[2])
							if (isnum(duration))
								duration = round(duration)
								if (duration < 1 || duration > 255)
									duration = clamp(duration, 1, 255)
									message_user("Warning: Pulse duration out of bounds \[1 - 255]. Value clamped.")
							else
								duration = 1
								message_user("Warning: Non-numeric pulse duration! Argument ignored.")

						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="pulse", "duration"=duration))
						if (success == ESIG_SUCCESS)
							message_user("OK")

						else if (success == ESIG_BADCOMMAND)
							message_user("Error: Device is not ENACTOR (Cannot provide stimulus).")
						else
							message_user("Error: Unable to signal device.")

					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								var/duration = 1
								if (length(initlist) >= 2)
									duration = text2num_safe(initlist[2])
									if (isnum(duration))
										duration = round(duration)
										if (duration < 1 || duration > 255)
											duration = clamp(duration, 1, 255)
											message_user("Warning: Pulse duration out of bounds \[1 - 255]. Value clamped.")
									else
										duration = 1
										message_user("Warning: Non-numeric pulse duration! Argument ignored.")

								var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="pulse", "duration"=duration))
								if (success == ESIG_SUCCESS)
									message_user("OK")

								else if (success == ESIG_BADCOMMAND)
									message_user("Error: Device is not ENACTOR (Cannot provide stimulus).")
								else
									message_user("Error: Unable to signal device.")

								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			if ("activate", "deactivate", "sense")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)
						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"=command))
						if (success == ESIG_SUCCESS)
							message_user("OK")

						else if (success == ESIG_BADCOMMAND)
							message_user("Error: Device is not [(command == "sense") ? "SENSOR (Cannot measure stimulus)" : "ENACTOR (Cannot provide stimulus)."]")
						else
							message_user("Error: Unable to signal device.")

					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"=command))
								if (success == ESIG_SUCCESS)
									message_user("OK")

								else if (success == ESIG_BADCOMMAND)
									message_user("Error: Device is not [(command == "sense") ? "SENSOR (Cannot measure stimulus)" : "ENACTOR (Cannot provide stimulus)."]")
								else
									message_user("Error: Unable to signal device.")

								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			if ("read")
				if (initlist.len)
					var/driverID = ckey(initlist[1])
					if (driverID in testDrivers)
						var/targetID = testDrivers.Find(driverID)
						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="sense"))
						if (success == ESIG_SUCCESS && signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="read")) == ESIG_SUCCESS)
							message_user("Loading...")
							response_timeout = 2
							return

						else if (success == ESIG_BADCOMMAND)
							message_user("Error: Device is not SENSOR (Cannot measure stimulus)")
						else
							message_user("Error: Unable to signal device.")
					else
						var/findSuccess = 0
						for (var/x in testDrivers)
							if (driverID == ckey(testDrivers[x]))
								findSuccess = 1
								var/targetID = testDrivers.Find(x)

								var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="sense"))
								if (success == ESIG_SUCCESS && signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=targetID, "dcommand"="read")) == ESIG_SUCCESS)
									message_user("Loading...")
									response_timeout = 2
									return

								else if (success == ESIG_BADCOMMAND)
									message_user("Error: Device is not SENSOR (Cannot measure stimulus)")
								else
									message_user("Error: Unable to signal device.")

								break

						if (!findSuccess)
							message_user("Error: Unknown (Or Invalid) device network ID / Name.")

				else
					message_user("Error: No device network ID / name specified.")

			else
				message_user("Unknown command argument.")


		mainframe_prog_exit
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		if (data["command"] == DWAINE_COMMAND_REPLY)
			if (!data["data"])
				return ESIG_GENERIC

			switch (lowertext(data["format"]))
				if ("values") //Multiple read, formatted as comma separated list.
					var/formatted = "|-----------|Sensor Values:|-----------||n"
					var/list/valueList = splittext(data["data"], ",")
					if (valueList.len)
						for (var/x = 1, x <= valueList.len, x++)
							. = replacetext(valueList[x], "-", " ")
							formatted += "| \[[add_zero("[x]",4)]] | [.]|n"

					else
						formatted += " | NONE|n"

					formatted += "|--------------------------------------|"
					message_user("[formatted]", "multiline")

				if ("field")	//Single value from a peeked field. fieldname-fieldvalue
					var/list/splitData = splittext(data["data"], "-")
					if (length(splitData) < 2)
						return ESIG_GENERIC

					message_user("[splitData[1]]: \[[splitData[2]]]")


				if ("info")
					var/formatted = "+---------------|Status|---------------+|n"
					var/list/rawDataList = splittext(data["data"], ",")
					if (length(rawDataList) > 3)
						formatted += "| Active: [(rawDataList[1] == "1") ? "YES" : "NO"]|n| ID: [rawDataList[2]]|n| Enactor: [(rawDataList[3] == "1") ? "YES" : "NO"]|n| Sensor: [(rawDataList[4] == "1") ? "YES" : "NO"]|n+--------|Configuration Values|--------+|n"

						. = ""
						if (length(rawDataList) > 4)
							for (var/i = rawDataList.len, i > 4, i--)
								. = "| \[[add_zero("[i-4]",4)]] | [uppertext(rawDataList[i])]|n[.]"

							formatted += .

						else
							formatted += "| NONE|n"

					formatted += "|--------------------------------------|"
					message_user("[formatted]", "multiline")

				else
					message_user("[data["data"]]", "multiline")

			mainframe_prog_exit
			return ESIG_SUCCESS


		return ESIG_BADCOMMAND

//#define GRUMPY_DEBUG

#ifdef GRUMPY_DEBUG
#define DEBUG_OUT(x)	boutput(world, (x))
#else
#define DEBUG_OUT(x)	/* (x) */
#endif

#define MODE_BASE_MENU		0
#define MODE_DEVICE_INFO	1
#define MODE_DEVICE_READ	2
#define MODE_DEVICE_SUBREAD	3
#define MODE_DEVICE_ADJUST	4
#define MODE_DEVICE_SUBADJ	5

/datum/computer/file/mainframe_program/driver/artifact_console
	name = "artconsol"
	setup_processes = 1

	var/tmp/mode = MODE_BASE_MENU

	var/tmp/list/known_devices
	var/tmp/current_device_id = null
	var/tmp/list/current_device_known_fields
	var/tmp/current_field = null
	var/tmp/list/moreDisplayBuffer
	var/tmp/known_device_start_offset

	disposing()

		..()

	New()
		..()
		known_devices = list()
		known_device_start_offset = 0
		moreDisplayBuffer = list()
		current_device_known_fields = list()

	initialize()
		if (..())
			return 1

		SPAWN(1 SECOND)
			update_known_devices()


			message_device("command=message&title=Devices&blank=1&data=[get_main_menu()]")
/*
			. = ""
			var/initial_device_count = 1
			for (var/initial_device in known_devices)
				if (!initial_device)
					continue

				if (initial_device_count++ > 8)
					break

				. += "| [initial_device] | [known_devices[initial_device] ? "[known_devices[initial_device]]" : "INVALID"]|n"

			if (!.)
				. = "| NONE"

			message_device("command=message&data=[.]")
*/
	terminal_input(var/data, var/datum/computer/file/file)
		if (..() || !initialized)
			return

		var/list/datalist = params2list(data)
//		var/session = datalist["session"]
//		if (!session || !(session in sessions))
//			return

		switch (lowertext(datalist["command"]))
			if ("ack")
				//wip
				return

			if ("nack")
				//wip
				return

			if ("input")

				if (datalist["select"])
					//wip
					DEBUG_OUT("Select = [datalist["select"]]")
					if (mode == MODE_BASE_MENU)
						var/selectedLine = round(text2num_safe(datalist["select"]))
						if (!isnum(selectedLine) || selectedLine < 0 || selectedLine > 7)
							return

						if ((++selectedLine + known_device_start_offset) > known_devices.len)
							return

						if (selectedLine > 7 && (known_device_start_offset + 7) < known_devices.len)
							return

						current_device_id = known_devices[selectedLine + known_device_start_offset]
						if (!current_device_known_fields)
							current_device_known_fields = list()

						current_device_known_fields.len = 0
						DEBUG_OUT(current_device_id)
						message_device("command=highlight&line=[selectedLine-1]&state=1&mode=single")

					else if (mode == MODE_DEVICE_ADJUST || mode == MODE_DEVICE_SUBADJ)
						if (!current_device_id) //It's hard to adjust a device with no device.
							mode = MODE_BASE_MENU
							message_device("command=message&title=Devices&blank=1&data=[get_main_menu()]")
							return

						var/selectedLine = round(text2num_safe(datalist["select"]))
						if (!isnum(selectedLine) || selectedLine < 0 || selectedLine > 7)
							return

						if (++selectedLine > current_device_known_fields.len)
							return

						current_field = current_device_known_fields[selectedLine]
						message_device("command=highlight&line=[selectedLine-1]&state=1&mode=single")

					return

				else if (datalist["control"])
					//wip
					DEBUG_OUT("Control = [datalist["control"]]")
					. = text2num_safe(datalist["control"])
					switch (.)
						if (0) //Back
							switch (mode)
								if (MODE_DEVICE_READ, MODE_DEVICE_INFO, MODE_DEVICE_ADJUST)
									mode = MODE_BASE_MENU
									current_field = null
									//current_device_id = null

									message_device("command=message&title=Devices&blank=1&data=[get_main_menu()]")

								if (MODE_DEVICE_SUBREAD, MODE_DEVICE_SUBADJ)
									mode = MODE_DEVICE_INFO
									current_field = null
									show_info_menu()


						if (1, 2) //<--, -->
							//todo
							if (mode == MODE_BASE_MENU)
								if (. == 1)
									if (known_device_start_offset)
										known_device_start_offset = max(0, known_device_start_offset - 8)

										message_device("command=message&title=Devices&blank=1&data=[get_main_menu()]")
										return

								else
									if ((known_devices.len - 8) - known_device_start_offset > 0)
										known_device_start_offset += 7

										message_device("command=message&title=Devices&blank=1&data=[get_main_menu()]")
										return

								return


							else if ((mode == MODE_DEVICE_ADJUST || mode == MODE_DEVICE_SUBADJ) && current_field && current_device_id)
								var/valueToAdjust = text2num_safe( current_device_known_fields[current_field] )
								if (!isnum(valueToAdjust))
									return

								valueToAdjust = round(valueToAdjust)

								if (. == 1)
									if (valueToAdjust)
										valueToAdjust--
									else
										valueToAdjust = 999
								else
									if (valueToAdjust >= 999)
										valueToAdjust = 0
									else
										valueToAdjust++

								//Now we try to set that value on the actual device.
								var/driverID = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
								if (!(driverID & ESIG_DATABIT))
									return

								driverID &= ~ESIG_DATABIT

								signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driverID, "dcommand"="poke", "field"=current_field, "value"=valueToAdjust))
								SPAWN(0.5 SECONDS)
									signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driverID, "dcommand"="peek", "field"=current_field))

							return

						if (3) //Info
							show_info_menu()
							return

						if (4) //Read
							if (!current_device_id || !(current_device_id in known_devices))
								return

							var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
							if (!(driver_id & ESIG_DATABIT))
								return

							driver_id &= ~ESIG_DATABIT

							if (signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="sense")) == ESIG_SUCCESS)
								signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="read"))

							return

						if (5) //Pulse
							if (!current_device_id || !(current_device_id in known_devices))
								return

							var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
							if (!(driver_id & ESIG_DATABIT))
								return

							signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=(driver_id & ~ESIG_DATABIT), "dcommand"="pulse", "duration"=1))

							return

						if (6) //Adjust

							if (mode == MODE_DEVICE_ADJUST || mode == MODE_DEVICE_SUBADJ)
								return

							if (!current_device_id || !(current_device_id in known_devices))
								//message_device("command=message&data=[get_main_menu()]")
								return

							mode = (mode == MODE_BASE_MENU) ? MODE_DEVICE_ADJUST: MODE_DEVICE_SUBADJ

							var/driverID = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
							if (driverID & ESIG_DATABIT)
								driverID &= ~ESIG_DATABIT
							else
								driverID = 0

							if (!current_device_known_fields.len)
								signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driverID, "dcommand"="info"))
								return null

							. = ""
							for (var/value_entry in current_device_known_fields)
								. += "| [value_entry] IS [(current_device_known_fields[uppertext(value_entry)]) ? current_device_known_fields[uppertext(value_entry)] : "LOADING"]|n"

								if (driverID)
									signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driverID, "dcommand"="peek", "field"="[value_entry]"))

							if (.)
								message_device("command=message&title=Adjust Values&blank=1&data=[.]")
								return

							mode = MODE_BASE_MENU
							message_device("command=message&data=[get_main_menu()]")
							return null

					return


	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		if (data["command"] == DWAINE_COMMAND_REPLY)
			if (!data["data"])
				return ESIG_GENERIC

			switch (lowertext(data["format"]))
				if ("values") //Multiple read, formatted as comma separated list.
					var/formatted = ""//"|-----------|Sensor Values:|-----------||n"
					var/list/valueList = splittext(data["data"], ",")
					if (valueList.len)
						for (var/x = 1, x <= valueList.len, x++)
							. = replacetext(valueList[x], "-", " ")
							formatted += "| \[[add_zero("[x]",4)]] | [.]|n"

					else
						formatted += " | NONE|n"

					//formatted += "|--------------------------------------|"
					if (mode == MODE_BASE_MENU)
						mode = MODE_DEVICE_READ
					else
						mode = MODE_DEVICE_SUBREAD

					message_device("command=message&title=Sensor Values&blank=1&data=[formatted]")

				if ("field")
					DEBUG_OUT("Entering artconsole field handler with data \"[data["data"]]\"")
					var/separatorPosition = findtext(data["data"],"-")
					if (!separatorPosition)
						DEBUG_OUT("Unable to find separator in data.")
						return ESIG_GENERIC

					DEBUG_OUT("Separator found at position [separatorPosition].")
					var/fieldName = uppertext( copytext( data["data"], 1, separatorPosition ) )
					var/fieldValue = copytext(data["data"], separatorPosition+1, separatorPosition+65)
					if (!fieldName || !fieldValue)
						DEBUG_OUT("No fieldName or maybe no fieldValue.  One of the two.  Or both.")
						return ESIG_GENERIC

					DEBUG_OUT("fieldName found as \"[fieldName]\" and fieldValue found as \"[fieldValue]\"")
					if (current_device_id)
						DEBUG_OUT("current_device_id is [current_device_id]")
						current_device_known_fields[fieldName] = fieldValue

						if (mode == MODE_DEVICE_ADJUST || mode == MODE_DEVICE_SUBADJ)
							DEBUG_OUT("Attempting to update user menu . . .")
							var/lineToUpdate = current_device_known_fields.Find(fieldName)
							if (lineToUpdate && lineToUpdate < 8)
								DEBUG_OUT("Doing this thing . . .")
								message_device("command=message&line=[lineToUpdate-1]&data=| [fieldName] IS [fieldValue]")

				if ("info")
					var/formatted = ""//"+---------------|Status|---------------+|n"
					var/list/rawDataList = splittext(data["data"], ",")
					if (mode == MODE_DEVICE_INFO)
						if (length(rawDataList) > 3)
							formatted += "| Active: [(rawDataList[1] == "1") ? "YES" : "NO"]|n| ID: [rawDataList[2]]|n| Enactor: [(rawDataList[3] == "1") ? "YES" : "NO"]|n| Sensor: [(rawDataList[4] == "1") ? "YES" : "NO"]|n"


							if (current_device_known_fields)
								current_device_known_fields.len = 0

							else
								current_device_known_fields = list()

							. = ""
							if (length(rawDataList) > 4)
								if (length(rawDataList) > 7)
									formatted += "|------|Configuration Values (1/[(rawDataList.len-7)%3])|--------||n"
									moreDisplayBuffer.len = 0
									for (var/i = rawDataList.len, i > 7, i--)
										moreDisplayBuffer += "| \[[add_zero("[i-4],4")]] | [uppertext(rawDataList[i])]"

									rawDataList.len = 7
								else
									formatted += "|--------|Configuration Values|--------||n"

								for (var/i = rawDataList.len, i > 4, i--)
									. = "| \[[add_zero("[i-4]",4)]] | [uppertext(rawDataList[i])]|n[.]"

									if (cmptext(rawDataList[i], "none"))
										break

									current_device_known_fields += uppertext(rawDataList[i])

								formatted += .

							else
								formatted += "|--------|Configuration Values|--------||n| NONE|n"

						//formatted += "|--------------------------------------|"
						message_device("command=message&title=Status&blank=1&data=[formatted]")

					else if (mode == MODE_DEVICE_ADJUST || mode == MODE_DEVICE_SUBADJ)

						var/driverID
						if (current_device_id)
							driverID = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
							if (driverID & ESIG_DATABIT)
								driverID &= ~ESIG_DATABIT
							else
								driverID = 0


						if (length(rawDataList) > 4)
							for (var/i = rawDataList.len, i > 4, i--)
								if (cmptext(rawDataList[i], "none"))
									break

								. = uppertext(rawDataList[i])
								current_device_known_fields += .
								formatted += "| [.] IS LOADING|n"

								if (driverID)
									signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driverID, "dcommand"="peek", "field"="[.]"))

						if (formatted)
							message_device("command=message&title=Adjust Values&blank=1&data=[formatted]")
						else
							message_device("command=message&title=Adjust Values&blank=1&data=| NONE")


			//	else
			//		message_user("[data["data"]]", "multiline")

			return ESIG_SUCCESS


		return ESIG_BADCOMMAND


	proc/update_known_devices()
		var/list/potential_new_devices = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="test_appt", "mode"=0))
		if (!istype(potential_new_devices))
			return 1



		for (var/bad_entry_index = 1, bad_entry_index <= potential_new_devices.len, bad_entry_index++)
			if (!potential_new_devices[bad_entry_index])
				potential_new_devices.Cut(bad_entry_index,bad_entry_index+1)
				bad_entry_index--


		known_devices = potential_new_devices
		return 0

	proc/get_field_values()
		if (!current_device_id)
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
		if (!(driver_id & ESIG_DATABIT))
			return

		driver_id &= ~ESIG_DATABIT

		for (var/field in current_device_known_fields)
			signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="peek", "field"="[field]"))


	proc/get_main_menu()
		update_known_devices()

		. = ""
		if (known_device_start_offset >= known_devices.len)
			known_device_start_offset = 0

		var/offset = known_device_start_offset+1
		var/print_more_at_the_end = known_device_start_offset || (offset + 7 < known_devices.len)
		var/initial_device
		for (, offset <= known_devices.len && offset < known_device_start_offset + (8 + !print_more_at_the_end), offset++)
			initial_device = known_devices[offset]
			if (!initial_device)
				continue

			. += "| [initial_device] | [known_devices[initial_device] ? "[known_devices[initial_device]]" : "INVALID"]|n"

		if (!.)
			. = "| NONE"

		else if (print_more_at_the_end)
			if (known_device_start_offset)
				if (known_device_start_offset + 8 < known_devices.len)
					. += "| (FOR MORE, PRESS <- OR ->)"
				else
					. += "| (FOR MORE, PRESS <- )"
			else
				. += "| ( FOR MORE, PRESS -> )"

	proc/show_info_menu()
		if (!current_device_id || !(current_device_id in known_devices))
			message_device("command=message&blank=1&data=[get_main_menu()]")
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dnetid"=current_device_id))
		if (!(driver_id & ESIG_DATABIT))
			return

		mode = MODE_DEVICE_INFO
		signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id & ~ESIG_DATABIT, "dcommand"="info"))

/*
		var/list/testDrivers = signal_program(1, list("command"="dlist", "dtag"="test_appt", "mode"=0))
		if (!istype(testDrivers))
			return
*/

#undef MODE_BASE_MENU
#undef MODE_DEVICE_INFO
#undef MODE_DEVICE_READ
#undef MODE_DEVICE_SUBREAD
#undef MODE_DEVICE_ADJUST
#undef MODE_DEVICE_SUBADJ


#define REASON_NONE			0
#define REASON_FIELDS		1
#define REASON_HIGHLIGHT	2
#define REASON_ALERT		4
#define REASON_TITLE		8

//very WIP ok
/obj/machinery/networked/artifact_console
	name = "artifact research console"
	desc = "It just sorta showed up in a giant box of test equipment."
	density = 1
	anchored = ANCHORED
	device_tag = "PNET_ARTCONSOL"
	timeout = 10
	icon = 'icons/obj/networked.dmi'
	icon_state = "generic0"
	var/list/entries
	var/screen_title = "Devices"
	var/highlightMap = 0
	var/entryUpdateFlags = REASON_NONE
	var/displayingAlertFlag = 1
	var/list/deviceProfiles = list()

	New()
		..()
		if (prob(10))
			src.desc = "Giant mystery science doodad."

		entries = list("","","","","|cLoading...","","","")
		SPAWN(0.5 SECONDS)
			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

	power_change()
		if(powered())
			icon_state = "generic[src.host_id != null]"
		else
			SPAWN(rand(0, 15))
				icon_state = "generic-p"
				status |= NOPOWER

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN) || !src.link)
			return

		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE)
			return

		var/target = signal.data["sender"]

		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS)
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id, "net", "[net_number]")

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
				if(target == src.host_id)
					src.host_id = null
					src.entries[5] = "No Connection"
					src.updateUsrDialog(REASON_ALERT)
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				if(src.host_id)
					return

				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.host_id = target
				src.old_host_id = src.host_id
				if(signal.data["data"] != "noreply" && src.link)
					//src.post_status(target, "command","term_connect","data","noreply","device",src.device_tag)
					var/datum/signal/newsignal = get_free_signal()
					newsignal.source = src
					newsignal.transmission_method = TRANSMISSION_WIRE
					newsignal.data["command"] = "term_connect"
					newsignal.data["data"] = "noreply"
					newsignal.data["device"] = src.device_tag

					newsignal.data["address_1"] = target
					newsignal.data["sender"] = src.net_id

					src.link.post_signal(src, newsignal)


				return

			if("term_ping")
				if(target != src.host_id)
					return
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				return

			if("term_message","term_file")
				var/list/message_list = params2list(signal.data["data"])
				if (message_list)

					switch (lowertext(message_list["command"]))
						if ("alert")	//It wants us to display a single message in the center of the screen.
							src.entries[5] = copytext(message_list["msg"], 1, 65)
							src.highlightMap = 0

							if (message_list["title"])
								screen_title = copytext(message_list["title"], 15)
								src.updateUsrDialog(REASON_ALERT | REASON_TITLE)

							else
								src.updateUsrDialog(REASON_ALERT)

						if ("message")
							if (displayingAlertFlag)
								displayingAlertFlag = 0
								src.entries[5] = ""

							var/entryOffset = round(text2num_safe( message_list["line"] ))
							var/wipeRemainingLines = isnull(entryOffset) || (message_list["blank"] == "1")

							if (isnull(entryOffset) || entryOffset < 0 || entryOffset > 7)
								entryOffset = 0

							if (wipeRemainingLines)
								src.highlightMap = 0

							for (var/entryInfo in splittext(message_list["data"], "|n"))
								if (++entryOffset > src.entries.len)
									break

								if (dd_hasprefix(entryInfo, "|h1" ))
									src.entries[entryOffset] = copytext(entryInfo, 4, 69)
									src.highlightMap |= (1<<(entryOffset-1))

								else if (dd_hasprefix(entryInfo, "|h0"))
									src.entries[entryOffset] = copytext(entryInfo, 4, 69)
									src.highlightMap &= ~(1<<(entryOffset-1))

								else
									src.entries[entryOffset] = copytext(entryInfo, 1, 65)

							if (wipeRemainingLines)
								while (++entryOffset <= entries.len)
									entries[entryOffset] = ""
									src.highlightMap &= ~(1<<(entryOffset-1))

							if (message_list["title"])
								screen_title = copytext(message_list["title"], 1, 15)
								src.updateUsrDialog(REASON_FIELDS | REASON_HIGHLIGHT | REASON_TITLE)
							else
								src.updateUsrDialog(REASON_FIELDS|REASON_HIGHLIGHT)

						if ("highlight")
							var/lineToAdjust = round(text2num_safe( message_list["line"] ))
							if (isnull(lineToAdjust) || lineToAdjust < 0 || lineToAdjust > 7)
								return

							if (message_list["state"] == "1")
								if (message_list["mode"] == "single")
									src.highlightMap = (1<<lineToAdjust)
								else
									src.highlightMap |= (1<<lineToAdjust)
							else
								src.highlightMap &= ~(1<<lineToAdjust)

							src.updateUsrDialog(REASON_HIGHLIGHT)

						if ("title")
							if (message_list["title"])
								screen_title = copytext(message_list["title"], 1, 15)
								src.updateUsrDialog(REASON_TITLE)


				return

			if("term_disconnect")
				if(target == src.host_id)
					src.host_id = null
				src.timeout = initial(src.timeout)
				src.timeout_alert = 0
				src.updateUsrDialog(1)
				return

		return

	attack_hand(var/mob/user)
		if (..(user))
			return

		var/dat = {"<!DOCTYPE html>
<html>
<head>
<TITLE>Artifact Research Computer</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style type="text/css">
	body {background-color:#999876;}

	img {border-style: none;}

	a:link {text-decoration:none}

	#consolelog
	{
		border: 1px grey solid;
		height: 15em;
		width: 415px;
		position: absolute;
		left: 80px;
		overflow-y: hidden;
		overflow-x: hidden;
		word-wrap: break-word;
		background-color:#1B1E1B;
		color:#19A319;
		font-family: "Consolas", monospace;
		font-size: 18px;
	}

	.consolelog_entry
	{
		overflow-y: hidden;
		overflow-x: hidden;
		width: 411px;
		height: 1.5em;
		position: relative;
		left: 2px;
	}

	.modebutton
	{
		border: 1px black solid;
		background-color: #797856;
		width: 40px;
		height: 20px;
		position: absolute;
		left: 20px;
		display:block;
		text-align: center;
        color: #D0D0D0;
		font-size: small;
	}
</style>
</head>

<body scroll=no><br>


		<a id = 'button0' class='modebutton' style='top:64px;' href='byond://?src=\ref[src];button=0'></a>
		<a id = 'button1' class='modebutton' style='top:93px;' href='byond://?src=\ref[src];button=1'></a>
		<a id = 'button2' class='modebutton' style='top:122px;' href='byond://?src=\ref[src];button=2'></a>
		<a id = 'button3' class='modebutton' style='top:149px;' href='byond://?src=\ref[src];button=3'></a>
		<a id = 'button4' class='modebutton' style='top:178px;' href='byond://?src=\ref[src];button=4'></a>
		<a id = 'button5' class='modebutton' style='top:207px;' href='byond://?src=\ref[src];button=5'></a>
		<a id = 'button6' class='modebutton' style='top:236px;' href='byond://?src=\ref[src];button=6'></a>
		<a id = 'button7' class='modebutton' style='top:265px;' href='byond://?src=\ref[src];button=7'></a>

		<div id='consolelog'>
			<div id='header' class='consolelog_entry' style='width: 415px;'>|-----------|<font id='consoletitle'>[screen_title]</font><font style='position:absolute;left:275px;'>|-----------|</font></div>
			"}

		var/center_line = 0
		for (var/entryNum = 0, entryNum < 7, entryNum++)
			. = "[src.entries[entryNum + 1]]"

			center_line = 0
			while (copytext(., 1,2) == "|")
				if (cmptext(copytext(., 2, 3), "c"))
					center_line = 1

				else if (cmptext(copytext(., 2, 3), "h"))
					highlightMap |= (1<<entryNum)

				else
					break

				. = copytext(., 3)

			if (center_line)
				. = "<center>[.]</center>"


			dat += "<div id='entry[entryNum]' class='consolelog_entry'[(highlightMap & (1<<entryNum)) ? " style='color: #1B1E1B; background-color: #19A319'" : ""]>[.]</div>"


		dat += "<div id='entry7' class='consolelog_entry'>[src.entries[src.entries.len]]</div>"


		dat += {"
			<div id='footer' class='consolelog_entry' style='width: 415px;'>|--------------------------------------|</div>
		</div>

		<a id = 'button8' class='modebutton' style='left:515px; top:57px;' href='byond://?src=\ref[src];button=8'>BACK</a>

		<a id = 'button9' class='modebutton' style='left:515px; top:87px; font-size: large;' href='byond://?src=\ref[src];button=9'>&#8678;</a>

		<a id = 'buttonA' class='modebutton' style='left:515px; top:117px; font-size: large;' href='byond://?src=\ref[src];button=10'>&#8680;</a>

		<a id = 'buttonB' class='modebutton' style='left:515px; top:145px;' href='byond://?src=\ref[src];button=11'>INFO</a>

		<a id = 'buttonC' class='modebutton' style='left:515px; top:200px;' href='byond://?src=\ref[src];button=12'>READ</a>

		<a id = 'buttonD' class='modebutton' style='left:515px; top:228px;' href='byond://?src=\ref[src];button=13'>PULSE</a>

		<a id = 'buttonE' class='modebutton' style='left:515px; top:256px;' href='byond://?src=\ref[src];button=14'>ADJ</a>

		<a id = 'buttonR' class='modebutton' style='left:445px; top:320px; background-color:#C00000;' href='byond://?src=\ref[src];reset=2'>RESET</a>

		<script language="Javascript">
			function centerMessage(t)
			{
				var entryNum = 0
				for (; entryNum < 8; entryNum++)
				{
					document.getElementById("entry" + entryNum).innerHTML = "";
				}
				document.getElementById("entry3").innerHTML = "<center>" + t + "</center>";
			}

			function setEntry(num, t)
			{
				document.getElementById("entry" + num).innerHTML = t;
			}

			function bulkUpdate(updateArray)
			{
				var updateNum = 0;
				if (!updateArray)
				{
					return;
				}

				updateArray = updateArray.split("|n");

				for (; updateNum < updateArray.length && updateNum < 8; updateNum++)
				{
					document.getElementById("entry" + updateNum).innerHTML = updateArray\[updateNum];
				}
			}

			function setEntrySelected(num, selected)
			{
				var targetEntry = document.getElementById("entry" + num);
				if (selected != 0)
				{
					targetEntry.style.color = '#1B1E1B';
					targetEntry.style.backgroundColor = '#19A319';
				}
				else
				{
					targetEntry.style.color = '#19A319';
					targetEntry.style.backgroundColor = '#1B1E1B';
				}
			}

			function bulkSelect(num)
			{
				var bit = 0
				num = Number(num);
				if (isNaN(num) || num < 0 || num > 255)
				{
					return;
				}

				for (; bit < 8; bit++)
				{
					setEntrySelected(bit, ((1<<bit) & num));
				}
			}

			function setTitle(newTitle)
			{
				var theTitle = document.getElementById("consoletitle");
				if (!newTitle || !theTitle)
				{
					return;
				}

				newTitle = newTitle.substr(0, 14);
				theTitle.innerHTML = newTitle;

				return;
			}

			function clearDisplay()
			{
				var entryNum = 0;
				var entry;

				for (; entryNum < 8; entryNum++)
				{
					entry = document.getElementById("entry" + entryNum);
					entry.style.color = '#19A319';
					entry.style.backgroundColor = '#1B1E1B';
					entry.innerHTML = '';
				}
			}

		</script>

		</body>
</html>
"}

		src.add_dialog(user)
		user.Browse(dat, "window=art_computer;size=580x360;can_resize=0")
		onclose(user, "art_computer")
		return

	attackby(obj/item/W, mob/user)
		/*
		if (isscrewingtool(W))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			src.panel_open = !src.panel_open
			boutput(user, "You [src.panel_open ? "unscrew" : "secure"] the cover.")
			src.updateUsrDialog()
			return

		else
		*/
		return ..()


	Topic(href, href_list)
		if(..())
			return

		src.add_dialog(usr)

		if (href_list["button"])
			. = round(text2num_safe(href_list["button"]))
			if (. < 0)
				return

			if (. < 8)	//One of the line selection buttons (0-7).
				message_host("command=input&select=[.]")
				return

			else if (. < 15) //One of the control inputs (The right side of the panel)
				message_host("command=input&control=[. - 8]")

		else if (href_list["reset"])
			DEBUG_OUT(1)
			if ((host_id && href_list["reset"] != "2") || !old_host_id || !src.link)
				DEBUG_OUT(2)
				return

			if (href_list["reset"] == "2")
				DEBUG_OUT(3)
				host_id = null

			DEBUG_OUT(4)
			src.entries = list("","","","","|cReconnecting...","","","")
			src.highlightMap = 0
			displayingAlertFlag = 1
			src.updateUsrDialog(REASON_FIELDS|REASON_HIGHLIGHT)
			sleep(1 SECOND)

			DEBUG_OUT(5)
			src.last_reset = world.time
			var/old = src.host_id ? src.host_id : src.old_host_id
			src.host_id = null
			src.old_host_id = null

			src.post_status(old, "command","term_disconnect")
			sleep(0.5 SECONDS)
			DEBUG_OUT(6)
			src.post_status(old, "command", "term_connect", "device", src.device_tag)

			SPAWN(1 SECOND)
				if (!old_host_id)
					old_host_id = old


	updateUsrDialog(var/forceUpdate)
		DEBUG_OUT(":( [forceUpdate]")
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			DEBUG_OUT("[M]")
			if (M.using_dialog_of(src))
				DEBUG_OUT("[M]!!!")
				if (forceUpdate || entryUpdateFlags)
					DEBUG_OUT("[M] ! !  !")
					src.dynamicUpdate(M, forceUpdate|entryUpdateFlags)
					entryUpdateFlags = REASON_NONE
				else
					src.Attackhand(M)

		if (issilicon(usr))
			if (!(usr in nearby))
				if (usr.using_dialog_of(src))
					if (forceUpdate || entryUpdateFlags)
						src.dynamicUpdate(usr, forceUpdate|entryUpdateFlags)
						entryUpdateFlags = REASON_NONE
					else
						src.attack_ai(usr)


	proc/dynamicUpdate(mob/user as mob, updateReason)
		if (updateReason & REASON_ALERT)
			displayingAlertFlag = 1
			entries = list("","","","","[entries[5]]","","","")
			if (dd_hasprefix(entries[5], "|c"))
				DEBUG_OUT("blink")
				user << output(url_encode("<center>[copytext(entries[5],3)]</center>"), "art_computer.browser:centerMessage")

			else
				DEBUG_OUT("blunk")
				user << output(url_encode("[entries[5]]"), "art_computer.browser:centerMessage")

			if (updateReason & REASON_TITLE)
				user << output(url_encode(screen_title), "art_computer.browser:setTitle")

			return

		if (updateReason & REASON_FIELDS)
			. = ""
			for (var/entryNum = 1, entryNum < 9, entryNum++)
				if (isnull(entries[entryNum]))
					. = ""

				if (dd_hasprefix(entries[entryNum], "|c"))
					. += "<center>[copytext(entries[entryNum],3)]</center> |n"
				else
					. += "[entries[entryNum]] |n"

			DEBUG_OUT("blank \[[url_encode("[.]")]\]")
			user << output("[url_encode(.)]", "art_computer.browser:bulkUpdate")

		if (updateReason & REASON_HIGHLIGHT)
			DEBUG_OUT("blenk")
			user << output("[highlightMap]", "art_computer.browser:bulkSelect")

		if (updateReason & REASON_TITLE)
			user << output(url_encode(screen_title), "art_computer.browser:setTitle")


	proc/message_host(var/message, var/datum/computer/file/file)
		if (!src.host_id || !message)
			return

		if (file)
			src.post_file(src.host_id,"data",message, file)
		else
			src.post_status(src.host_id,"command","term_message","data",message)

		return

#undef REASON_NONE
#undef REASON_FIELDS
#undef REASON_HIGHLIGHT
#undef REASON_ALERT
#undef REASON_TITLE

/* Here is the current overview for this GPTIO thing. :words:
GPTIO - General Purpose Test-equipment Input/Output

Description:
	A standardized set of commands for interfacing between test equipment network devices and a generalized driver/command application pair.
	Communications take place over standard term_message interface layer.

	Devices may be a MASTER, ENACTOR, SENSOR, or both an ENACTOR and a SENSOR. Only the mainframe is allowed to function as the master and issue commands.

	Sensors may be either active or passive, passive sensors generating a result either from external stimulus or as part of an ongoing scan cycle, while
	active sensors perform a scan of some sort upon instruction.

	Enactors facilitate some sort of interaction with the tested artifact, i.e. a laser being emitted, a hammer hitting it, etc

	All test devices share the network device identifier of "PNET_TEST_APPT" and are differentiated by the contents of the "id" discriminator tag in their
	registration packet. (This is the Test Apparatus ID).

	Device type (Enactor, Sensor, Both) is to be stated in the Capability Field, with respective values 'E', 'S', and 'B'

GPTIO Commands:
(Device will acknowledge command with "ACK" or "NACK" unless otherwise specified)
COMMAND NAME		ARGS		DESCRIPTION
					GENERAL
	*INFO		NONE		Return test apparatus ID, valid configuration values, and Capability Field. No ACK
	*STATUS		NONE		Return activation state of device. No ACK
	*POKE		2			Set a configuration value on the device. Will NACK if field ID or value is invalid.
				Field		Name of field to set.
				Value		New value for field.
	*PEEK		1			Return value of configuration field. Will NACK if field ID is invalid.
				Field	Name of field to read.

					ENACTORS
	*ACTIVATE	NONE		Activate testing function of device, i.e. continuous firing of a laser, radar scan, etc. Will override any active pulse operation.
	*DEACTIVATE	NONE		Deactivate testing function of device. Will halt any active pulse operation.
	*PULSE		1			Activate for a certain period (Time unit is device specific, may be a certain number of activations)
				Duration	Activation period, as above. 1-255

					SENSORS - ACTIVE & PASSIVE
	*SENSE		NONE		The sensor equivalent of a single pulse. Both active and passive respond with ACKs, but only active perform a scan here.
	*READ		NONE		Returns most recent recorded sensor value, or NACK if there is none.

					DEVICE -> MASTER
	*ACK		NONE		Indicate success of previous command.
	*NACK		NONE		Indicate failure of previous command.
	*INFO		4			Response to INFO request from master.
				ID			Apparatus ID
				ValueList	List of configurable value fields, separated by '-'. Optional.
				Capability	Capability Field (E/S/B)
				Status		Activation status, 1 or 0
	*STATUS		1			Response to STATUS request from master.
				DATA		Activation status, 1 or 0.
	*PEEKED		1			Response to PEEK request from master.
				Value		Value of requested field.
*/
