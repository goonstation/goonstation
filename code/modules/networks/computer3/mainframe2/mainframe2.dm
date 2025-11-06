/**
 *	Terminal connection datums represent an active connection between the mainframe and another networked device.
 */
/datum/terminal_connection
	/// The master device that this device is connected to.
	var/obj/machinery/networked/master = null
	/// The network ID of the connected device.
	var/net_id = null
	/// The device tag of the connected device (PNET_MAINFRAME, HUI_TERMINAL, etc).
	var/term_type = null

/datum/terminal_connection/New(obj/machinery/networked/master, net_id, term_type)
	. = ..()

	if (istype(master))
		src.master = master

	src.net_id = net_id
	src.term_type = term_type

/datum/terminal_connection/disposing()
	src.master = null
	. = ..()





/**
 *	The physical mainframe, responsible for managing network connections, disconnections, and timeouts; for loading, unloading
 *	and running mainframe programs; and for passing signals to, from, and between mainframe programs.
 */
/obj/machinery/networked/mainframe
	name = "Mainframe"
	desc = "A mainframe computer. It's pretty big!"
	density = TRUE
	anchored = ANCHORED
	icon_state = "dwaine"
	device_tag = "PNET_MAINFRAME"
	timeout = 30
	req_access = list(access_heads)
	machine_registry_idx = MACHINES_MAINFRAMES
	power_usage = 500

	/// An associative list of terminal connections made to this mainframe, indexed by the device's network ID.
	var/list/datum/terminal_connection/terminals = null
	/// An associative list of terminal connections currently set to timeout, indexed by the device's network ID.
	var/list/datum/terminal_connection/timeout_list = null
	/// A list of mainframe programs currently running. Each program will have its `process` proc called in sync with the machinery processing loop.
	var/list/datum/computer/file/mainframe_program/processing = null

	/// The current operating system of this mainframe.
	var/datum/computer/file/mainframe_program/os/os = null
	/// This mainframe's bootloader, instantiated when a main OS cannot be located on the memory card.
	var/datum/computer/file/mainframe_program/os/bootloader/bootloader = null
	/// The storage folder used to contain currently running programs.
	var/datum/computer/folder/runfolder = null
	/// The internal storage for this mainframe.
	var/obj/item/disk/data/memcard/hd = null

	/// Whether the Power-On Self-Test sequence has completed. Set to `TRUE` initially so it doesn't freak out during powernet generation.
	var/posted = TRUE

	/// The storage capacity of this mainframe's internal storage.
	var/setup_drive_size = 4096
	/// The typepath to use for this mainframe's harddrive.
	var/setup_drive_type = /obj/item/disk/data/memcard
	/// The typepath to use for this mainframe's bootloader.
	var/setup_bootloader_path = /datum/computer/file/mainframe_program/os/bootloader

/obj/machinery/networked/mainframe/zeta
	setup_drive_type = /obj/item/disk/data/memcard/main2

/obj/machinery/networked/mainframe/New()
	. = ..()

	src.terminals = list()
	src.processing = list()
	src.timeout_list = list()

	SPAWN(1 SECOND)
		src.net_id = global.generate_net_id(src)

		if (!src.link)
			var/obj/machinery/power/data_terminal/test_link = locate() in get_turf(src)
			if (test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
				src.link = test_link
				src.link.master = src

		if (!src.hd && (src.setup_drive_size > 0))
			if (src.setup_drive_type)
				src.hd = new src.setup_drive_type(src)
			else
				src.hd = new /obj/item/disk/data/memcard(src)

			src.hd.file_amount = src.setup_drive_size

		if (ispath(src.setup_bootloader_path))
			src.bootloader = new src.setup_bootloader_path()
			src.bootloader.master = src

		sleep(5.4 SECONDS)
		src.posted = FALSE
		src.post_system()

/obj/machinery/networked/mainframe/disposing()
	if (src.terminals)
		for (var/device_id as anything in src.terminals)
			src.terminals[device_id]?.dispose()

		src.terminals.Cut()
		src.terminals = null

	if (src.os)
		src.os.dispose()
		src.os = null

	if (src.bootloader)
		src.bootloader.dispose()
		src.bootloader = null

	if (src.runfolder)
		src.runfolder = null

	if (src.hd)
		src.hd.dispose()
		src.hd = null

	if (src.processing)
		src.processing.Cut()
		src.processing = null

	if (src.timeout_list)
		src.timeout_list.Cut()
		src.timeout_list = null

	. = ..()

/obj/machinery/networked/mainframe/attack_ai(mob/user)
	return

/obj/machinery/networked/mainframe/attack_hand(mob/user)
	if (user.stat || user.restrained())
		return

	if (src.status & BROKEN)
		if (!src.hd)
			return

		boutput(user, SPAN_ALERT("The mainframe is trashed, but the memory core could probably salvaged."))
		return

	var/dat = "<html><head><title>Mainframe Access Panel</title></head><body><hr>"
	dat += "<b>ACTIVE:</b> [src.os ? "YES" : "NO"]<br>"
	dat += "<b>BOOTING:</b> [(src.bootloader && istype(src.os, src.bootloader.type)) ? "YES" : "NO"]<br><br>"

	if (src.status & NOPOWER)
		dat += "<b>Memory Core:</b> <a href='byond://?src=\ref[src];core=1'>[src.hd ? "LOADED" : "---------"]</a><br>"
		dat += "Core Shield Maglock is <b>OFF</b><hr>[src.net_switch_html()]<hr>"
	else
		dat += "<b>Memory Core:</b> [src.hd ? "LOADED" : "---------"]<br>"
		dat += "Core Shield Maglock is <b>ON</b><hr>"


	user.Browse(dat, "window=mainframe;size=245x202")
	global.onclose(user, "mainframe")

/obj/machinery/networked/mainframe/Topic(href, href_list)
	if ((src.status & BROKEN) || !isturf(src.loc) || (BOUNDS_DIST(src, usr) != 0) || usr.stat || usr.restrained())
		return

	src.add_dialog(usr)

	if (href_list["core"])
		if (!(src.status & NOPOWER))
			boutput(usr, SPAN_ALERT("The electromagnetic lock is still on!"))
			return

		if (src.hd)
			src.hd.set_loc(src.loc)
			boutput(usr, "You remove the memory core from the mainframe.")
			usr.unlock_medal("421", TRUE)
			src.status |= MAINT
			src.unload_all()
			src.hd = null
			src.runfolder = null
			src.posted = FALSE

		else
			var/obj/item/I = usr.equipped()

			if (istype(I, /obj/item/disk/data/memcard))
				usr.drop_item()
				I.set_loc(src)
				src.hd = I
				src.status &= ~MAINT
				boutput(usr, "You insert [I].")

			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I

				if (istype(mag.holding, /obj/item/disk/data/memcard))
					I = mag.holding
					mag.dropItem(FALSE)
					I.set_loc(src)
					src.hd = I
					src.status &= ~MAINT
					boutput(usr, "You insert [I].")

	else if (href_list["dipsw"] && (src.status & NOPOWER))
		var/switchNum = text2num_safe(href_list["dipsw"])
		if ((switchNum < 1) || (switchNum > 8))
			return TRUE

		switchNum = round(switchNum)
		if (src.net_number & switchNum)
			src.net_number &= ~switchNum
		else
			src.net_number |= switchNum

	src.updateUsrDialog()
	src.add_fingerprint(usr)

/obj/machinery/networked/mainframe/attackby(obj/item/W, mob/user)
	if (!ispryingtool(W))
		return ..()

	if (!(src.status & BROKEN))
		return

	if (!src.hd)
		boutput(user, SPAN_ALERT("The memory core has already been removed."))
		return

	src.status |= MAINT
	src.unload_all()
	src.hd.set_loc(src.loc)
	src.hd = null
	src.posted = FALSE

	boutput(user, "You pry out the memory core.")
	src.updateUsrDialog()

/obj/machinery/networked/mainframe/process()
	set waitfor = 0
	. = ..()

	if ((src.status & (NOPOWER | BROKEN | MAINT)) || !src.processing)
		return

	if (prob(3))
		SPAWN(1 DECI SECOND)
			playsound(src.loc, pick(global.ambience_computer), 50, 1)

	for (var/i in 1 to length(src.processing))
		var/datum/computer/file/mainframe_program/program = src.processing[i]
		if (!istype(program))
			continue

		if (program.disposed)
			src.processing[i] = null
			continue

		try
			program.process()

		catch(var/exception/e)
			if (!findtext(e.name, "Maximum recursion level reached"))
				throw e

			// Warn all connected users that the mainframe has crashed.
			if (istype(src.os, /datum/computer/file/mainframe_program/os/kernel))
				var/datum/computer/file/mainframe_program/os/kernel/kernel = src.os
				kernel.message_all_users("|nA program encountered a critical error (maximum recursion). Rebooting the mainframe.|n", "System", TRUE)

			src.reboot_mainframe()

	if (src.timeout == 0)
		src.timeout = initial(src.timeout)
		src.timeout_alert = FALSE

		for (var/id as anything in src.timeout_list)
			var/datum/terminal_connection/conn = src.terminals[id]
			src.terminals -= id

			if (!conn)
				continue

			src.os?.closed_connection(conn)
			conn.dispose()

	else
		src.timeout--

		if ((src.timeout <= 5) && !src.timeout_alert)
			src.timeout_alert = TRUE
			src.timeout_list = src.terminals.Copy()

			for (var/id as anything in src.timeout_list)
				src.post_status(id, "command", "term_ping", "data", "reply")

/obj/machinery/networked/mainframe/receive_signal(datum/signal/signal)
	if (src.status & (NOPOWER | BROKEN | MAINT) || !src.link)
		return

	if (!src.net_id || !signal || signal.encryption || (signal.transmission_method != TRANSMISSION_WIRE))
		return

	var/target = signal.data["sender"]

	// The sender doen't need to target us specifically to ping us.
	// Otherwise, if the sender isn't addressing us, ignore them.
	if (signal.data["address_1"] != src.net_id)
		if ((signal.data["address_1"] == "ping") && ((signal.data["net"] == null) || ("[signal.data["net"]]" == "[src.net_number]")) && signal.data["sender"])
			SPAWN(0.5 SECONDS)
				src.post_status(target, "command", "ping_reply", "device", src.device_tag, "netid", src.net_id)

		return

	var/sigcommand = lowertext(signal.data["command"])
	if (!sigcommand || !signal.data["sender"])
		return

	switch (sigcommand)
		if ("term_connect")
			// If the terminal is already connected, something may be wrong, so disconnect them.
			if (src.terminals[target])
				var/datum/terminal_connection/conn = src.terminals[target]
				src.terminals -= target
				src.os?.closed_connection(conn)
				conn.dispose()

				SPAWN(0.3 SECONDS)
					src.post_status(target, "command", "term_disconnect")

				return

			var/devtype = signal.data["device"]
			if (!devtype)
				return

			// Create a new connection.
			var/datum/terminal_connection/new_conn = new /datum/terminal_connection(src, target, devtype)
			src.terminals[target] = new_conn
			if (signal.data["data"] != "noreply")
				src.post_status(target, "command", "term_connect", "data", "noreply")

			// Alert the OS of the new connection.
			if (src.os)
				var/datum/computer/connect_file = signal.data_file?.copy_file()
				src.os.new_connection(new_conn, connect_file)
				connect_file?.dispose()

		if ("term_message", "term_file")
			// Don't accept messages or files from unconnected terminals.
			if (!src.terminals[target] || !src.os)
				return

			var/data = signal.data["data"]
			if (!data)
				return

			src.os.term_input(data, target, signal.data_file?.copy_file())
			if (!isnull(usr))
				logTheThing(LOG_STATION, usr, "message '[html_encode(data)]' sent to [src] [log_loc(src)] from [signal.source] [log_loc(signal.source)]")

		if ("term_break")
			if (!src.terminals[target] || !src.os)
				return

			src.os.term_input(1, target, null, TRUE)

		if ("term_ping")
			if (!src.terminals[target])
				SPAWN(0.3 SECONDS)
					src.post_status(target, "command", "term_disconnect")

				return

			if (src.timeout_list[target])
				src.timeout_list -= target

			if (signal.data["data"] == "reply")
				src.post_status(target, "command", "term_ping")

		if ("term_disconnect")
			if (!src.terminals[target])
				return

			var/datum/terminal_connection/conn = src.terminals[target]
			src.terminals -= target
			src.os?.closed_connection(conn)
			conn.dispose()

		if ("ping_reply")
			if (!src.os)
				return

			src.os.ping_reply(signal.data["netid"], signal.data["device"])

/obj/machinery/networked/mainframe/power_change()
	if (src.status & BROKEN)
		src.icon_state = initial(src.icon_state) + "b"
		return

	if (src.powered())
		src.icon_state = initial(src.icon_state)
		src.status &= ~NOPOWER
		src.post_system() // Will simply return if POSTed already.
		return

	SPAWN(rand(0, 15))
		src.icon_state = initial(src.icon_state) + "0"
		src.status |= NOPOWER
		src.posted = FALSE
		src.os = null

/obj/machinery/networked/mainframe/clone()
	var/obj/machinery/networked/mainframe/clone = ..()
	if (!clone)
		return

	clone.setup_bootloader_path = src.setup_bootloader_path
	clone.hd = src.hd?.clone()

	return clone

/obj/machinery/networked/mainframe/meteorhit(obj/O)
	if (src.status & BROKEN)
		src.dispose()

	src.set_broken()
	var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
	smoke.set_up(5, 0, src)
	smoke.start()

/obj/machinery/networked/mainframe/ex_act(severity)
	switch (severity)
		if (1)
			src.dispose()
		if (2)
			if (prob(50))
				src.set_broken()
		if (3)
			if (prob(25))
				src.set_broken()

/obj/machinery/networked/mainframe/blob_act(power)
	if (!prob(power * 2.5))
		return

	src.set_broken()
	src.set_density(FALSE)

/// Initialise and start running a mainframe program, adding it to the processing list and runfolder.
/obj/machinery/networked/mainframe/proc/run_program(datum/computer/file/mainframe_program/program, datum/mainframe2_user_data/user, datum/computer/file/mainframe_program/caller_prog, runparams, allow_fork = FALSE)
	if (!src.hd || !program || (!program.holder && program.needs_holder))
		return FALSE

	if (!src.runfolder)
		// Attempt to locate an existing runfolder.
		for (var/datum/computer/folder/F in src.hd.root.contents)
			if (F.name != "proc")
				continue

			src.runfolder = F
			src.runfolder.metadata["permission"] = COMP_HIDDEN
			break

		// If a runfolder can't be found, attempt to create a new one.
		if (!src.runfolder)
			src.runfolder = new /datum/computer/folder()
			src.runfolder.name = "proc"
			src.runfolder.metadata["permission"] = COMP_HIDDEN

			if (!src.hd.root.add_file(src.runfolder))
				src.runfolder.dispose()
				return FALSE

	// Add the program to the runfolder.
	if (allow_fork || !(program in src.processing))
		program = program.copy_file()
		if (!src.runfolder.add_file(program))
			program.dispose()
			return FALSE

	program.master = src

	if (istype(program, /datum/computer/file/mainframe_program/os))
		if (src.os)
			program.dispose()
			return FALSE

		src.os = program

	if (!(program in src.processing))
		// If the program is the OS, insert it at the start of the processing list.
		if ((src.os == program) && length(src.processing))
			src.processing.Insert(1, src.os)

			// Update the program ID of each program in the list.
			for (var/i in 1 to length(src.processing))
				var/datum/computer/file/mainframe_program/P = src.processing[i]
				if (!istype(P))
					continue

				P.progid = i

		// Otherwise add the program to the processing list, replacing any null entries before extending the list.
		else
			var/null_index = src.processing.Find(null)
			if (null_index)
				src.processing[null_index] = program
				program.progid = null_index
			else
				src.processing += program
				program.progid = length(src.processing)

	if (user && !allow_fork)
		program.useracc = user
		user.current_prog = program

	if (caller_prog)
		program.parent_task = caller_prog
		program.parent_id = caller_prog.progid
		program.useracc ||= caller_prog.useracc

	program.initialize(runparams)
	return program

/// Unload all mainframe programs, removing them from the processing list and runfolder. Also logs out all users.
/obj/machinery/networked/mainframe/proc/unload_all()
	// Logout all users so that when the mainframe reboots, they can log into their old user account, instead of creating a new user.
	if (istype(src.os, /datum/computer/file/mainframe_program/os/kernel))
		var/datum/computer/file/mainframe_program/os/kernel/kernel = src.os
		kernel.logout_all_users(FALSE)

	src.os = null
	for (var/datum/computer/file/mainframe_program/P in src.processing)
		src.unload_program(P)

/// Unload a mainframe program, removing it from the processing list and runfolder.
/obj/machinery/networked/mainframe/proc/unload_program(datum/computer/file/mainframe_program/program)
	if (!program || (program == src.os))
		return FALSE

	var/processing_length = length(src.processing)
	if (src.processing[processing_length] == program)
		src.processing -= program
	else if (program.progid && (program.progid <= processing_length))
		src.processing[program.progid] = null

	program.initialized = FALSE
	program.unloaded()

	if (program.holding_folder == src.runfolder)
		program.dispose()

	return TRUE

/**
 *	Relay a signal between two mainframe programs.
 *	- `caller_prog`: The mainframe program sending the signal.
 *	- `progid`: The program ID of the recipient program.
 *	- `data`: A key-value list of data to pass to the recipient program.
 *	- `file`: An optional computer file to pass to the recipient program.
 */
/obj/machinery/networked/mainframe/proc/relay_progsignal(datum/computer/file/mainframe_program/caller_prog, progid, list/data, datum/computer/file/file)
	if ((progid < 1) || (progid > length(src.processing)) || !caller_prog)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/P = src.processing[progid]
	if (!istype(P))
		return ESIG_GENERIC

	return P.receive_progsignal(caller_prog.progid, data, file)

/// Disconnect and issue a reconnect request to all currently connected devices, excluding computer terminals.
/obj/machinery/networked/mainframe/proc/reconnect_all_devices()
	for (var/device_id as anything in src.terminals)
		var/datum/terminal_connection/conn = src.terminals[device_id]
		if (istype(conn) && cmptext(conn.term_type, "hui_terminal"))
			continue

		src.reconnect_device(device_id)

	return ESIG_SUCCESS

/// Disconnect and issue a reconnect request to a specific device.
/obj/machinery/networked/mainframe/proc/reconnect_device(device_id)
	if (!device_id)
		return ESIG_GENERIC

	device_id = lowertext(device_id)

	if (src.terminals[device_id])
		var/datum/terminal_connection/conn = src.terminals[device_id]
		src.terminals -= device_id
		src.os?.closed_connection(conn)
		conn.dispose()

	src.post_status(device_id, "command", "term_connect", "device", src.device_tag)
	return ESIG_SUCCESS

/// Unload all mainframe programs and reboot the mainframe.
/obj/machinery/networked/mainframe/proc/reboot_mainframe()
	src.unload_all()
	src.posted = FALSE
	src.post_system()
	src.reconnect_all_devices()

/// Run the mainframe's Power-On Self-Test sequence, setting up the mainframe's OS.
/obj/machinery/networked/mainframe/proc/post_system()
	if (src.posted || !src.hd)
		return

	src.posted = TRUE

	// If an OS reference already exists, initialise it and return.
	if (src.os)
		src.os.initialize()
		return

	if (src.runfolder)
		src.runfolder.dispose()
		src.runfolder = null

	if (!src.hd || !src.hd.root)
		return

	// Attempt to find an OS file in the SYS folder.
	var/datum/computer/folder/sysfolder = null
	for (var/datum/computer/folder/F in src.hd.root.contents)
		if (F.name != "sys")
			continue

		sysfolder = F
		break

	// If found, use that OS file as the new OS.
	if (sysfolder)
		var/datum/computer/file/mainframe_program/os/new_os = locate(/datum/computer/file/mainframe_program/os) in sysfolder.contents
		if (istype(new_os))
			src.visible_message("[src] beeps")
			new_os.initialized = FALSE
			src.run_program(new_os)
			return

	// Otherwise run the bootloader.
	if (!istype(src.bootloader))
		src.bootloader = new src.setup_bootloader_path()

	src.run_program(src.bootloader)
