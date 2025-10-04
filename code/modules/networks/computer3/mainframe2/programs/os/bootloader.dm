/// When searching, the bootloader will message the current databank and request an OS file and any drivers on-tape.
#define STAGE_SEARCHING 0
/// When evaluating, the bootloader will await a reply from the current databank, then attempt to write any OS files and drivers passed into the mainframe's harddrive before starting the new OS.
#define STAGE_EVALUATING 1


/**
 *	The bootstrap loader, or bootloader, is ran when the mainframe cannot locate an OS file on its harddrive during the POST
 *	sequence. When ran, the bootloader disconnects all current mainframe connections, wipes the harddrive, and queries all
 *	available databanks for a backup OS and drivers. Typically used in conjunction with the mainframe recovery tapes.
 */
/datum/computer/file/mainframe_program/os/bootloader
	name = "NETBOOT"
	size = 4
	needs_holder = FALSE

	/**
	 *	The current stage of the bootloader.
	 *	- `STAGE_SEARCHING`: When searching, the bootloader will message the current databank and request an OS file and any drivers on-tape.
	 *	- `STAGE_EVALUATING`: When evaluating, the bootloader will await a reply from the current databank, then attempt to write any OS files and drivers passed into the mainframe's harddrive before starting the new OS.
	 */
	var/tmp/stage = STAGE_SEARCHING

	/// A list of the net IDs of databanks that responded to the bootloader's network ping.
	var/tmp/list/known_banks = null
	/// The net ID of the databank currently being searched for an OS backup.
	var/tmp/current = null

	/// The number of cycles for which the bootloader should wait before starting to search for databanks.
	var/tmp/ping_wait = 0
	/// The number of cycles for which the bootloader should remain in `STAGE_EVALUATING` before moving onto the next databank.
	var/tmp/stage_wait = 0
	/// The number of cycles for which the bootloader should wait before restarting the bootload process.
	var/tmp/rescan_wait = 0

/datum/computer/file/mainframe_program/os/bootloader/New()
	. = ..()
	src.known_banks = list()

/datum/computer/file/mainframe_program/os/bootloader/disposing()
	src.known_banks = null
	. = ..()

/datum/computer/file/mainframe_program/os/bootloader/initialize()
	if (..())
		return

	src.known_banks.Cut()
	src.clear_core()
	src.disconnect_devices()

	src.stage_wait = 4
	src.stage = STAGE_EVALUATING
	src.ping_wait = 4
	src.current = null

	SPAWN(1 DECI SECOND)
		src.master.post_status("ping", "data", "NETBOOT", "net", "[src.master.net_number]")

/datum/computer/file/mainframe_program/os/bootloader/process()
	if (..())
		return

	if (src.ping_wait)
		src.ping_wait--
		return

	if (src.rescan_wait)
		src.rescan_wait--
		if (src.rescan_wait <= 0)
			src.initialized = FALSE
			src.initialize()

		return

	if (src.stage_wait)
		src.stage_wait--
		if (src.stage_wait <= 0)
			src.stage = STAGE_SEARCHING

	if (src.stage == STAGE_SEARCHING)
		if (!length(src.known_banks))
			src.master.os = null
			src.handle_quit()
			src.dispose()
			return

		src.new_current()
		src.message_term("command=bootreq", src.current)

/datum/computer/file/mainframe_program/os/bootloader/new_connection(datum/terminal_connection/conn)
	if (!istype(conn) || (conn.term_type != "PNET_DATA_BANK"))
		return

	src.known_banks |= conn.net_id

/datum/computer/file/mainframe_program/os/bootloader/closed_connection(datum/terminal_connection/conn)
	if (!istype(conn))
		return

	src.known_banks -= conn.net_id

/datum/computer/file/mainframe_program/os/bootloader/ping_reply(senderid, sendertype)
	if (..() || !src.ping_wait)
		return

	if (src.master.terminals[senderid])
		return

	if ((sendertype != "PNET_DATA_BANK") && (sendertype != "HUI_TERMINAL"))
		return

	SPAWN(rand(1, 4))
		src.master.post_status(senderid, "command", "term_connect", "device", src.master.device_tag)

/datum/computer/file/mainframe_program/os/bootloader/term_input(data, termid, datum/computer/file/file)
	if (..() || (src.stage != STAGE_EVALUATING))
		return

	var/datum/terminal_connection/conn = src.master.terminals[termid]
	if (!conn?.term_type || (conn.term_type != "PNET_DATA_BANK"))
		return

	var/list/commandlist = params2list(data)
	if (!commandlist || !commandlist["command"])
		return

	switch (lowertext(commandlist["command"]))
		if ("status")
			src.stage_wait = 1

		if ("file")
			if (!file)
				src.new_current()
				return

			var/datum/computer/file/archive/archive = file.copy_file()
			if (!istype(archive))
				archive.dispose()
				src.new_current()
				return

			var/datum/computer/file/mainframe_program/os/new_os = locate() in archive.contained_files
			if (!istype(new_os))
				archive.dispose()
				src.new_current()
				return

			var/datum/computer/folder/sys_folder = src.parse_directory(setup_filepath_system, src.holder.root, TRUE)
			var/datum/computer/folder/drive_folder = src.parse_directory(setup_filepath_drivers_proto, src.holder.root, TRUE)
			var/datum/computer/folder/bin_folder = src.parse_directory(setup_filepath_commands, src.holder.root, TRUE)
			var/datum/computer/folder/srv_folder = src.parse_directory("srv", sys_folder, TRUE)

			if (!sys_folder || !drive_folder || !bin_folder || !srv_folder)
				src.master.visible_message("[src.master] boops")
				src.master.os = null
				src.handle_quit()
				src.dispose()
				return

			for (var/datum/computer/file/mainframe_program/program in archive.contained_files)
				if (istype(program, /datum/computer/file/mainframe_program/os))
					continue

				program = program.copy_file()

				// If the program is a driver, add it to the driver directory.
				if (istype(program, /datum/computer/file/mainframe_program/driver))
					if (src.get_computer_datum(program.name, drive_folder))
						continue

					if (!drive_folder.add_file(program))
						program.dispose()
						break

				// If the program is a utility, add it to the binaries directory.
				else if (istype(program, /datum/computer/file/mainframe_program/utility))
					if (src.get_computer_datum(program.name, bin_folder))
						continue

					if (!bin_folder.add_file(program))
						program.dispose()
						break

				// If the program is a service, add it to the service directory.
				else if (istype(program, /datum/computer/file/mainframe_program/srv))
					if (src.get_computer_datum(program.name, srv_folder))
						continue

					if (!srv_folder.add_file(program))
						program.dispose()
						break

				// Otherwise add the program to the system directory.
				else
					if (src.get_computer_datum(program.name, sys_folder))
						continue

					if (!sys_folder.add_file(program))
						program.dispose()
						break

			new_os = new_os.copy_file()
			if (sys_folder.add_file(new_os))
				src.master.os = null
				archive.dispose()
				src.master.visible_message("[src.master] beeps")
				src.master.run_program(new_os)
				src.handle_quit()
				src.dispose()

			else
				archive?.dispose()
				new_os?.dispose()
				src.master.visible_message("[src.master] boops sadly.")
				src.rescan_wait = 20

/// Move onto evaluting the next databank in the known banks list.
/datum/computer/file/mainframe_program/os/bootloader/proc/new_current()
	if (src.current)
		src.known_banks.Cut(1, 2)
		src.current = null

	if (!length(src.known_banks))
		src.rescan_wait = 20
		return

	src.stage_wait = 4
	src.stage = STAGE_EVALUATING
	src.current = src.known_banks[1]

/// Wipe the mainframe's harddrive.
/datum/computer/file/mainframe_program/os/bootloader/proc/clear_core()
	if (!src.holder?.root)
		return FALSE

	for (var/datum/computer/C as anything in src.holder.root.contents)
		if ((C == src) || (C == src.holding_folder))
			continue

		C.dispose()

	return TRUE

/// Disconnect all devices currently connected to the mainframe.
/datum/computer/file/mainframe_program/os/bootloader/proc/disconnect_devices()
	if (!src.master)
		return

	for (var/device_id as anything in src.master.terminals)
		var/datum/terminal_connection/conn = src.master.terminals[device_id]
		if (!istype(conn))
			continue

		src.master.terminals -= device_id
		conn.dispose()

		SPAWN(rand(1, 4))
			src.master.post_status(device_id, "command", "term_disconnect")


#undef STAGE_SEARCHING
#undef STAGE_EVALUATING
