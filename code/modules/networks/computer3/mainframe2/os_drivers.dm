//CONTENTS
//Base driver
//Base mountable device driver.
//Databank driver
//Filesystem mountpoint (To go with databank driver)
//Printer driver
//Nuclear charge driver (!!)
//User interface program for nuclear driver.
//Guardbot dock driver
//User interface program for dock driver.
//Radio module driver
//IR detector driver
//Remote APC driver
//HEPT emitter driver
//User interface program for HEPT emitter.
//Security monitor program for H7 mainframe.
//General purpose test apparatus driver & interface program
//Service terminal stuff!!
//A print helper program for service terminals
//Communication dish driver.  You know how incredibly important those are!!

/datum/computer/file/mainframe_program/driver
	name = "generic" //The driver is paired with devices with device tag "PNET_[driver name]" or just "[driver name]"
	size = 6
	extension = "DRV"
	executable = 0
	var/tmp/termtag = null //This is set to the term type of a driver upon initialization, because the name of an active driver is the net ID of its linked device
	var/setup_processes = 0 //This driver uses process() and is also open to relayed messages (via the OS)
	var/tmp/status = null //A simple status indicator used when the kernel lists drivers.

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if(!src.master || !setup_processes)
			return 1

		return 0

	asText()
		return "[termtag]-[status ? status : "OK"]"

	proc
		terminal_input(var/data, var/datum/computer/file/file)
			if(!data || !initialized)
				return 1
			return 0

		message_device(var/data, var/datum/computer/file/file)
			if (!initialized || (length(src.name) != 8))
				return ESIG_NOTARGET

			return signal_program(1, list("command"=DWAINE_COMMAND_MSG_TERM, "data" = data, "term" = src.name), file)

/datum/computer/file/mainframe_program/driver/mountable
	var/tmp/list/contents_mirror = list()
	var/tmp/list/to_remove = list()
	var/tmp/list/to_add = list()
	var/tmp/list/mountpoints = list()
	var/default_permission = COMP_ALLACC & ~(COMP_DOTHER|COMP_DGROUP)

	/* new disposing() pattern should handle this. -singh
	disposing()
		for (var/datum/computer/D in src.contents_mirror)
			D.holding_folder = null
			//qdel(D)
			D.dispose()

		for (var/i in src.to_add)
			var/datum/computer/D = to_add[i]
			if (D)
				D.holding_folder = null
				//qdel(D)
				D.dispose()

		for (var/i in src.to_remove)
			var/datum/computer/D = to_remove[i]
			if (D)
				D.holding_folder = null
				//qdel(D)
				D.dispose()

		..()
	*/

	disposing()
		for (var/datum/computer/D in src.contents_mirror)
			D.holding_folder = null
			//qdel(D)
			D.dispose()


		if (src.to_add)
			for (var/i in src.to_add)
				var/datum/computer/D = to_add[i]
				if (D)
					D.holding_folder = null
					//qdel(D)
					D.dispose()

			src.to_add.len = 0

		if (src.to_remove)
			for (var/i in src.to_remove)
				var/datum/computer/D = to_remove[i]
				if (D)
					D.holding_folder = null
					//qdel(D)
					D.dispose()

			src.to_remove.len = 0

		if (src.mountpoints)
			for (var/datum/computer/folder/mountpoint/MP in src.mountpoints)
				MP.driver = null
				MP.dispose()

			src.mountpoints.len = 0


		src.to_add = null
		src.to_remove = null
		src.mountpoints = null
		src.contents_mirror = null

		..()

	proc
		add_file(var/datum/computer/file/file)

		remove_file(var/datum/computer/file/file)

		change_metadata(var/datum/computer/file/file, var/field, var/newval)


/datum/computer/file/mainframe_program/driver/mountable/user_terminal
	name = "int_hui_terminal"
	setup_processes = 1

	initialize(var/initparams)
		if (..())
			return

		signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"="term"))
		return

	add_file(var/datum/computer/file/a_file, var/datum/mainframe2_user_data/user)
		if (!initialized || !istype(a_file) || !istype(user) || !user.user_id)
			return 0

		if (istype(a_file, /datum/computer/file/record))
			for (var/entry in a_file:fields)
				var/splitpoint = findtext(entry, "=")
				if (splitpoint)
					a_file:fields -= entry
					var/new_end = copytext(entry, splitpoint+1)
					entry = copytext(entry, 1, splitpoint)

					a_file:fields[entry] = new_end

		. = a_file.copy_file()
		a_file.dispose()

		return (signal_program(1, list("command"=DWAINE_COMMAND_MSG_TERM,"term"="[user.user_id]"), .) == ESIG_SUCCESS)


/datum/computer/file/mainframe_program/driver/mountable/databank
	name = "data_bank"
	var/tmp/bank_name = null
	var/tmp/list/to_adjust = list()
	var/tmp/lastOperationResponse = null

	initialize(var/initparams)
		if (..())
			return

		if (bank_name)
			signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"=lowertext(src.bank_name)))
		return

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))

			if ("register")
				if (!datalist["data"])
					return

				if (datalist["data"] != src.bank_name)
					src.bank_name = datalist["data"]
					signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"=lowertext(src.bank_name)))
					message_device("command=sync")

			if ("sync")
				if (istype(file, /datum/computer/file/archive))
					src.update_from_archive(file)

			if ("status")
				if (datalist["status"] == "notape")
					for (var/datum/computer/D in src.contents_mirror)
						D.holding_folder = null
						//qdel(D)
						D.dispose()

					lastOperationResponse = "notape"

					for (var/i in src.to_add)
						var/datum/computer/D = to_add[i]
						if (D)
							D.holding_folder = null
							//qdel(D)
							D.dispose()

					for (var/i in src.to_remove)
						var/datum/computer/D = to_remove[i]
						if (D)
							D.holding_folder = null
							//qdel(D)
							D.dispose()

					src.contents_mirror.len = 0
					src.to_add.len = 0
					src.to_remove.len = 0
					src.to_adjust.len = 0
					return

				var/sessionid = datalist["session"]
				if(isnull(sessionid))
					return

				if (sessionid in to_adjust)
					var/list/worklist = to_adjust[sessionid]
					if (istype(worklist) && worklist.len == 3 && datalist["status"] == "success")
						var/datum/computer/file/workfile = worklist[1]
						if (istype(workfile))
							var/newval = worklist[3]
							if (isnum(text2num_safe(newval)))
								newval = text2num_safe(newval)
							workfile.metadata["[worklist[2]]"] = newval

					to_adjust -= sessionid
					//qdel(worklist)
					worklist = null
					lastOperationResponse = datalist["status"]

				else if (sessionid in to_add)
					var/datum/computer/file/workfile = to_add[sessionid]
					if (!istype(workfile))
						to_add -= sessionid
						return

					if (datalist["status"] == "success")
						contents_mirror += workfile
						to_add -= sessionid
						workfile.holder = src.holder
					else
						//qdel(workfile)
						workfile.dispose()
						to_add -= sessionid

					lastOperationResponse = datalist["status"]
					return

				else if (sessionid in to_remove)
					var/datum/computer/file/workfile = to_remove[sessionid]
					if (!istype(workfile))
						to_remove -= sessionid
						return

					if (datalist["status"] == "success" || datalist["status"] == "nofile")
						//qdel(workfile)
						workfile.dispose()
						to_remove -= sessionid
						workfile.holder = null
						lastOperationResponse = "success"
					else
						src.contents_mirror += workfile
						to_remove -= sessionid
						lastOperationResponse = datalist["status"]


					return

				return

		return

	add_file(var/datum/computer/file/file) //Note: Folders are not (And really should not) be accepted.
		if (!initialized || !istype(file))
			return 0

		if (!(file in to_add) && !(file in contents_mirror))
			var/sessionid = "[world.timeofday%100][rand(0,9)]"
			to_add[sessionid] = file
			//file.holder = src.holder
			lastOperationResponse = null
			message_device("command=filestore&session=[sessionid]", file)
			sleep(0.5 SECONDS)

			return (lastOperationResponse == "success")

		return 0

	remove_file(var/datum/computer/file/file)
		if (!initialized || !file)
			return 0

		if ((file in contents_mirror) && !(file in to_remove))
			var/sessionid = "[world.timeofday%100][rand(0,9)]"
			to_remove[sessionid] = file
			contents_mirror -= file
			lastOperationResponse = null
			message_device("command=delfile&fname=[file.name]&session=[sessionid]")
			sleep(0.5 SECONDS)

			return (lastOperationResponse == "success")

		return 0


	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		if (!file || isnull(field))
			return 0

		var/list/checklist = src.contents_mirror + src.to_add + src.to_remove
		if (!(file in checklist))
			return 0

		var/sessionid = "[world.timeofday%100][rand(0,9)]"
		to_adjust[sessionid] = list(file, field, newval)
		lastOperationResponse = null
		message_device("command=modfile&fname=[file.name]&field=[field]&val=[newval]&session=[sessionid]")
		sleep(0.5 SECONDS)

		return (lastOperationResponse == "success")

	proc
		update_from_archive(var/datum/computer/file/archive/arc)
			//boutput(world, "update_from_archive for [src.name] with supplied \ref[arc]")
			if (!arc || !arc.contained_files)
				//boutput(world, "blug")
				return

			for(var/datum/computer/F in src.contents_mirror)
				//boutput(world, "Disposing of \ref[F]")
				F.holding_folder = null
				//qdel(F)
				F.dispose()

			src.contents_mirror.len = 0

			for (var/datum/computer/F in arc.contained_files)
				if (istype(F, /datum/computer/folder))
					//qdel(F)
					//boutput(world, "Disposing of folder \ref[F]")
					F.dispose()
					continue

				F.holder = src.holder
				F.holding_folder = src
				src.contents_mirror += F
				arc.contained_files -= F
				//boutput(world, "Scooting over \ref[F] [F?.disposed]")
				if (!F.metadata)
					F.metadata = list()

				if (isnull(F.metadata["permission"]))
					F.metadata["permission"] = default_permission

			return


/datum/computer/folder/mountpoint
	gen = 10

	var/datum/computer/file/mainframe_program/driver/mountable/driver = null

	New(var/datum/computer/file/mainframe_program/driver/mountable/newdriver)
		..()
		if (gen != 10) gen = 10
		if(istype(newdriver))
			//qdel(src.contents)
			src.contents = newdriver.contents_mirror
			src.driver = newdriver
			src.driver.mountpoints += /datum/computer/folder/mountpoint
		return

	/* new disposing() pattern should handle this. -singh
	disposing()
		src.contents = null
		src.driver = null
		..()
	*/

	disposing()
		src.contents = null
		if (src.driver && src.driver.mountpoints)
			src.driver.mountpoints -= src

		src.driver = null

		..()

	add_file(datum/computer/R, misc)
		if (!driver || driver.holder != src.holder)
			return 0

		R.holding_folder = driver
		return driver.add_file(R, misc)

	remove_file(datum/computer/R, misc)
		if(!driver || driver.holder != src.holder)
			return 0

		return driver.remove_file(R, misc)

/datum/computer/file/mainframe_program/driver/mountable/printer
	name = "printdevc"
	setup_processes = 1

	var/tmp/printer_name = null
	var/tmp/printer_wait = 0 //Time spent waiting for a printer response.
	var/tmp/list/to_print = list()
	var/tmp/datum/computer/file/record/statusfile = null

	var/setup_statusfile_name = "status"

	disposing()
		to_print = null
		statusfile = null

		..()

	initialize(var/initparams)
		if (..())
			return

		if (printer_name)
			signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"="lp-[lowertext(src.printer_name)]"))

		if (!statusfile)
			for (var/datum/computer/R in src.contents_mirror)
				if (R.name == setup_statusfile_name)
					if (istype(R, /datum/computer/file/record))
						statusfile = R
					return

			statusfile = new /datum/computer/file/record(  )
			statusfile.name = setup_statusfile_name
			statusfile.fields += "Status: OK"
			src.contents_mirror += statusfile

		return

	add_file(var/datum/computer/file/theFile)
		if (!initialized || !istype(theFile))
			return 0

		if (istype(theFile, /datum/computer/file/record) || !isnull(theFile.asText()))
			contents_mirror += theFile
			to_print += theFile
			return 1

		return 0

	remove_file(var/datum/computer/file/file)
		if (!initialized || !file)
			return 0

		if (file in contents_mirror)
			contents_mirror -= file
			to_print -= file
			return 1

		return 0

	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		return 0

	process()
		if (..() || !initialized || !length(to_print))
			return

		if (printer_wait)
			printer_wait--
			return

		printer_wait = 5
		var/datum/computer/file/record/printFile = to_print[1]
		if (istype(printFile) && printFile.fields)
			if (dd_hasprefix(printFile.fields[1], "title="))
				var/title = copytext(printFile.fields[1], 7)
				printFile.fields.Cut(1,2)
				message_device("command=print&title=[title]", printFile)
				return
			else
				message_device("command=print", printFile)
				return

		else if (istype(printFile, /datum/computer/file) && printFile.asText() != null)
			var/datum/computer/file/oldPrintFile = printFile
			printFile = new /datum/computer/file/record( )
			contents_mirror -= oldPrintFile
			to_print -= oldPrintFile

			contents_mirror += printFile
			to_print.Insert(1, printFile)

			printFile.fields = splittext(oldPrintFile.asText(), "|n")
			oldPrintFile.dispose()

			message_device("command=print", printFile)
			return

		message_device("command=print", to_print[1])
		return

	terminal_input(var/data, var/datum/computer/file/file)
		if (..() || !initialized)
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))

			if ("register")
				if (!datalist["data"])
					return

				if (datalist["data"] != src.printer_name)
					src.printer_name = datalist["data"]
					signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, link="lp-[lowertext(src.printer_name)]"))

			if ("status")
				var/status = lowertext(datalist["status"])
				switch(status)
					if ("success", "badfile", "lowpaper")
						if (!printer_wait)
							return

						if (status == "badfile")
							update_status("Invalid file sent.")
						else if (status == "lowpaper")
							update_status("Low paper.")
						else
							update_status("OK")

						var/datum/computer/file/F = to_print[1]
						src.contents_mirror -= F
						to_print.Cut(1,2)
						//qdel(F)
						F.dispose()
						printer_wait = 0

					if ("busy")
						update_status("Busy")
						printer_wait = 10
						return

					if ("bufferfull")
						update_status("Printbuffer is full!")
						printer_wait = 10
						return

					if ("nopaper")
						update_status("Out of paper.")
						to_print.len = 0
						for (var/datum/computer/file/F in src.contents_mirror)
							if (F == src.statusfile)
								continue
							//qdel(F)
							F.dispose()

						src.contents_mirror.len = 1
						printer_wait = 0
						return

					if ("jam")
						update_status("Mechanism jam.")
						to_print.len = 0
						for (var/datum/computer/file/F in src.contents_mirror)
							if (F == src.statusfile)
								continue
							//qdel(F)
							F.dispose()

						src.contents_mirror.len = 1
						printer_wait = 0
						return

					if ("thermalert")
						update_status("Lineprinter on fire.")
						to_print.len = 0
						for (var/datum/computer/file/F in src.contents_mirror)
							if (F == src.statusfile)
								continue
							//qdel(F)
							F.dispose()

						src.contents_mirror.len = 1
						printer_wait = 0
						return

				return

		return

	proc/update_status(var/newstatus)
		if (!newstatus)
			return

		if (!statusfile)
			for (var/datum/computer/R in src.contents_mirror)
				if (R.name == setup_statusfile_name)
					if (istype(R, /datum/computer/file/record))
						statusfile = R
					else
						return

			statusfile = new /datum/computer/file/record(  )
			statusfile.name = setup_statusfile_name
			src.contents_mirror += statusfile

		statusfile.fields.len = 0
		statusfile.fields += "Status: [newstatus]"
		return

//telescience driver
/datum/computer/file/mainframe_program/driver/telepad
	name = "s_telepad"
	setup_processes = 1
	var/list/sessions = list()

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (lowertext(data["command"]))
			if ("set_coords")
				var/new_x = text2num_safe(data["x"])
				if (!isnum(new_x))
					return ESIG_USR1
				new_x = round(new_x, 0.01)

				var/new_y = text2num_safe(data["y"])
				if (!isnum(new_y))
					return ESIG_USR1
				new_y = round(new_y, 0.01)

				var/new_z = text2num_safe(data["z"])
				if (!isnum(new_z))
					return ESIG_USR1
				new_z = round(new_z, 0.01)

				var/datum/computer/file/coords/new_coords = new /datum/computer/file/coords
				new_coords.destx = (new_x * XMULTIPLY) - XSUBTRACT
				new_coords.desty = (new_y * YMULTIPLY) - YSUBTRACT
				new_coords.destz = new_z - ZSUBTRACT
//				boutput(world, "[XMULTIPLY] [XSUBTRACT]  [YMULTIPLY] [YSUBTRACT]  [ZSUBTRACT]")

				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				sessions[sessionid] = ESIG_USR1

				message_device("command=set_coords&session=[sessionid]", new_coords)
				sleep(0.6 SECONDS)
				. = sessions[sessionid]
				sessions -= sessionid
				return .

			if ("relay") //sshh
				var/source_x = text2num_safe(data["x1"])
				if (!isnum(source_x))
					return ESIG_USR1
				source_x = round(source_x, 0.01)

				var/source_y = text2num_safe(data["y1"])
				if (!isnum(source_y))
					return ESIG_USR1
				source_y = round(source_y, 0.01)

				var/source_z = text2num_safe(data["z1"])
				if (!isnum(source_z))
					return ESIG_USR1
				source_z = round(source_z, 0.01)

				var/dest_x = text2num_safe(data["x2"])
				if (!isnum(dest_x))
					return ESIG_USR1
				dest_x = round(dest_x, 0.01)

				var/dest_y = text2num_safe(data["y2"])
				if (!isnum(dest_y))
					return ESIG_USR1
				dest_y = round(dest_y, 0.01)

				var/dest_z = text2num_safe(data["z2"])
				if (!isnum(dest_z))
					return ESIG_USR1
				dest_z = round(dest_z, 0.01)

				var/datum/computer/file/coords/new_coords = new /datum/computer/file/coords
				new_coords.destx = (dest_x * XMULTIPLY) - XSUBTRACT
				new_coords.desty = (dest_y * YMULTIPLY) - YSUBTRACT
				new_coords.destz = dest_z - ZSUBTRACT

				new_coords.origx = (source_x * XMULTIPLY) - XSUBTRACT
				new_coords.origy = (source_y * YMULTIPLY) - YSUBTRACT
				new_coords.origz = source_z - ZSUBTRACT

				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				sessions[sessionid] = ESIG_USR1

				message_device("command=relay&session=[sessionid]", new_coords)

			if ("send", "receive", "portal", "scan")
				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				sessions[sessionid] = ESIG_USR1
				message_device("command=[lowertext(data["command"])]&session=[sessionid]")
				sleep(0.6 SECONDS)
				. = sessions[sessionid]
				sessions -= sessionid
				return .

			else
				return ESIG_BADCOMMAND

	terminal_input(var/data, var/datum/computer/file/file)
		if (..() || !initialized)
			return

		var/list/datalist = params2list(data)
		var/session = datalist["session"]
		if (!session || !(session in sessions))
			return

		switch(lowertext(datalist["command"]))
			if ("ack")
				sessions[session] = ESIG_SUCCESS

			if ("nack")
				switch ( lowertext(datalist["cause"]) )
					if ("interference")
						sessions[session] = ESIG_USR2
					if ("badxyz","badx","bady","badz","badxy","badxz","badyz")
						//sessions[session] = ESIG_USR3
						sessions[session] = copytext(uppertext(datalist["cause"]), 4)
					if ("recharge")
						sessions[session] = ESIG_USR4

			if ("scan_reply")
				if (datalist["cause"] == "noatmos")
					sessions[session] = ESIG_USR2
				else
					datalist -= "command"
					datalist -= "session"
					sessions[session] = datalist

				return

/datum/computer/file/mainframe_program/srv/telecontrol
	name = "teleman"
	size = 1

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			message_user("Invalid commmand argument.|nValid Commands:|n (Coords) to set target coordinates. Specify x y z.|n (Send) to send to target.|n (Receive) to receive from target.|n (Portal) to open bidirectional portal to target.|n (Scan) to scan target atmosphere.","multiline")
			mainframe_prog_exit
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="s_telepad"))
		if (!(driver_id & ESIG_DATABIT))
			message_user("Error: Could not detect driver.")
			mainframe_prog_exit
			return

		driver_id &= ~ESIG_DATABIT
		var/command = lowertext(initlist[1])
		if (cmptext(command, "-p") && initlist.len > 2)
			. = text2num_safe(initlist[2])
			if (isnum(.))
				. = clamp(round(.), 0, 64)
				var/list/possibleDrivers = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="s_telepad"))
				if (istype(possibleDrivers))
					for (var/x = 1, x <= possibleDrivers.len, x++)
						if (possibleDrivers[x])
							if (--. < 1)
								driver_id = x
								break

			initlist.Cut(1, 3)
			command = lowertext(initlist[1])

		switch (command)
			if ("coords")
				if (initlist.len >= 4)
					var/new_x
					var/new_y
					var/new_z
					var/state = 0
					for (var/i = 2, i <= initlist.len, i++)
						switch (copytext(initlist[i], 1, 2))
							if ("x","X")
								var/equalsPoint = findtext(initlist[i], "=", 2)
								if (equalsPoint)
									new_x = text2num_safe(copytext(initlist[i], equalsPoint+1))
									if (!isnum(new_x))
										state = 1
										continue
								else
									state = 1
									continue

							if ("y","Y")
								var/equalsPoint = findtext(initlist[i], "=", 2)
								if (equalsPoint)
									new_y = text2num_safe(copytext(initlist[i], equalsPoint+1))
									if (!isnum(new_y))
										state = 2
										continue
								else
									state = 2
									continue

							if ("z","Z")
								var/equalsPoint = findtext(initlist[i], "=", 2)
								if (equalsPoint)
									new_z = text2num_safe(copytext(initlist[i], equalsPoint+1))
									if (!isnum(new_z))
										state = 3
										continue
								else
									state = 3
									continue

							if ("=")
								continue

							else
								var/numIn = text2num_safe(initlist[i])
								if (isnum(numIn))
									switch (state)
										if (0)
											if (!isnum(new_x))
												new_x = numIn

											else if (!isnum(new_y))
												new_y = numIn

											else if (!isnum(new_z))
												new_z = numIn

											continue

										if (1)
											new_x = numIn
											state = 0

										if (2)
											new_y = numIn
											state = 0

										if (3)
											new_z = numIn
											state = 0

					if (!isnum(new_x) || !isnum(new_y) || !isnum(new_z))
						message_user("Invalid[!isnum(new_x) ? " x" : null][!isnum(new_y) ? " y" : null][!isnum(new_z) ? " z" : null]")
					else
						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="set_coords", "x"=new_x, "y"=new_y, "z"=new_z))
						switch (success)
							if (ESIG_SUCCESS)
								message_user("OK")
							//if (ESIG_USR3)
							//	message_user("Invalid coordinates.")
							else
								if (istext(success))
									message_user("Invalid coordinates ([success])")
								else
									message_user("OK")

				else
					message_user("Insufficient arguments (Need x y z).")

			if ("relay")
				if (initlist.len >= 4)
					var/start_x
					var/start_y
					var/start_z

					var/end_x
					var/end_y
					var/end_z

					var/state = 0

					for (var/i = 2, i <= initlist.len, i++)
						var/numIn = text2num_safe(initlist[i])
						if (isnum(numIn))
							switch (state++)
								if (0)
									start_x = numIn

								if (1)
									start_y = numIn

								if (2)
									start_z = numIn

								if (3)
									end_x = numIn

								if (4)
									end_y = numIn

								if (5)
									end_z = numIn

								else
									break


					if (!isnum(start_x) || !isnum(start_y) || !isnum(start_z)  ||  !isnum(end_x) || !isnum(end_y) || !isnum(end_z))
						message_user("Invalid[!isnum(start_x) ? " x1" : null][!isnum(start_y) ? " y1" : null][!isnum(start_z) ? " z1" : null][!isnum(end_x) ? " x2" : null][!isnum(end_y) ? " y2" : null][!isnum(end_z) ? " z2" : null]")
					else
						var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="relay", "x1"=start_x, "y1"=start_y, "z1"=start_z, "x2" = end_x, "y2" = end_y, "z2" = end_z))
						switch (success)
							if (ESIG_SUCCESS)
								message_user("OK")
							//if (ESIG_USR3)
							//	message_user("Invalid coordinates.")
							else
								if (istext(success))
									message_user("Invalid coordinates ([success])")
								else
									message_user("Unable to interface with telepad.")

				else
					message_user("Insufficient arguments (Need x1 y1 z1, x2 y2 z2).")

			if ("send", "receive", "portal")
				var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"=command))
				switch (success)
					if (ESIG_SUCCESS)
						message_user("OK")
					if (ESIG_USR2)
						message_user("Teleportation prevented by interference.")
					//if (ESIG_USR3)
					//	message_user("Invalid coordinates.")
					if (ESIG_USR4)
						message_user("Telepad is recharging.")

					else
						if (istext(success))
							message_user("Invalid coordinates ([success])")
						else
							message_user("Unable to interface with telepad.")

			if ("scan")
				var/list/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="scan"))
				if (istype(success))
					#define _TELESCI_ATMOS_SCAN(GAS, _, NAME, ...) "[NAME]: [success[#GAS]], " +
					message_user("Scan Results:|nAtmosphere: [APPLY_TO_GASES(_TELESCI_ATMOS_SCAN) " "][success["temp"]] Kelvin, [success["pressure"]] kPa, [(success["burning"])?("BURNING"):(null)]","multiline")
					// undefined at the end of the file because of https://secure.byond.com/forum/post/2072419

				else if (istext(success))
					message_user("Invalid coordinates ([success])")

				else
					message_user("No atmosphere.")

			else
				message_user("Unknown command argument.")

		mainframe_prog_exit
		return

//Nuclear detonator driver.
/datum/computer/file/mainframe_program/driver/nuke
	name = "nuccharge"
	setup_processes = 1

	var/tmp/synctimer = 0
	var/tmp/nuke_time = 0
	var/tmp/nuke_active = 0
	var/tmp/list/sessions = list()
	var/tmp/list/sessiondata = list()
	var/tmp/list/auths = list()

	var/setup_sync_time = 20
	var/setup_auth_access = access_dwaine_superuser
	var/setup_auths_needed = 3

	var/const/SESSION_TIMER = 1
	var/const/SESSION_ARM = 2
	var/const/SESSION_DISARM = 3

	initialize(var/initparams)
		if (..())
			return

		synctimer = 1
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (lowertext(data["command"]))
			if ("report_status")
				synctimer = 1
				return list(nuke_time, nuke_active, auths.len, setup_auths_needed)

			if ("auth")
				if (auths.len >= setup_auths_needed)
					return ESIG_USR2

				var/datum/computer/file/record/usdat = file
				if (!istype(usdat) || !usdat.fields["registered"] || !usdat.fields["assignment"])
					return ESIG_GENERIC

				var/list/accessList = splittext(usdat.fields["access"], ";")
				if (!("[setup_auth_access]" in accessList))
					return ESIG_NOUSR

				var/userhash = md5("[usdat.fields["registered"]]+[usdat.fields["assignment"]]")
				if (!userhash)
					return ESIG_NOUSR

				if (userhash in auths)
					return ESIG_USR3
				else
					auths += userhash
					if (auths.len >= setup_auths_needed)
						return ESIG_USR2
					else
						return ESIG_USR1

			if ("deauth")
				var/datum/computer/file/record/usdat = file
				if (!istype(usdat))
					return ESIG_NOUSR

				var/list/accessList = splittext(usdat.fields["access"], ";")
				if (!("[setup_auth_access]" in accessList))
					return ESIG_NOUSR

				src.auths.len = 0
				return ESIG_SUCCESS

			if ("settime")
				if (nuke_active)
					return ESIG_USR1

				if (!isnum(data["time"]))
					return ESIG_GENERIC

				var/newtime = clamp(data["time"], MIN_NUKE_TIME, MAX_NUKE_TIME)

				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				message_device("command=settime&time=[newtime]&session=[sessionid]")
				sessions[sessionid] = SESSION_TIMER
				sessiondata[sessionid] = newtime
				return ESIG_SUCCESS

			if ("arm")
				if (auths.len < setup_auths_needed)
					return ESIG_USR1

				if (nuke_active)
					return ESIG_USR2

				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				message_device("command=act&auth=[netpass_heads]&session=[sessionid]")
				sessions[sessionid] = SESSION_ARM
				return ESIG_SUCCESS

			if ("disarm")
				if (auths.len < setup_auths_needed)
					return ESIG_USR1

				if (!nuke_active)
					return ESIG_USR2

				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				message_device("command=deact&auth=[netpass_heads]&session=[sessionid]")
				sessions[sessionid] = SESSION_DISARM
				return ESIG_SUCCESS

		return ESIG_GENERIC

	process()
		if (..())
			return

		if (nuke_active)
			if (synctimer)
				synctimer--
				if (!synctimer)
					synctimer = setup_sync_time
					message_device("command=status")

			if (nuke_time > 0) //Try to follow along for the viewers at home!
				nuke_time -= (nuke_time <= 10 ? 1 : 3)

		return

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				sessions["[sessionid]"] = "stat"
				message_device("command=status&session=[sessionid]")

				return

			if ("n_status")
				var/stat_time = text2num_safe(datalist["timeleft"])
				if (!isnum(stat_time))
					return

				src.nuke_time = clamp(stat_time, 0, 512)

				src.nuke_active = (datalist["active"] == "1")

				return

			if ("status")
				var/session = datalist["session"]
				if (!session || isnull(sessions[session]))
					return

				switch(lowertext(datalist["status"]))
					if ("failure", "noparam", "badauth")
						sessions -= session
						sessiondata -= session
					if ("success")
						switch(sessions[session])
							if (SESSION_TIMER)
								nuke_time = sessiondata[session]

							if (SESSION_ARM)
								nuke_active = 1

							if (SESSION_DISARM)
								nuke_active = 0

						sessions -= session
						sessiondata -= session

				return

		return

/datum/computer/file/mainframe_program/nuke_interface
	name = "nukeman" //Nuke Manager, I guess
	size = 4
	var/tmp/authmode = 0

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			message_user("Invalid commmand argument.|nValid Commands:|n (Status) for detonator status.|n (Auth) to authorize detonation.|n (Deauth) to revoke authorizations.|n (Time) to set charge timer.|n (Activate) to activate detonation sequence|n (Abort) to halt activation sequence.","multiline")
			mainframe_prog_exit
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="nuccharge"))
		if (!(driver_id & ESIG_DATABIT))
			message_user("Error: Could not detect charge driver.")
			mainframe_prog_exit
			return

		driver_id &= ~ESIG_DATABIT
		var/command = lowertext(initlist[1])
		switch(command)
			if ("status", "stat")
				var/list/nuke_status = signal_program(1, list("command"=DWAINE_COMMAND_DMSG, "target"=driver_id, "dcommand"="report_status"))
				if (istype(nuke_status) && (nuke_status.len >= 4))
					message_user("Detonator Status:|n ACTIVE: [(nuke_status[2] == 1) ? "YES" : "NO"]|n TIMER: [nuke_status[1]] second(s)|n AUTHS: ([nuke_status[3]]/[nuke_status[4]])","multiline")
				else
					message_user("Error: Could not associate with charge driver.")

			if ("authorize", "auth")
				authmode = 0
				message_user("Please enter *authorized* card and \"term_login\"")
				return

			if ("deauthorize", "deauth")
				authmode = 1
				message_user("Please enter *authorized* card and \"term_login\"")
				return

			if ("activate", "n_act")
				var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="arm"))
				switch(success)
					if (ESIG_SUCCESS)

						var/logUser = "unknown user!"
						var/obj/callobj = null
						if (istype(src.useracc) && src.useracc.user_id)
							callobj = locate("\[0x[copytext(src.useracc.user_id,2)]]") in world

						var/obj/machinery/calling_term = null
						if(istype(callobj.loc, /obj/machinery/computer3))
							calling_term = callobj.loc
						if(istype(calling_term))
							if(usr)
								logUser = usr
							else
								logUser = "Terminal \[[src.useracc.user_id]]"

						message_admins("NUKE: Research Sector nuclear charge activated by [key_name(logUser)].")
						logTheThing(LOG_COMBAT, logUser, "Activated the Research Sector nuclear charge.")

						message_user("!Transmitting Activation Code!")
					if (ESIG_USR1)
						message_user("Error: Insufficient Authorizations.")
					if (ESIG_USR2)
						message_user("Error: Charge already active.")
					else
						message_user("Error: Could not associate with charge driver.")

			if ("abort", "deactivate", "disarm", "n_dis")
				var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="disarm"))
				switch(success)
					if (ESIG_SUCCESS)
						message_user("Transmitting Deactivation Code...")
					if (ESIG_USR1)
						message_user("Error: Insufficient Authorizations.")
					if (ESIG_USR2)
						message_user("Error: Charge not active.")
					else
						message_user("Error: Could not associate with charge driver.")

			if ("about")
				message_user("Device driver for Wildfire MkVII Tactical Atomic Munitions. Version 3.009a.|nCopyright 2052 Thinktronic Data Systems.","multiline")

			if ("time")
				if (initlist.len >= 2)
					var/newtime = text2num_safe(initlist[2])
					if (isnum(newtime) && (newtime <= MAX_NUKE_TIME) && (newtime >= MIN_NUKE_TIME))
						var/success = signal_program( 1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="settime","time"=newtime))
						switch(success)
							if (ESIG_SUCCESS)
								message_user("New time set.")
							if (ESIG_USR1)
								message_user("Error: Could not set time: Charge currently active.")
							else
								message_user("Error: Could not associate with charge driver.")

					else
						message_user("Error: Invalid time argument supplied (Must be between [MIN_NUKE_TIME] and [MAX_NUKE_TIME]).")
				else
					message_user("Error: No time argument supplied (Must be between [MIN_NUKE_TIME] and [MAX_NUKE_TIME]).")


			else
				message_user("Unknown command argument.")

		mainframe_prog_exit
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..() || (data["command"] != DWAINE_COMMAND_RECVFILE) || !istype(file, /datum/computer/file/record))
			return ESIG_GENERIC

		if (!src.useracc)
			return ESIG_NOUSR

		var/datum/computer/file/record/usdat = file
		if (!usdat.fields["registered"] || !usdat.fields["assignment"])
			return ESIG_GENERIC

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="nuccharge"))
		if (driver_id & ESIG_DATABIT)
			driver_id &= ~ESIG_DATABIT
			var/result_msg = "Error communicating with charge driver."
			if (authmode)
				var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="deauth"), file)
				switch(success)
					if (ESIG_SUCCESS)
						result_msg = "All authorizations have been revoked."
					if (ESIG_NOUSR)
						result_msg = "Error: Insufficient credentials."

			else
				var/success = signal_program(1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="auth"), file)
				switch(success)
					if (ESIG_USR1)
						result_msg = "User authorized."
					if (ESIG_USR2)
						result_msg = "!All authorizations acquired!"
					if (ESIG_USR3)
						result_msg = "User already authorized."
					if (ESIG_NOUSR)
						result_msg = "Error: Insufficient credentials."

			message_user(result_msg)

		else
			message_user("Error: Could not associate with charge driver.")

		mainframe_prog_exit
		return

	input_text(var/text) //We're only going to see this if they are at a login prompt and type something else. Assumedly that is because they want to exit (Or had a typo)
		mainframe_prog_exit
		return


/datum/computer/file/mainframe_program/driver/mountable/guard_dock
	name = "pr6_charg"
	setup_processes = 1

	var/tmp/bot_id = null
	var/tmp/bot_taskid = "NONE"
	var/tmp/bot_toolid = "NONE"
	var/tmp/bot_taskid_default = "NONE"
	var/tmp/bot_charge = "nocell"
	var/tmp/last_sync = 0
	var/tmp/datum/computer/file/record/statusfile = null

	var/setup_statusfile_name = "status"


	initialize(var/initparams)
		if (..())
			return

		signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name))
		if (!statusfile)
			for (var/datum/computer/R in src.contents_mirror)
				if (R.name == setup_statusfile_name)
					if (istype(R, /datum/computer/file/record))
						statusfile = R
					return

			statusfile = new /datum/computer/file/record(  )
			statusfile.name = setup_statusfile_name
			statusfile.metadata["permission"] = COMP_ROTHER
			src.contents_mirror += statusfile

		return

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				var/checkstatus = datalist["status"]
				if ( (length(checkstatus) == 8) && (is_hex(checkstatus)) )
					src.bot_id = checkstatus
					message_device("command=status") //Inquire as to the status of the connected guardbot.
				else
					src.clear_bot()

				last_sync = world.timeofday

			if ("reply")
				last_sync = world.timeofday
				if (datalist["status"] == "nobot")
					src.clear_bot()
					return

				else if (src.bot_id && datalist["status"] != src.bot_id)
					return

				src.bot_id = datalist["status"]
				src.bot_taskid = (datalist["curtask"] ? datalist["curtask"] : "NONE")
				src.bot_taskid_default = (datalist["deftask"] ? datalist["deftask"] : "NONE")
				src.bot_toolid = (datalist["tool"] ? datalist["tool"] : "NONE")
				src.bot_charge = (datalist["charge"] ? datalist["charge"] : "nocell")
				src.update_status()

				return

			if ("trep")
				last_sync = world.timeofday

				src.bot_taskid = (datalist["curtask"] ? datalist["curtask"] : "NONE")
				src.bot_taskid_default = (datalist["deftask"] ? datalist["deftask"] : "NONE")
				src.update_status()
				return

			if ("status")
				switch(lowertext(datalist["status"]))
					if ("nobot", "ejected")
						src.clear_bot()
						return

					if ("connect", "upload_success")
						message_device("command=status")
						return

					if ("wipe_success")
						src.bot_taskid = "NONE"
						src.bot_taskid_default = "NONE"
						src.update_status()
						return

					if ("badtask")
						//to-do
						return

				return


		return

	proc
		clear_bot()
			src.bot_id = null
			src.bot_taskid = "NONE"
			src.bot_toolid = "NONE"
			src.bot_taskid_default = "NONE"
			src.bot_charge = "nocell"
			src.update_status()
			return

		parse_record(var/datum/computer/file/record/rec)
			if (!rec)
				return 0

			if (lowertext(rec.name) == "command") //This is some sort of driver command from the user.
				//The intention here is to reformat a user provided record list of form ("command=whatever","data=whatever2")
				//to the an associated list i.e. ("command"="whatever","data"="whatever2")
				var/list/parsedFields = list()
				for (var/field in rec.fields)
					. = findtext(field, "=")
					if (.)
						parsedFields[ copytext(field, 1, .) ] = copytext(field, .+1)

				if (!parsedFields.len)
					return 1

				switch(lowertext(parsedFields["command"]))
					if ("status")
						message_device("command=status")

					if ("wake")
						if (src.bot_id)
							message_device("command=eject")

					if ("wipe")
						if (src.bot_id)
							message_device("command=wipe")

					if ("download")
						if (src.bot_id)
							message_device("command=download")

					if ("upload")//See if it's a set of parameters to bundle with a guardbot task. If so, send the configured task.
						if (src.bot_id)//Oh and um the target guardbot task should be placed in the device folder first (By the user)
							var/datum/computer/file/guardbot_task/locatedTask = null
							var/locatedName = lowertext(parsedFields["fname"])
							if (!locatedName)
								return 1

							for (var/datum/computer/R in src.contents_mirror)
								if (lowertext(R.name) == locatedName)
									locatedTask = R
									break

							if (!istype(locatedTask))
								return 1

							var/model = (text2num_safe(parsedFields["model"]) == 1 ? 1: 0)

							locatedTask.configure(parsedFields)
							message_device("command=upload&overwrite=1&newmodel=[model]", locatedTask)

							src.contents_mirror -= locatedTask
							SPAWN(0.5 SECONDS)
								//qdel(locatedTask)
								if (locatedTask)
									locatedTask.dispose()

				return 1

			return 0

		update_status()
			if (!statusfile)
				for (var/datum/computer/R in src.contents_mirror)
					if (R.name == setup_statusfile_name)
						if (istype(R, /datum/computer/file/record))
							statusfile = R
						else
							return

				statusfile = new /datum/computer/file/record(  )
				statusfile.name = setup_statusfile_name
				statusfile.metadata["permission"] = COMP_ROTHER
				src.contents_mirror += statusfile

			statusfile.fields.len = 0
			if (src.bot_id)
				statusfile.fields["id"] = src.bot_id
				statusfile.fields["curtask"] = src.bot_taskid
				statusfile.fields["deftask"] = src.bot_taskid_default
				statusfile.fields["charge"] = src.bot_charge
				statusfile.fields["tool"] = src.bot_toolid
				src.status = src.bot_toolid
			else
				statusfile.fields["id"] = "nobot"
				src.status = null

			return

	add_file(var/datum/computer/file/theFile)
		if (!initialized || !istype(theFile))
			return 0

		//contents_mirror += file

		if (istype(theFile, /datum/computer/file/record))
			//contents_mirror += file

			parse_record(theFile)
			//qdel(file)
			theFile.dispose()
			return 1

		else if (istype(theFile, /datum/computer/file/guardbot_task))
			contents_mirror += theFile

			return 1

		return 0

	remove_file(var/datum/computer/file/theFile)
		if (!initialized || !theFile)
			return 0

		if (theFile in contents_mirror)
			contents_mirror -= theFile

			return 1

		return 0

	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		return 0

//Guardbot interface program
//Because I don't have all the shell script stuff ready enough otherwise yet
/datum/computer/file/mainframe_program/guardbot_interface
	name = "prman"
	size = 4
	var/const/buddyFreq = FREQ_BUDDY

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		. = read_user_field("group")
		if ((. > src.metadata["group"]) && (. != 0)) //User isn't sysop.
			message_user("Error: Access denied. System Operator status required.")
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			message_user("Invalid commmand argument.|nValid Arguments:|n \"list\" to list known docking stations.|n \"stat (PR-6 Net ID)\" to view unit status. |n \"upload (PR-6 Net ID) (task filepath) \[configuration filepath]\" to upload task.|n \"wake (PR-6 Net ID)\" to wake unit.|n \"wipe (PR-6 Net ID)\" to clear unit memory.|n \"recall (PR-6 Net ID | \'all\')\" to recall unit.","multiline")
			mainframe_prog_exit
			return

		var/list/driverlist = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="pr6_charg", "mode"=1))
		if (!istype(driverlist) || !length(driverlist))
			message_user("Error: Could not detect PR-6 driver(s).")
			mainframe_prog_exit
			return

		var/command = lowertext(initlist[1])
		switch(command)
			if ("list")
				var/listText = ""
				for (var/x in driverlist)
					listText += "[x] - [driverlist[x] ? "[driverlist[x]]" : "NONE"]|n"
				if (!listText)
					listText = "NONE"
				message_user("Known PR-6 Units:|n[listText]", "multiline")

			if ("stat")
				if (initlist.len < 2 || !(lowertext(initlist[2]) in driverlist))
					message_user("Error: Unknown or invalid PR-6 Net ID")
					mainframe_prog_exit
					return

				var/datum/computer/file/record/statrec = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"="/mnt/_[lowertext(initlist[2])]/status"))
				if (!istype(statrec))
					message_user("Error: Unable to fetch unit status.")
					mainframe_prog_exit
					return

				var/statmessage = "Status for Unit \[[lowertext(initlist[2])]]|n"
				if (statrec.fields["id"] != "nobot")
					statmessage += " Charge: "
					if (!isnum(text2num_safe(statrec.fields["charge"])))
						statmessage += "No cell!|n"
					else
						statmessage += "[text2num_safe(statrec.fields["charge"])]%|n"

					statmessage += " Current Tool: [statrec.fields["tool"] ? statrec.fields["tool"] : "NONE"]|n"
					statmessage += " Current Task: [statrec.fields["curtask"] ? statrec.fields["curtask"] : "NONE"]|n"
					statmessage += " Default Task: [statrec.fields["deftask"] ? statrec.fields["deftask"] : "NONE"]"

				else
					statmessage = "No PR-6 unit docked."

				message_user(statmessage, "multiline")

			if ("upload")
				if (initlist.len < 2 || !(lowertext(initlist[2]) in driverlist))
					message_user("Error: Unknown or invalid PR-6 Net ID")
					mainframe_prog_exit
					return

				if (initlist.len < 3)
					message_user("Error: No task filepath supplied.")
					mainframe_prog_exit
					return

				var/current = read_user_field("curpath")
				if (!initlist[3])
					initlist[3] = current
					if(!initlist[3])
						initlist[3] = "/"

				else if (!dd_hasprefix(initlist[3], "/"))
					initlist[3] = "[current]" + (current == "/" ? null : "/") + initlist[3]

				var/datum/computer/file/guardbot_task/task = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[3]))
				if (istype(task))
					//If we're uploading a task, first we need to hand the driver a copy of that task!
					var/datum/computer/file/guardbot_task/taskCopy = task.copy_file()
					taskCopy.name = "uploadtmp"
					if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/_[lowertext(initlist[2])]", "replace"=1), taskCopy) != ESIG_SUCCESS)
						message_user("Error: Unable to pass task to dock driver. Code 0xF5")
						//qdel(taskCopy)
						taskCopy.dispose()

						mainframe_prog_exit
						return

					var/datum/computer/file/record/commandRec = new /datum/computer/file/record(  )
					commandRec.name = "command"
					commandRec.fields += list("command=upload", "model=1", "fname=uploadtmp")

					//Optional configuration file specification
					if (initlist.len >= 4)
						if (initlist.len > 4 && cmptext(initlist[4], "-f"))
							if (!initlist[5])
								initlist[5] = current
								if(!initlist[5])
									initlist[5] = "/"

							else if (!dd_hasprefix(initlist[4], "/"))
								initlist[5] = "[current]" + (current == "/" ? null : "/") + initlist[5]

							var/datum/computer/file/record/configfile = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=initlist[5]))
							if (istype(configfile))
								commandRec.fields += configfile.fields
							else
								message_user("Warning: Configuration filepath invalid.")
						else
							. = ""
							for (var/i = 4, i <= initlist.len, i++)
								. += initlist[i]

							if (.)
								commandRec.fields += splittext(., ";")


					//Now give the driver the actual command record.
					if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/_[lowertext(initlist[2])]","replace"=1), commandRec) != ESIG_SUCCESS)
						message_user("Error: Unable to pass configuration to dock driver. Code 0xF7")
						//qdel(commandRec)
						if (commandRec)
							commandRec.dispose()

						mainframe_prog_exit
						return


				else
					message_user("Error: Unknown or invalid task filepath.")


			if ("wipe")
				if (initlist.len < 2 || !(lowertext(initlist[2]) in driverlist))
					message_user("Error: Unknown or invalid PR-6 Net ID")
					mainframe_prog_exit
					return

				var/datum/computer/file/record/commandRec = new /datum/computer/file/record(  )
				commandRec.name = "command"
				commandRec.fields += "command=wipe"

				if(signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/_[lowertext(initlist[2])]","replace"=1), commandRec) != ESIG_SUCCESS)
					message_user("Error: Unable to interface with dock driver. Code 0xF7")
					//qdel(commandRec)
					if (commandRec)
						commandRec.dispose()

				else
					message_user("Transmitting wipe command...")


			if ("wake")
				if (initlist.len < 2 || !(lowertext(initlist[2]) in driverlist))
					message_user("Error: Unknown or invalid PR-6 Net ID")
					mainframe_prog_exit
					return

				var/datum/computer/file/record/commandRec = new /datum/computer/file/record(  )
				commandRec.name = "command"
				commandRec.fields += "command=wake"

				if(signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/_[lowertext(initlist[2])]","replace"=1), commandRec) != ESIG_SUCCESS)
					message_user("Error: Unable to interface with dock driver.")
					//qdel(commandRec)
					if (commandRec)
						commandRec.dispose()

				else
					message_user("Transmitting wake command...")

			if ("recall")
				if (initlist.len < 2)
					message_user("Error: No PR-6 Net ID specified.")
					mainframe_prog_exit
					return

				var/targetID = ckey(initlist[2])
				if (targetID != "all" && ((length(targetID) != 8) || !is_hex(targetID)))
					message_user("Error: Invalid or malformed PR-6 Net ID")
					mainframe_prog_exit
					return

				var/radioDriver = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="pr6_radio"))
				if (radioDriver & ESIG_DATABIT)
					radioDriver &= ~ESIG_DATABIT
					//signal_program(1, list("command"="dmsg", "target"=radioDriver, "dcommand"="transmit", "data"="[targetID == "all" ? "acc_code=[netpass_heads]" : "address_1=[targetID]"];command=dock_return;_freq=[buddyFreq]"))

					var/datum/computer/file/record/sigFile = new
					sigFile.name = "[ascii2text( rand(65,91) )][time2text(world.realtime, "MMDDhhmmss")]"
					sigFile.fields = list(targetID == "all" ? "acc_code=[netpass_heads]" : "address_1=[targetID]", "command=dock_return")
					signal_program(1, list("command"=DWAINE_COMMAND_FWRITE, "path"="/mnt/radio/[buddyFreq]","replace"=1,"mkdir"=1), sigFile)

				else
					message_user("Error: Could not detect radio driver.")

			else
				message_user("Unknown command argument.")

		mainframe_prog_exit
		return

//Radio driver
/datum/computer/file/mainframe_program/driver/mountable/radio
	name = "pr6_radio"
	setup_processes = 1

	var/tmp/list/radio_users = list()
	var/tmp/initial_reqistry_complete = 0

	initialize(var/initparams)
		if (..())
			return

		signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name, "link"="radio"))
		return

	process()
		return

	disposing()
		for (var/a_user_id in radio_users)
			var/list/id_stuff = radio_users[a_user_id]
			if (istype(id_stuff) && length(id_stuff))
				signal_program(1, list("command"=DWAINE_COMMAND_TKILL, "target"=id_stuff[1]))

		if (radio_users)
			radio_users.len = 0
			radio_users = null

		..()

	terminal_input(var/data, var/datum/computer/file/theFile)
		if (..() || !data)
			return 1

		var/list/dataList = params2list(data)
		if (!dataList || !length(dataList))
			return 1

		if (dataList["sender"])
			. = ckey( dataList["sender"] )
			switch ( lowertext(dataList["command"]) )
				if ("term_connect")
					if (!dataList["address_1"] || !dataList["_freq"])
						return 1
					if (. in radio_users)
						radio_users -= .
						message_device("_freq=[ dataList["_freq"] ]&address_1=[ . ]&command=term_disconnect")
						//signal_program(1, list()) //Logout user too.
						return 1

					radio_users[.] = list("[ dataList["_freq"] ]", null)

					if(dataList["data"] != "noreply")
						message_device("_freq=[ dataList["_freq"] ]&address_1=[ . ]&command=term_connect&data=noreply")

					if (signal_program(1, list("command"=DWAINE_COMMAND_ULOGIN, "data"=., "name"="TEMP")) != ESIG_SUCCESS)
						radio_users -= .
						return 1

					return 0

				if ("term_message", "term_file")
					if (!dataList["address_1"] || !dataList["data"] || !dataList["_freq"])
						return 1
					if (!(. in radio_users))
						return 1
					return signal_program(1, list("command"=DWAINE_COMMAND_UINPUT, "data" = dataList["data"], "term" = .), theFile) != ESIG_SUCCESS

				if("term_ping")
					if (!dataList["address_1"] || !dataList["_freq"])
						return 1
					if(!(. in radio_users))
						message_device("_freq=[ dataList["_freq"] ]&address_1=[ . ]&command=term_disconnect")
						return 1
					if(dataList["data"] == "reply")
						message_device("_freq=[ dataList["_freq"] ]&address_1=[ . ]&command=term_ping")
					return 0

				if ("term_disconnect")
					if (!dataList["address_1"] || !dataList["_freq"])
						return 1
					radio_users -= .
					message_device("_freq=[ dataList["_freq"] ]&address_1=[ . ]&command=term_disconnect")
					return 0

		if (cmptext(dataList["command"],"register") && !initial_reqistry_complete)
			initial_reqistry_complete = 1

			var/list/newFreqs = splittext(dataList["freqs"], ",")
			for (var/newFreq in newFreqs)
				var/datum/computer/folder/folder = new
				folder.name = newFreq
				src.add_file(folder)

			return 0

		if (!dataList["_freq"])
			return 1

		var/datum/computer/file/record/signalRecord = new
		signalRecord.fields = dataList
		signalRecord.name = "[ascii2text( rand(65,90))][ascii2text( rand(65,90) )][time2text(world.realtime, "MMDDhhmm")]"
		signalRecord.holder = src.holder

		for (var/datum/computer/folder/radio_channel/rc in src.contents_mirror)
			if (cmptext(rc.name, dataList["_freq"]))
				rc.contents += signalRecord
				signalRecord.holding_folder = rc
				if (rc.contents.len > 32)
					var/datum/computer/to_delete = rc.contents[1]
					if (to_delete)
						qdel(to_delete)
				return 0

		src.contents_mirror += signalRecord
		return 0

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (data["command"])
			if ("transmit","TRANSMIT")
				if (!data["data"])
					return ESIG_GENERIC

				message_device(data["data"], file)
				return ESIG_SUCCESS

			if (DWAINE_COMMAND_MSG_TERM)
				if (!data["term"] || !data["data"])
					return ESIG_NOTARGET

				. = radio_users[ "[data["term"]]" ]
				if (!istype(., /list))
					return ESIG_NOTARGET

				message_device("_freq=[.[1]]&address_1=[ data["term"] ]&command=term_message&data=[ data["data"] ]&render=[ data["render"] ]")
				return ESIG_SUCCESS

		return ESIG_GENERIC

	add_file(var/datum/computer/file/theFile, var/freq)
		if (!initialized)
			return 0

		if (istype(theFile, /datum/computer/file/record))
			if (istext(freq))
				var/datum/computer/file/record/R = theFile
				if (R.fields.len)
					message_device("_freq=[freq]&[jointext(R.fields, ";")]")

			//qdel(file)
			theFile.dispose()

			return 1

		else if (istype(theFile, /datum/computer/folder))
			var/newFreqName = text2num_safe(theFile.name)
			if (newFreqName < 1000 || newFreqName > 1500 || newFreqName != round(newFreqName))
				theFile.dispose()
				return 0

			newFreqName = "[newFreqName]"
			for (var/datum/computer/folder/otherFolder in contents_mirror)
				if (otherFolder.name == newFreqName)
					theFile.dispose()
					return 0

			theFile.dispose()
			theFile = new /datum/computer/folder/radio_channel ( src )
			theFile.name = newFreqName
			theFile.holding_folder = src

			contents_mirror += theFile
			message_device("_command=add&_freq=[newFreqName]")
			return theFile

		return 0

	remove_file(var/datum/computer/file/file)
		if (!initialized || !file)
			return 0

		if (file in contents_mirror)
			if (istype(file, /datum/computer/folder/radio_channel))
				message_device("_command=remove&_freq=[file.name];")
			contents_mirror -= file

			return 1

		return 0

	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		return 0

/datum/computer/folder/radio_channel
	var/datum/computer/file/mainframe_program/driver/mountable/radio/ourDriver

	New(var/datum/computer/file/mainframe_program/driver/mountable/radio/newDriver)
		..()

		if (istype(newDriver))
			ourDriver = newDriver

	can_add_file(datum/computer/file/R)
		return (ourDriver && istype(R))

	add_file(var/datum/computer/file/theFile)
		if (!ourDriver)
			return 0

		return ourDriver.add_file(theFile, src.name)

	remove_file(var/datum/computer/file/theFile)
		if (!ourDriver)
			return 0

		src.contents -= theFile
		return 1

#define STATE_OFF 0
#define STATE_IDLE 1
#define STATE_ONGUARD 2
#define STATE_ALERTED 3
#define STATE_UNKNOWN 4

//IR detector driver
/datum/computer/file/mainframe_program/driver/secdetector
	name = "ir_detect"
	setup_processes = 1
	status = 0

	var/tmp/detectorID = null
	var/tmp/knownState = 0

	process()
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (lowertext(data["command"]))
			if ("report_status")
				switch(knownState)
					if (STATE_OFF)
						return ESIG_USR1
					if (STATE_IDLE)
						return ESIG_USR2
					if (STATE_ONGUARD)
						return ESIG_USR3
					if (STATE_ALERTED)
						return ESIG_USR4
					else
						return ESIG_IOERR

			if ("activate")
				//todo
				return ESIG_SUCCESS

			if ("deactivate")
				//todo
				return ESIG_SUCCESS

		return ESIG_GENERIC

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				if (!detectorID && !isnull(ckey(datalist["data"])))
					detectorID = ckey(datalist["data"])

				return

			if ("statechange")
				switch(lowertext(datalist["state"]))
					if ("inactive")
						knownState = STATE_OFF
					if ("idle")
						knownState = STATE_IDLE
					if ("onguard")
						knownState = STATE_ONGUARD
					if ("alert")
						knownState = STATE_ALERTED
					else
						knownState = STATE_UNKNOWN

				src.status = knownState

				return

		return

#undef STATE_OFF
#undef STATE_IDLE
#undef STATE_ONGUARD
#undef STATE_ALERTED
#undef STATE_UNKNOWN

//APC driver
/datum/computer/file/mainframe_program/driver/apc
	name = "pwr_cntrl"
	setup_processes = 1
	status = "0;0;0;0"
	var/tmp/apcID = null

	var/tmp/apcEquip = 0
	var/tmp/apcLight = 0
	var/tmp/apcEnviron = 0
	var/tmp/apcCover = 0

	process()
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		if (lowertext(data["command"]) == "setmode")
			var/commandString = null
			var/newEquip = data["equip"]
			var/newLight = data["light"]
			var/newEnviron = data["environ"]
			var/newCover = data["cover"]

			if (!isnull(newEquip))
				commandString += "&equip=[round(clamp(newEquip, 0, 3))]"

			if (!isnull(newLight))
				commandString += "&light=[round(clamp(newLight, 0, 3))]"

			if (!isnull(newEnviron))
				commandString += "&environ=[round(clamp(newEnviron, 0, 3))]"

			if (!isnull(newCover))
				commandString += "&cover=[newCover ? "1" : "0"]"

			if (commandString)
				message_device("command=setmode[commandString]")

			return ESIG_SUCCESS

		return ESIG_GENERIC

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				if (!apcID && !isnull(ckey(datalist["data"])))
					apcID = ckey(datalist["data"])
					message_device("command=status")

				return

			if ("status")
				var/newEquip = text2num_safe(datalist["equip"])
				var/newLight = text2num_safe(datalist["light"])
				var/newEnviron = text2num_safe(datalist["environ"])
				var/newCover = text2num_safe(datalist["cover"])

				if (!isnull(newEquip))
					apcEquip = round(clamp(newEquip, 0, 3))

				if (!isnull(newLight))
					apcLight = round(clamp(newLight, 0, 3))

				if (!isnull(newEnviron))
					apcEnviron = round(clamp(newEnviron, 0, 3))

				if (newCover)
					apcCover = 1
				else
					apcCover = 0

				status = "[apcEquip];[apcLight];[apcEnviron];[apcCover]"

		return


//HEPT emitter
/datum/computer/file/mainframe_program/driver/hept_emitter
	name = "hept_emit"
	setup_processes = 1
	status = 0

	process()
		return

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				if (datalist["data"] == "1")
					status = 1
				else
					status = 0
			if ("ack")
				status = !status

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (lowertext(data["command"]))
			if ("report_status")
				if (status)
					return ESIG_USR1
				else
					return ESIG_USR2

			if ("activate")
				message_device("command=activate")

				return ESIG_SUCCESS

			if ("deactivate")
				message_device("command=deactivate")

				return ESIG_SUCCESS


		return ESIG_GENERIC

//A very simple interface program for the HEPT emitter.
/datum/computer/file/mainframe_program/hept_interface
	name = "heptman"
	size = 4

	initialize(var/initparams)
		if (..())
			mainframe_prog_exit
			return

		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			message_user("Invalid commmand argument.|nValid Commands:|n (Status) for emitter status.|n (Activate) to activate emitter|n (Deactivate) to shut down emitter.","multiline")
			mainframe_prog_exit
			return

		var/driver_id = signal_program(1, list("command"=DWAINE_COMMAND_DGET, "dtag"="hept_emit"))
		if (!(driver_id & ESIG_DATABIT))
			message_user("Error: Could not detect emitter driver.")
			mainframe_prog_exit
			return

		driver_id &= ~ESIG_DATABIT
		var/command = lowertext(initlist[1])
		switch(command)
			if ("status")
				var/statReport = signal_program( 1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="report_status"))
				switch (statReport)
					if (ESIG_USR1)
						message_user("Emitter status: Active")

					if (ESIG_USR2)
						message_user("Emitter status: Inactive")

					else
						message_user("Error: Unknown status code from driver.")

			if ("activate")
				var/success = signal_program( 1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="activate"))
				if (success == ESIG_SUCCESS)
					message_user("Transmitting activation signal...")
				else
					message_user("Error: Could not associate with driver.")


			if ("deactivate")
				var/success = signal_program( 1, list("command"=DWAINE_COMMAND_DMSG,"target"=driver_id,"dcommand"="deactivate"))
				if (success == ESIG_SUCCESS)
					message_user("Transmitting deactivation signal...")
				else
					message_user("Error: Could not associate with driver.")

			else
				message_user("Unknown command argument.")


		mainframe_prog_exit
		return

//A program that will automatically load when the H7 mainframe starts up and proceed to keep watch over the labs.
/datum/computer/file/mainframe_program/h7init
	name = "init"
	size = 16

	var/process_delay_divider = 4 //Only process every (this many) ticks.
	var/tmp/security_state = 0
	var/setup_security_timeout = 15

	initialize()
		if (..() || useracc) //Should not be run by a user.
			mainframe_prog_exit
			return


		return

	process()
		if (..() || process_delay_divider--)
			return

		process_delay_divider = initial(process_delay_divider)

		if (!security_state)
			var/list/secDrivers = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="ir_detect"))
			if (!istype(secDrivers))
				return

			for (var/drivID = 1, drivID <= secDrivers.len, drivID++)
				if (isnull(secDrivers[drivID]))
					continue

				//Check if any of the drivers are reporting an alerted device...
				var/result = secDrivers[secDrivers[drivID]]
				if (result >= 3)
					security_state = setup_security_timeout
					process_delay_divider = 1
					return

			//qdel(secDrivers)
			secDrivers.len = 0
			secDrivers = null

		else if (security_state-- == setup_security_timeout)
			activateAPCs()
			dispatchGuards()

		return

	proc/activateAPCs()
		var/list/apcDrivers = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="pwr_cntrl"))
		if (!istype(apcDrivers))
			return
		for (var/drivID = 1, drivID <= apcDrivers.len, drivID++)
			if (isnull(apcDrivers[drivID]))
				continue

			signal_program(1, list("command"=DWAINE_COMMAND_DMSG,"target"=drivID,"dcommand"="setmode","equip"=3,"light"=3,"environ"=3))
			continue

		return

	proc/dispatchGuards()
		var/list/guardDrivers = signal_program(1, list("command"=DWAINE_COMMAND_DLIST, "dtag"="pr6_charg", "mode"=1))
		if (!istype(guardDrivers))
			return
		for (var/drivID = 1, drivID <= guardDrivers.len, drivID++)

			if (isnull(guardDrivers[drivID]))
				continue

			var/datum/computer/file/record/commandRec = new /datum/computer/file/record( )
			commandRec.name = "command"
			commandRec.fields = list("command=wake")

			var/result = signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/_[lowertext(guardDrivers[drivID])]"), commandRec)
			if(result != ESIG_SUCCESS)
				//qdel(commandRec)
				commandRec.dispose()
			continue


		return

//General test equipment driver
/datum/computer/file/mainframe_program/driver/test_apparatus
	name = "test_appt"
	setup_processes = 1
	status = "UNKNOWN"
	var/tmp/active = 0
	var/tmp/last_action = null
	var/tmp/isSensor = 0 //Is the connected device a sensor?
	var/tmp/isEnactor = 0 //Is the connected device an "enactor" (Transducer I guess? Stimulus.)
	var/tmp/list/sessions = list()
	var/tmp/list/knownReadingFields = list()	//Associated list of Known Reading Fields -> Unit of Measure
	var/tmp/list/knownReadings = list()
	var/tmp/list/knownValues = list()

	process()
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		var/old_last_action = last_action
		last_action = lowertext(data["command"])
		switch (last_action)
			if ("info") //Send info request (Device ID and capabilities, separate from status)
				var/sessionid = "[world.timeofday%100][rand(0,9)]"
				sessions["[sessionid]"] = sendid

				message_device("command=info&session=[sessionid]")
				return ESIG_SUCCESS

			if ("status") //Request current state of device, whether it is active, etc
				message_device("command=status")
				return ESIG_SUCCESS

			if ("poke") //Set an arbitrary (device-specific) configuration value on the device.
				if (!isnull(data["field"]) && !isnull(data["value"]))
					if (isnum(data["value"]))
						data["value"] = round(clamp(data["value"], 1, 400)) // 400 is highest stimulus value for heater

					var/sessionid = "[world.timeofday%100][rand(0,9)]"
					sessions["[sessionid]"] = sendid
					message_device("command=poke&field=[data["field"]]&value=[data["value"]]&session=[sessionid]")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

			if ("peek") //Read the value of configuration value on device.
				if (!isnull(data["field"]))
					var/sessionid = "[world.timeofday%100][rand(0,9)]"
					sessions["[sessionid]"] = sendid
					message_device("command=peek&field=[data["field"]]&session=[sessionid]")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

//Enactor Specific Commands
			if ("pulse") //Send pulse command & duration
				if (!isEnactor)
					return ESIG_BADCOMMAND

				var/pulseDuration = data["duration"]
				if (!isnum(pulseDuration))
					pulseDuration = 1

				pulseDuration = clamp(pulseDuration, 1, 255)
				message_device("command=pulse&duration=[pulseDuration]")
				return ESIG_SUCCESS

			if ("activate") //Send activation command, if enactor.
				if (isEnactor)
					message_device("command=activate")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

			if ("deactivate") //Send deactivation commmand, if enactor.
				if (isEnactor)
					message_device("command=deactivate")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

//Sensor Specific Commands
			if ("sense") //Send sense command, if sensor.
				if (isSensor)
					message_device("command=sense")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

			if ("read") //Send read command, if sensor.
				if (isSensor)
					var/sessionid = "[world.timeofday%100][rand(0,9)]"
					sessions["[sessionid]"] = sendid
					message_device("command=read&session=[sessionid]")
					return ESIG_SUCCESS

				return ESIG_BADCOMMAND

		//This isn't a valid new last_action, set it back
		last_action = old_last_action

		return ESIG_GENERIC

	terminal_input(var/data, var/datum/computer/file/file)
		if (..())
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))
			if ("register")
				//Set apparatus ID
				status = uppertext(copytext(ckeyEx(datalist["id"]), 1, 16))
				if (!status)
					status = "UNKNOWN"

				src.active = (datalist["data"] == "1")

				//Determine if the device is an enactor, a sensor, or both.
				switch (lowertext(datalist["capability"]))
					if ("e") //Enactor
						isEnactor = 1
						isSensor = 0
					if ("s") //Sensor
						isEnactor = 0
						isSensor = 1
					if ("b") //Both
						isEnactor = 1
						isSensor = 1

				//Request further data.
				sessions["0"] = null

				message_device("command=info&session=0")

				//A thought: maybe the capability check could be removed from here now that we query info.
				return

			if ("ack")
				switch (src.last_action)
					if ("activate", "pulse")
						active = 1
					if ("deactivate")
						active = 0
					if ("poke")
						var/sessionID = datalist["session"]
						if (!sessionID || !(sessionID in sessions))
							return

						var/waitID = sessions["[sessionID]"]
						sessions -= "[sessionID]"
						if (!isnum(waitID))
							return

						signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="SUCCESS"))
						return

			if ("peeked")
				var/sessionID = datalist["session"]
				if (!sessionID || !(sessionID in sessions))
					return

				var/waitID = sessions["[sessionID]"]
				sessions -= "[sessionID]"
				if (!isnum(waitID))
					return

				signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY, "data"="[isnull(datalist["field"]) ? "NULL" : "[datalist["field"]]"]-[isnull(datalist["value"]) ? "NULL" : "[datalist["value"]]"]", "format"="field"))
				//signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="Value: \[[isnull(datalist["value"]) ? "NULL" : "[datalist["value"]]"]]"))
				return

			if ("nack")
				switch (src.last_action)
					if ("poke")
						var/sessionID = datalist["session"]
						if (!sessionID || !(sessionID in sessions))
							return

						var/waitID = sessions["[sessionID]"]
						sessions -= "[sessionID]"
						if (!isnum(waitID))
							return

						signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="Error: Invalid Field or Value."))
						return

					if ("peek")
						var/sessionID = datalist["session"]
						if (!sessionID || !(sessionID in sessions))
							return

						var/waitID = sessions["[sessionID]"]
						sessions -= "[sessionID]"
						if (!isnum(waitID))
							return

						signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="Error: Invalid Field."))
						return

					if ("read")
						var/sessionID = datalist["session"]
						if (!sessionID || !(sessionID in sessions))
							return

						var/waitID = sessions["[sessionID]"]
						sessions -= "[sessionID]"
						if (!isnum(waitID))
							return

						signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="No sense data to read!"))
						return

			if ("info")
				var/sessionID = datalist["session"]
				if (!sessionID || !(sessionID in sessions))
					return

				status = uppertext(copytext(ckeyEx(datalist["id"]), 1, 16))
				if (!status)
					status = "UNKNOWN"

				src.active = (datalist["status"] == "1")

				switch (lowertext(datalist["capability"]))
					if ("e") //Enactor
						isEnactor = 1
						isSensor = 0
					if ("s") //Sensor
						isEnactor = 0
						isSensor = 1
					if ("b") //Both
						isEnactor = 1
						isSensor = 1

				if (knownReadingFields)
					knownReadingFields.len = 0
				else
					knownReadingFields = list()
				var/list/deviceFields = splittext(datalist["readinglist"], ",")
				var/unit_offset = 0
				for (var/reading_entry in deviceFields)
					if (!reading_entry)
						continue

					unit_offset = findtext(reading_entry, "-")
					if (unit_offset > 1)
						. = copytext(reading_entry, unit_offset, 33)
						reading_entry = copytext(reading_entry, 1, unit_offset)
					else
						. = null

					knownReadingFields[reading_entry] = .

				if (datalist["valuelist"])
					knownValues = splittext(datalist["valuelist"], ",")


				var/waitID = sessions["[sessionID]"]
				sessions -= "[sessionID]"
				if (!isnum(waitID))
					return

				var/infotext = "[active],[status],[isEnactor],[isSensor]"
				if (datalist["valuelist"])
					infotext += ",[datalist["valuelist"]]"

				signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY, "data"=infotext, "format"="info"))
				return

			if ("read")
				var/list/readData = splittext(datalist["data"], ",")
				var/sessionID = datalist["session"]
				if (!sessionID || !(sessionID in sessions))
					return

				if (!isnull(readData))
					if (knownReadings.len < knownReadingFields.len)
						knownReadings.len = length(knownReadingFields)

					for (var/i = 1, i <= knownReadingFields.len && i <= readData.len, i++)
						knownReadings[i] = readData[i]

				var/waitID = sessions["[sessionID]"]
				sessions -= "[sessionID]"
				if (!isnum(waitID))
					return

				var/readDataString = ""
				for (var/i = 1, i <= min(knownReadings.len, knownReadingFields.len), i++)
					if (readDataString)
						readDataString += ","

					readDataString += "[knownReadingFields[i]] [knownReadings[i]] [knownReadingFields[ knownReadingFields[i] ]]"

				signal_program(waitID, list("command"=DWAINE_COMMAND_REPLY,"data"="[readDataString]","format"="values"))


			if ("status")
				if (datalist["data"] == "1")
					active = 1
				else
					active = 0
				return

		return




//Service terminal -- For terminal interaction besides an interactive user that just want to query some daemon about something and do not require a shell.
/datum/computer/file/mainframe_program/driver/mountable/service_terminal
	name = "srv_terminal"
	setup_processes = 1
	status = "INVALID"
	var/userid = null
	var/service_id = 0

	process()
		return

	/* new disposing() pattern should handle this. -singh
	disposing()
		if (service_id)
			signal_program(1, list("command"="tkill", "target"=service_id))
		..()
	*/

	disposing()
		if (service_id)
			signal_program(1, list("command"=DWAINE_COMMAND_TKILL, "target"=service_id))

		userid = null
		..()

	initialize(initparams)
		if (..() || !istype(initparams, /datum/computer/file/record))
			return

		var/datum/computer/file/record/initRec = initparams
		if (!initRec.fields || !initRec.fields["userid"])// || !initRec.fields["service"])
			return

		userid = ckeyEx(initRec.fields["userid"])

		var/datum/mainframe2_user_data/srvUser = new
		src.useracc = srvUser
		srvUser.user_id = userid
		srvUser.current_prog = src

		if (signal_program(1, list("command"=DWAINE_COMMAND_ULOGIN, "name"="SRV[userid]", "service"=1, "sysop"=1)) != ESIG_SUCCESS)
			//qdel(srvUser)
			srvUser.dispose()
			return

		signal_program(1, list("command"=DWAINE_COMMAND_MOUNT, "id"=src.name))
		if (initRec.fields["service"])
			var/datum/computer/file/mainframe_program/exec = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="/sys/srv/[initRec.fields["service"]]"))
			if (istype(exec))
				var/list/siglist = list("command"=DWAINE_COMMAND_TSPAWN, "passusr"=1, "path"="/sys/srv/[initRec.fields["service"]]")
				if (initRec.fields["args"])
					siglist["args"] = strip_html(initRec.fields["args"])

				exec = signal_program(1, siglist)
				if (istype(exec))
					service_id = exec.progid
					status = "OK"
		else
			status = "OK"

				//qdel(siglist)

		return

	terminal_input(var/data, var/datum/computer/file/theFile)
		if (..())
			return

		var/list/datalist = params2list(data)
		var/command = lowertext(datalist["command"])
		if (!command)
			return

		if (service_id && (signal_program(1, list("command"=DWAINE_COMMAND_TKILL, "target"=service_id)) == ESIG_GENERIC))
			service_id = null

		var/datum/computer/file/mainframe_program/exec = signal_program(1, list("command"=DWAINE_COMMAND_FGET, "path"="/sys/srv/[command]"))
		if (istype(exec))
			var/list/siglist = list("command"=DWAINE_COMMAND_TSPAWN, "passusr"=1, "path"="/sys/srv/[command]")
			if (datalist["args"])
				siglist["args"] = strip_html(datalist["args"])

			if (istype(theFile))
				var/datum/computer/file/copy = theFile.copy_file()

				if (copy)
					copy.name = "tmp[copytext("\ref[copy]", 4, 12)]"
					src.contents_mirror += copy
					if (src.contents_mirror.len > 8)
						src.contents_mirror.Cut(1,2)
					siglist["args"] = siglist["args"] + " /mnt/_[src.name]/[copy.name]"

			exec = signal_program(1, siglist)
			if (istype(exec))
				service_id = exec.progid
				status = "OK"
			else
				service_id = 0

			//qdel(siglist)

		return

	receive_progsignal(var/sendid, var/list/data = null, var/datum/computer/file/file)
		if (..())
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		if (data["command"]  == DWAINE_COMMAND_MSG_TERM)
			if (findtext(data["render"],"record"))
				var/list/dataList = splittext(data["data"],"|n")
				var/dataMessage = ""
				var/datum/computer/file/record/messageRec = null
				if (dataList.len)
					dataMessage = "command=[dataList[1]]"
					dataList.Cut(1,2)

				if (dataList.len) //Cutting out the first term may have left us with a rather brief list (Of nothing)
					messageRec = new /datum/computer/file/record( )
					messageRec.fields = dataList

				message_device(dataMessage, messageRec)
			else
				message_device("command=[data["data"]]", file)

		else if (data["command"] == DWAINE_COMMAND_EXIT || data["command"] == DWAINE_COMMAND_TEXIT)
			src.service_id = 0
			status = "IDLE"

		return

/datum/computer/file/mainframe_program/srv/print
	name = "print"
	size = 1

	initialize(var/initparams)
		if (..() || !useracc)
			mainframe_prog_exit
			return

		var/command = null
		var/list/initlist = splittext(initparams, " ")
		if (!initparams || !length(initlist))
			command = "index"
		else
			command = ckey(initlist[1])

		switch (command)
			if ("index")
				//locate mounted printers
				var/datum/computer/folder/mount = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"="/mnt"))
				if (istype(mount))
					var/response = "print_index"
					for (var/datum/computer/potentialPrinter in mount.contents)
						if (copytext(lowertext(potentialPrinter.name), 1, 4) == "lp-")
							response += "|n[copytext(potentialPrinter.name, 4)]"

					message_user(response, "multiline")
				else
					message_user("print_index")

			if ("status")
				//Retrieve printer status value from the little record it keeps for exactly those purposes.
				if (initlist.len > 1)
					var/printerName = copytext(ckeyEx(initlist[2]), 1,33)
					var/datum/computer/file/record/printerStatus = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"="/mnt/lp-[printerName]/status"))
					var/theStatus = "???"
					if (istype(printerStatus) && printerStatus.fields && length(printerStatus.fields))
						theStatus = "[printerStatus.fields[1]]"
					message_user("print_status|n[theStatus]","multiline")

			if ("print")
				if (initlist.len > 2)
					var/printerName = copytext(ckeyEx(initlist[2]), 1,33)
					var/toPrintPath = initlist[3]
					if (!dd_hasprefix(toPrintPath, "/"))
						toPrintPath = "/[toPrintPath]"

					var/datum/computer/file/record/toPrintFile = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=toPrintPath))
					if (istype(toPrintFile))
						if (signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/lp-[printerName]"), toPrintFile) == ESIG_SUCCESS)
							message_user("ack")
						else
							message_user("nack")
					else
						message_user("nack")

			if ("printall")
				if (initlist.len > 1)
					var/toPrintPath = initlist[2]
					if (!dd_hasprefix(toPrintPath, "/"))
						toPrintPath = "/[toPrintPath]"

					var/datum/computer/file/record/toPrintFile = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"=toPrintPath))
					if (istype(toPrintFile))
						var/datum/computer/folder/mnt = signal_program(1, list("command"=DWAINE_COMMAND_FGET,"path"="/mnt"))
						if (istype(mnt))
							var/failure = 0
							for (var/datum/computer/folder/printFolder in mnt.contents)
								if (copytext(printFolder.name, 1, 4) != "lp-")
									continue

								signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/[printFolder.name]"), toPrintFile.copy_file())
/*
								if (signal_program(1, list("command"="fwrite","path"="/mnt/[printFolder.name]"), toPrintFile.copy_file()) != ESIG_SUCCESS)
									failure = 1
									break
*/
							message_user("[failure ? "n" : null]ack")
						else
							message_user("nack")
					else
						message_user("nack")

		mainframe_prog_exit
		return

/datum/computer/file/mainframe_program/driver/mountable/comm_dish
	name = "com_array"
	setup_processes = 1
	var/tmp/datum/computer/file/record/statusfile = null
	var/bridge_printer_id = "bridge"

	var/setup_statusfile_name = "status"

	disposing()
		statusfile = null

		..()

	initialize(var/initparams)
		if (..())
			return

		//signal_program(1, list("command"="mount", "id"=src.name, "link"="comm"))

		if (!statusfile)
			for (var/datum/computer/R in src.contents_mirror)
				if (R.name == setup_statusfile_name)
					if (istype(R, /datum/computer/file/record))
						statusfile = R
					return

			statusfile = new /datum/computer/file/record(  )
			statusfile.name = setup_statusfile_name
			statusfile.fields += "Status: OK"
			src.contents_mirror += statusfile

		return

	add_file(var/datum/computer/file/theFile)
		if (!initialized || !istype(theFile))
			return 0

		if (istype(theFile, /datum/computer/file/record) || !isnull(theFile.asText()))
			contents_mirror += theFile
			return 1

		return 0

	remove_file(var/datum/computer/file/file)
		if (!initialized || !file)
			return 0

		if (file in contents_mirror)
			contents_mirror -= file
			return 1

		return 0

	change_metadata(var/datum/computer/file/file, var/field, var/newval)
		return 0

	terminal_input(var/data, var/datum/computer/file/record/recfile)
		if (..() || !initialized)
			return

		var/list/datalist = params2list(data)
		switch(lowertext(datalist["command"]))

/*			if ("register")
				if (!datalist["data"])
					return

				signal_program(1, list("command"="mount", "id"=src.name, link="comm"))
*/
			if ("add_report")
				if (!istype(recfile))
					return

				recfile = recfile.copy_file()
				contents_mirror += recfile
				recfile.holder = src.holder

				recfile = recfile.copy_file() //A copy for a printer, too
				signal_program(1, list("command"=DWAINE_COMMAND_FWRITE,"path"="/mnt/lp-[bridge_printer_id]"), recfile)

				return

			if ("remove_report")
				. = round( clamp(text2num_safe(datalist["filenum"]), 0, 127 ) )
				if (!isnum(.))
					return

				for (var/datum/computer/file/record/deletion_candidate in src.contents_mirror)
					if (cmptext(deletion_candidate.name, "report[.]"))
						contents_mirror -= deletion_candidate
						deletion_candidate.dispose()
						break

				return

		return

#undef _TELESCI_ATMOS_SCAN
