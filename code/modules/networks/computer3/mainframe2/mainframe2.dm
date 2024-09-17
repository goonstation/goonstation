

/*
 *	The Terminal Connection datum, used to keep track of, well, terminal connections.
 */

/datum/terminal_connection
	var/obj/machinery/networked/master = null
	var/net_id = null //Network ID of connected device.
	var/term_type = null //Terminal type ID of connected device.  i.e. PNET_MAINFRAME or HUI_TERMINAL

	New(var/obj/machinery/networked/newmaster, var/new_id, var/newterm_type)
		..()
		if(istype(newmaster))
			src.master = newmaster

		if(new_id)
			src.net_id = new_id

		if(newterm_type)
			src.term_type = newterm_type
		return

	disposing()
		master = null

		..()

/*
 *	The physical mainframe, communication through wired network.
 */

/obj/machinery/networked/mainframe
	name = "Mainframe"
	desc = "A mainframe computer. It's pretty big!"
	density = 1
	anchored = ANCHORED
	icon_state = "dwaine"
	device_tag = "PNET_MAINFRAME"
	timeout = 30
	req_access = list(access_heads)
	machine_registry_idx = MACHINES_MAINFRAMES
	var/list/terminals = list() //list of netIDs/terminal profiles of connected terminal devices.
	var/list/processing = list() //As the name implies, this is the list of programs that should be updated every process call on the mainframe object.
	var/list/timeout_list = list() //Terminals currently set to time out
	var/datum/computer/file/mainframe_program/os/os = null //Ref to current operating system program
	var/datum/computer/file/mainframe_program/os/bootstrap = null //Ref to bootloader program, instanciated when a main OS cannot be located on the memory card
	var/datum/computer/folder/runfolder = null //Storage folder for currently running programs.
	var/obj/item/disk/data/memcard/hd = null  //Only internal storage for the mainframe--core memory, used as primary storage.

	var/posted = 1 //Have we run through the POST sequence?  Set to 1 initially so it doesn't freak out during map powernet generation.

	var/setup_drive_size = 4096
	var/setup_drive_type = /obj/item/disk/data/memcard //Use this path for the hd
	var/setup_bootstrap_path = /datum/computer/file/mainframe_program/os/bootstrap //The bootstrapping system.
	var/setup_os_string = null
	power_usage = 500

	zeta
		//setup_starting_os = /datum/computer/file/mainframe_program/os/main_os
		setup_drive_type = /obj/item/disk/data/memcard/main2

	New()
		..()
		SPAWN(1 SECOND)

			src.net_id = generate_net_id(src)

			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src

			if(!hd && (setup_drive_size > 0))
				if(src.setup_drive_type)
					src.hd = new src.setup_drive_type
					src.hd.set_loc(src)
				else
					src.hd = new /obj/item/disk/data/memcard(src)
				src.hd.file_amount = src.setup_drive_size

			if(ispath(setup_bootstrap_path))
				src.bootstrap = new setup_bootstrap_path
				src.bootstrap.master = src

			sleep(5.4 SECONDS)
			src.posted = 0
			src.post_system()

		return

	disposing()
		if (terminals)
			for (var/datum/conn in terminals)
				conn.dispose()

			terminals.len = 0
			terminals = null

		if (os)
			os.dispose()
			os = null

		if (bootstrap)
			bootstrap.dispose()
			bootstrap = null

		if (runfolder)
			runfolder = null

		if (hd)
			hd.dispose()
			hd = null

		if (processing)
			processing.len = 0
			processing = null

		if (timeout_list)
			timeout_list.len = 0
			timeout_list = null

		..()

	attack_ai(mob/user as mob)
		return

	attack_hand(mob/user)
		if (user.stat || user.restrained())
			return

		if(status & BROKEN)
			if(!src.hd)
				return

			boutput(user, SPAN_ALERT("The mainframe is trashed, but the memory core could probably salvaged."))
			return

		var/dat = "<html><head><title>Mainframe Access Panel</title></head><body><hr>"

		dat += "<b>ACTIVE:</b> [src.os ? "YES" : "NO"]<br>"
		dat += "<b>BOOTING:</b> [(src.bootstrap && src.os && istype(src.os, src.bootstrap.type)) ? "YES" : "NO"]<br><br>"

		if(status & NOPOWER)

			dat += "<b>Memory Core:</b> <a href='?src=\ref[src];core=1'>[src.hd ? "LOADED" : "---------"]</a><br>"
			dat += "Core Shield Maglock is <b>OFF</b><hr>[net_switch_html()]<hr>"
		else

			dat += "<b>Memory Core:</b> [src.hd ? "LOADED" : "---------"]<br>"
			dat += "Core Shield Maglock is <b>ON</b><hr>"


		user.Browse(dat, "window=mainframe;size=245x202")
		onclose(user, "mainframe")
		return

	Topic(href, href_list)
		if(status & BROKEN)
			return

		if (istype(src.loc, /turf) && BOUNDS_DIST(src, usr) == 0)
			if (usr.stat || usr.restrained())
				return

			src.add_dialog(usr)

			if(href_list["core"])

				if(!(status & NOPOWER))
					boutput(usr, SPAN_ALERT("The electromagnetic lock is still on!"))
					return

				//Ai/cyborgs cannot physically remove a memory board from a room away.
				if(issilicon(usr) && BOUNDS_DIST(src, usr) > 0)
					boutput(usr, SPAN_ALERT("You cannot physically touch the board."))
					return

				if(src.hd)
					src.hd.set_loc(src.loc)
					boutput(usr, "You remove the memory core from the mainframe.")
					usr.unlock_medal("421", 1)
					status |= MAINT
					src.unload_all()
					src.hd = null
					src.runfolder = null
					src.posted = 0

				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/disk/data/memcard))
						usr.drop_item()
						I.set_loc(src)
						src.hd = I
						status &= ~MAINT
						boutput(usr, "You insert [I].")
					else if (istype(I, /obj/item/magtractor))
						var/obj/item/magtractor/mag = I
						if (istype(mag.holding, /obj/item/disk/data/memcard))
							I = mag.holding
							mag.dropItem(0)
							I.set_loc(src)
							src.hd = I
							status &= ~MAINT
							boutput(usr, "You insert [I].")

			else if (href_list["dipsw"] && (status & NOPOWER))
				var/switchNum = text2num_safe(href_list["dipsw"])
				if (switchNum < 1 || switchNum > 8)
					return 1

				switchNum = round(switchNum)
				if (net_number & switchNum)
					net_number &= ~switchNum
				else
					net_number |= switchNum

			src.updateUsrDialog()
			src.add_fingerprint(usr)
		return

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			if (!(status & BROKEN))
				return

			if (!src.hd)
				boutput(user, SPAN_ALERT("The memory core has already been removed."))
				return

			status |= MAINT
			src.unload_all()
			src.hd.set_loc(src.loc)
			src.hd = null
			src.posted = 0

			boutput(user, "You pry out the memory core.")
			src.updateUsrDialog()
			return

		else
			..()

		return


	process()
		set waitfor = 0
		..()
		if(status & (NOPOWER|BROKEN|MAINT) || !processing)
			return
		if(prob(3))
			SPAWN(1 DECI SECOND)
				playsound(src.loc, pick(ambience_computer), 50, 1)

		for (var/progIndex = 1, progIndex <= src.processing.len, progIndex++)
			var/datum/computer/file/mainframe_program/prog = src.processing[progIndex]
			if (prog)
				if (prog.disposed)
					src.processing[progIndex] = null
					continue
				try
					prog.process()
				catch(var/exception/e)
					if(findtext(e.name, "Maximum recursion level reached"))
						src.unload_all()
					else
						throw e
/*
		for(var/datum/computer/file/mainframe_program/P in src.processing)
			if (P)
				P.process()
*/
		if(src.timeout == 0)
			src.timeout = initial(src.timeout)
			src.timeout_alert = 0
			for(var/timed in timeout_list)
				var/datum/terminal_connection/conn = src.terminals[timed]
				src.terminals -= timed
				if(src.os && conn)
					src.os.closed_connection(conn)
				//qdel(conn)
				if (conn)
					conn.dispose()
		else
			src.timeout--
			if(src.timeout <= 5 && !src.timeout_alert)
				src.timeout_alert = 1
				src.timeout_list = src.terminals.Copy()
				for(var/id in timeout_list)
					src.post_status(id, "command","term_ping","data","reply")

		return

	receive_signal(datum/signal/signal)
		if(status & (NOPOWER|BROKEN|MAINT) || !src.link)
			return
		if(!signal || !src.net_id || signal.encryption)
			return

		if(signal.transmission_method != TRANSMISSION_WIRE) //No radio for us thanks
			return

		var/target = signal.data["sender"]

		//They don't need to target us specifically to ping us.
		//Otherwise, if they aren't addressing us, ignore them
		if(signal.data["address_1"] != src.net_id)
			if((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id)

			return

		var/sigcommand = lowertext(signal.data["command"])
		if(!sigcommand || !signal.data["sender"])
			return

		switch(sigcommand)
			if("term_connect") //Terminal interface stuff.
				if(target in src.terminals)
					//something might be wrong here, disconnect them!
					var/datum/terminal_connection/conn = src.terminals[target]
					src.terminals.Remove(target)
					src.os?.closed_connection(conn)
					//qdel(conn)
					if (conn)
						conn.dispose()
					SPAWN(0.3 SECONDS)
						src.post_status(target, "command","term_disconnect")
					return

				var/devtype = signal.data["device"]
				if(!devtype) return
				var/datum/terminal_connection/newconn = new /datum/terminal_connection(src, target, devtype)
				src.terminals[target] = newconn //Accept the connection!
				if(signal.data["data"] != "noreply")
					src.post_status(target, "command","term_connect","data","noreply")
				//also say hi.
				if(src.os)
					var/datum/computer/theFile = null
					if (signal.data_file)
						theFile = signal.data_file.copy_file()
					src.os.new_connection(newconn, theFile)
					//qdel(file)
					if (theFile)
						theFile.dispose()
				return

			if("term_message","term_file")
				if(!(target in src.terminals)) //Huh, who is this?
					return

				//src.visible_message("[src] beeps.")
				var/data = signal.data["data"]
				var/file = null
				if(signal.data_file)
					file = signal.data_file.copy_file()
				if(src.os && data)
					src.os.term_input(data, target, file)
					if(!isnull(usr))
						var/atom/source = signal.source
						logTheThing(LOG_STATION, usr, "message '[html_encode(data)]' sent to [src] [log_loc(src)] from [source] [log_loc(source)]")

				return

			if ("term_break")
				if (!(target in src.terminals))
					return

				if (src.os)
					src.os.term_input(1, target, null, 1)

			if("term_ping")
				if(!(target in src.terminals))
					SPAWN(0.3 SECONDS) //Go away!!
						src.post_status(target, "command","term_disconnect")
					return
				if(target in src.timeout_list)
					src.timeout_list -= target
				if(signal.data["data"] == "reply")
					src.post_status(target, "command","term_ping")
				return

			if("term_disconnect")
				if(target in src.terminals)
					var/datum/terminal_connection/conn = src.terminals[target]
					src.os?.closed_connection(conn)
					src.terminals -= target
					//qdel(conn)
					if (conn)
						conn.dispose()

				return

			if("ping_reply")
				if(src.os)
					os.ping_reply(signal.data["netid"],signal.data["device"])
				return

		return

	power_change()
		if(status & BROKEN)
			icon_state = initial(src.icon_state)
			src.icon_state += "b"
			return

		else if(powered())
			icon_state = initial(src.icon_state)
			status &= ~NOPOWER
			src.post_system() //Will simply return if POSTed already.
		else
			SPAWN(rand(0, 15))
				icon_state = initial(src.icon_state)
				src.icon_state += "0"
				status |= NOPOWER
				src.posted = 0
				src.os = null

	clone()
		var/obj/machinery/networked/mainframe/cloneframe = ..()
		if (!cloneframe)
			return

		cloneframe.setup_bootstrap_path = src.setup_bootstrap_path
		cloneframe.setup_os_string = src.setup_os_string
		if (src.hd)
			cloneframe.hd = src.hd.clone()

		return cloneframe

	meteorhit(var/obj/O as obj)
		if(status & BROKEN)
			//dispose()
			src.dispose()
		set_broken()
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src)
		smoke.start()
		return

	ex_act(severity)
		switch(severity)
			if(1)
				//dispose()
				src.dispose()
				return
			if(2)
				if (prob(50))
					set_broken()
			if(3)
				if (prob(25))
					set_broken()

	blob_act(var/power)
		if (prob(power * 2.5))
			set_broken()
			src.set_density(0)

	proc
		run_program(datum/computer/file/mainframe_program/program, var/datum/mainframe2_user_data/user, var/datum/computer/file/mainframe_program/caller, var/runparams, var/allow_fork=0)
			if(!hd || !program || (!program.holder && program.needs_holder))
				return 0

			if(!runfolder)
				for (var/datum/computer/folder/F in src.hd.root.contents)
					if (F.name == "proc")
						runfolder = F
						runfolder.metadata["permission"] = COMP_HIDDEN
						break

				if(!runfolder)
					runfolder = new /datum/computer/folder(  )
					runfolder.name = "proc"
					runfolder.metadata["permission"] = COMP_HIDDEN
					if(!hd.root.add_file( runfolder ))
						//qdel(runfolder)
						runfolder.dispose()
						return 0
			if (allow_fork || !(program in src.processing))
				program = program.copy_file()
				if(!runfolder.add_file( program ))
					//qdel(program)
					program.dispose()
					return 0

			if(program.master != src)
				program.master = src

			if(istype(program, /datum/computer/file/mainframe_program/os))
				if (!src.os)
					src.os = program
				else
					//qdel(program)
					program.dispose()
					return 0

			if(!(program in src.processing))
				if (src.os == program && length(src.processing))
					src.processing.len++
					for (var/x = src.processing.len, x > 0, x--)
						var/datum/computer/file/mainframe_program/P = src.processing[x]
						if (istype(P))
							P.progid = x+1
						if (length(src.processing) == x)
							src.processing.len++
						src.processing[x+1] = P

					src.processing[1] = src.os
					src.os.progid = 1

				else
					var/success = 0
					for (var/x = 1, x <= src.processing.len, x++)
						if (!isnull(src.processing[x]))
							continue

						src.processing[x] = program
						program.progid = x
						success = 1
						break

					if (!success)
						src.processing += program
						program.progid = length(src.processing)

			if (user && !allow_fork)
				program.useracc = user
				user.current_prog = program

			if (caller)
				if (!program.useracc)
					program.useracc = caller.useracc
				program.parent_task = caller
				program.parent_id = caller.progid

			program.initialize(runparams)
			//program.initialized = 1
			return program

		unload_program(datum/computer/file/mainframe_program/program)
			if(!program)
				return 0

			if(program == src.os)
				return 0

			if (src.processing[src.processing.len] == program)
				src.processing -= program
			else if (program.progid && program.progid <= src.processing.len)
				src.processing[program.progid] = null
	//		if(src.active_program == program)
	//			src.active_program = src.host_program
			program.initialized = 0
			program.unloaded()

			if (program.holding_folder == src.runfolder)
				//qdel(program)
				program.dispose()

			return 1

		unload_all()
			src.os = null
			for(var/datum/computer/file/mainframe_program/M in src.processing)
				src.unload_program(M)

			return


		delete_file(datum/computer/file/theFile)
			if((!theFile) || (!theFile.holder) || (theFile.holder.read_only))
				//boutput(world, "Cannot delete :(")
				return 0

			//qdel(file)
			theFile.dispose()
			return 1

		relay_progsignal(var/datum/computer/file/mainframe_program/caller, var/progid, var/list/data = null, var/datum/computer/file/file)
			if (progid < 1 || progid > src.processing.len || !caller)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/P = src.processing[progid]
			if(!istype(P))
				return ESIG_GENERIC

			var/callID = src.processing.Find(caller)
			return P.receive_progsignal(callID, data, file)

		set_broken()
			icon_state = initial(src.icon_state)
			icon_state += "b"
			status |= BROKEN

		reconnect_all_devices()
			for (var/device_id in src.terminals)
				var/datum/terminal_connection/conn = src.terminals[device_id]
				if (istype(conn) && cmptext(conn.term_type, "hui_terminal"))
					continue

				reconnect_device(device_id)

			return ESIG_SUCCESS

		reconnect_device(var/device_netid)
			if (!device_netid)
				return ESIG_GENERIC

			device_netid = lowertext(device_netid)
			if (device_netid in src.terminals)
				var/datum/terminal_connection/conn = src.terminals[device_netid]
				src.os?.closed_connection(conn)
				src.terminals -= device_netid
				//qdel(conn)
				if (conn)
					conn.dispose()

			src.post_status(device_netid, "command", "term_connect", "device", src.device_tag)
			return ESIG_SUCCESS

		/*
		 *	Overview of startup process:
		 *		If we already have an OS reference, initialize it and return.
		 *		If not, begin looking for an OS file in memory (Of type /datum/computer/file/mainframe_program/os)
		 *			Ideally, there is a folder named "sys" in the root directory to look in.
		 *		If we can't find the OS there, we pass control over the our bootstrapping program.
		 */

		post_system()
			if(src.posted || !src.hd)
				return

			src.posted = 1

			if(src.os) //Let the starting programs set up vars or whatever
				src.os.initialize()

			else

				if (src.runfolder)
					//qdel(src.runfolder)
					src.runfolder.dispose()
					src.runfolder = null

				if(src.hd && src.hd.root)
					var/datum/computer/folder/sysfolder = null
					for (var/datum/computer/folder/F in src.hd.root.contents)
						if (F.name == "sys")
							sysfolder = F
							break

					if (sysfolder)
						var/datum/computer/file/mainframe_program/os/newos = locate(/datum/computer/file/mainframe_program/os) in sysfolder.contents
						if (istype(newos))
							src.visible_message("[src] beeps")
							newos.initialized = 0
							src.run_program(newos)
							return

					if(!istype(src.bootstrap))
						src.bootstrap = new src.setup_bootstrap_path

					//Run the bootstrapping code!
					if(bootstrap)
						src.run_program(bootstrap)

			return


/*
 *	Bootstrapping System
 */

/datum/computer/file/mainframe_program/os/bootstrap
	name = "NETBOOT"
	size = 4
	needs_holder = 0
	var/tmp/list/known_banks = list()
	var/tmp/current = null //Net ID of current bank.
	var/tmp/stage = 0
	var/tmp/ping_wait = 0
	var/tmp/stage_wait = 0
	var/tmp/rescan_wait = 0
	var/setup_system_directory = "/sys"
	var/setup_driver_directory = "/sys/drvr"
	var/setup_bin_directory = "/bin"

	disposing()
		known_banks = null
		..()

	initialize()
		if(..())
			return

		src.known_banks.len = 0

		src.clear_core()

		src.find_existing_databanks()

		src.stage_wait = 4
		src.stage = 1
		src.ping_wait = 4
		src.current = null
		SPAWN(1 DECI SECOND)
			src.master.post_status("ping","data","NETBOOT","net","[src.master.net_number]")
		return

	process()
		if(..())
			return

		if(src.ping_wait)
			src.ping_wait--
			return

		if(src.rescan_wait)
			if (--src.rescan_wait < 1)
				src.initialized = 0
				src.initialize()
			return

		if(src.stage_wait)
			src.stage_wait--
			if(stage_wait <= 0)
				stage = 0

		if(!stage)
			if(!known_banks.len)
				src.master.os = null
				src.handle_quit()
				//qdel (src)
				src.dispose()
				return

			new_current()
			src.message_term("command=bootreq",current)
			return
		return

	new_connection(datum/terminal_connection/conn)
		if(!istype(conn))
			return

		if(conn.term_type == "PNET_DATA_BANK" && !(conn.net_id in known_banks) )
			known_banks += conn.net_id

		return

	closed_connection(datum/terminal_connection/conn)
		if(!istype(conn)) return
		var/del_netid = conn.net_id
		if(del_netid in src.known_banks)
			src.known_banks -= del_netid
		return

	ping_reply(var/senderid,var/sendertype)
		if(..() || !ping_wait)
			return

		if( !(senderid in master.terminals) && (sendertype == "PNET_DATA_BANK" || sendertype == "HUI_TERMINAL"))
			SPAWN(rand(1,4))
				src.master.post_status(senderid,"command","term_connect","device",master.device_tag)
		return

	term_input(var/data, var/termid, var/datum/computer/file/the_file)
		if(..() || !stage)
			return

		var/datum/terminal_connection/conn = master.terminals[termid]
		if(!conn || !conn.term_type)
			return
		var/device_type = conn.term_type
		if(device_type == "PNET_DATA_BANK")
			var/list/commandlist = params2list(data)
			if(!commandlist || !commandlist["command"])
				return
			var/command = lowertext(commandlist["command"])

			//boutput(world, "\[[conn.net_id]]")

			switch(command)
				if("register")
					return

				if("file")
					//boutput(world, "FILE")
					if(!the_file)
						new_current()
						return

					var/datum/computer/file/archive/arc = the_file.copy_file()
					if(!istype(arc))
						//qdel(arc)
						arc.dispose()
						new_current()
						return

					var/datum/computer/file/mainframe_program/os/newos = locate() in arc.contained_files
					if(!istype(newos))
						//qdel(arc)
						arc.dispose()
						new_current()
						return

					var/datum/computer/folder/sysdir = parse_directory(src.setup_system_directory, src.holder.root, 1)
					var/datum/computer/folder/drivedir = parse_directory(src.setup_driver_directory, src.holder.root, 1)
					var/datum/computer/folder/bindir = parse_directory(src.setup_bin_directory, src.holder.root, 1)
					var/datum/computer/folder/srvdir = parse_directory("srv", sysdir, 1)
					if(!sysdir || !drivedir || !bindir || !srvdir)
						master.visible_message("[master] boops")
						master.os = null
						src.handle_quit()
						//dispose()
						src.dispose()
						return

					for(var/datum/computer/file/mainframe_program/MP in arc.contained_files)
						if (istype(MP, /datum/computer/file/mainframe_program/os))
							continue

						var/datum/computer/file/mainframe_program/MP_copy = MP.copy_file()
						if (istype(MP_copy, /datum/computer/file/mainframe_program/driver))
							if(get_computer_datum(MP_copy.name, drivedir))
								continue
							if(!drivedir.add_file(MP_copy))
								//qdel(MP_copy)
								MP_copy.dispose()
								break

						else if (istype(MP_copy, /datum/computer/file/mainframe_program/utility))
							if(get_computer_datum(MP_copy.name, bindir))
								continue
							if(!bindir.add_file(MP_copy))
								///qdel(MP_copy)
								MP_copy.dispose()
								break

						else if (istype(MP_copy, /datum/computer/file/mainframe_program/srv))
							if(get_computer_datum(MP_copy.name, sysdir))
								continue

							if(!srvdir.add_file(MP_copy))
								MP_copy.dispose()

						else
							if(get_computer_datum(MP_copy.name, sysdir))
								continue
							if(!sysdir.add_file(MP_copy))
								//qdel(MP_copy)
								MP_copy.dispose()
								break

					newos = newos.copy_file()
					if(sysdir.add_file(newos))
						master.os = null
						//qdel(arc)
						arc.dispose()
						master.visible_message("[master] beeps")
						master.run_program(newos)
						src.handle_quit()
						//dispose()
						src.dispose()
						return
					else
						//qdel(arc)
						//qdel(newos)
						if (arc)
							arc.dispose()
						if (newos)
							newos.dispose()
						/*
						src.quit()
						qdel(src)
						*/
						master.visible_message("[master] boops sadly.")
						src.rescan_wait = 20
						return


				if ("status")
					src.stage_wait = 1
					return

		return

	proc
		new_current() //Move on to a new current in the list.
			if(src.current)
				src.known_banks.Cut(1,2)
				src.current = null

			if(!known_banks.len)
				/*
				src.master.os = null
				src.quit()
				qdel(src)
				*/
				src.rescan_wait = 20
				return

			stage_wait = 4
			stage = 1
			src.current = known_banks[1]
			return

		clear_core() //Clear the core memory board.
			if(!src.holder || !src.holder.root)
				return 0

			for(var/datum/computer/C in src.holder.root.contents)
				if(C == src || C == src.holding_folder)
					continue

				//qdel(C)
				C.dispose()

			return 1

		find_existing_databanks() //Find databank connections already in master.terminals
			if(!src.master)
				return

			for(var/x in master.terminals)
				var/datum/terminal_connection/conn = master.terminals[x]
				if(!istype(conn))
					continue

				master.terminals -= x
				//qdel(conn)
				conn.dispose()

				var/tempx = x
				SPAWN(rand(1,4))
					src.master.post_status(tempx, "command", "term_disconnect")


			return


/*
 *	A little mass message proc for some SPOOKY ANTICS
 */

/proc/send_spooky_mainframe_message(var/the_message, var/a_spooky_custom_name)
	if (!the_message)
		return 1

	for (var/obj/machinery/networked/mainframe/aMainframe as anything in machine_registry[MACHINES_MAINFRAMES])
		LAGCHECK(LAG_LOW)
		if (aMainframe.z != 1)
			continue

		if (!aMainframe.os || !hascall(aMainframe.os, "message_all_users"))
			continue

		aMainframe.os:message_all_users(the_message, a_spooky_custom_name, 1)
		return 0

	return 2
