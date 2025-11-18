/**
 *	The kernel is the computer program at the core of the OS and is responsible for managing interactions with all hardware
 *	devices, such as terminals, databanks, scanners and so forth through device drivers; for handling inputs; for creating and
 *	terminating connections; for the execution of system calls; and for other basic system services.
 */
/datum/computer/file/mainframe_program/os/kernel
	name = "Kernel"
	size = 16

	/// A list of cached DWAINE syscall datums, indexed by their ID.
	var/list/datum/dwaine_syscall/syscalls = null

	/// A list of users currently connected to the OS, indexed by their user ID.
	var/tmp/list/datum/mainframe2_user_data/users = null
	/// The maximum number of users that may connect to the OS.
	var/tmp/max_users = 0
	/// The `/sys` directory that the kernel is located in.
	var/tmp/datum/computer/folder/sys_folder = null
	/// A list of drivers that are open to receiving messages from the OS.
	var/tmp/list/datum/computer/file/mainframe_program/driver/processing_drivers = null

	/// The number of cycles for which the kernel should reply to any pings made.
	var/tmp/ping_accept = 0
	/// How often the mainframe should ping the network, in cycles.
	var/tmp/rescan_period = 60
	/// The current number of cycles until the mainframe should ping the network.
	var/tmp/rescan_timer = 0

	/// The default program name of the login program.
	var/setup_progname_login = "login"
	/// The default program name of the shell.
	var/setup_progname_shell = "msh"
	/// The default program name of the init program.
	var/setup_progname_init = "init"

/datum/computer/file/mainframe_program/os/kernel/New()
	src.processing_drivers = list()
	src.rescan_timer = src.rescan_period

	. = ..()

/datum/computer/file/mainframe_program/os/kernel/disposing()
	src.users = null
	src.sys_folder = null
	src.processing_drivers = null

	if (src.master?.os == src)
		src.master.os = null

	for (var/datum/dwaine_syscall/syscall as anything in src.syscalls)
		qdel(syscall)

	src.syscalls = null

	. = ..()

/datum/computer/file/mainframe_program/os/kernel/initialize()
	if (..())
		return

	src.users = list()
	src.processing_drivers = list()

	src.syscalls = list()
	for (var/syscall_type as anything in concrete_typesof(/datum/dwaine_syscall))
		var/datum/dwaine_syscall/syscall = new syscall_type(src)
		if (src.syscalls.len < syscall.id)
			src.syscalls.len = syscall.id

		src.syscalls[syscall.id] = syscall

	src.sys_folder = src.parse_directory(setup_filepath_system, src.holder.root, TRUE)
	if (!src.sys_folder)
		src.max_users = 0
		return

	src.sys_folder.metadata["permission"] = COMP_HIDDEN

	src.max_users = max(round((src.holder.file_amount - 128) / 32), 0)
	// Attempt to start up the kernel. If it fails, return and prevent users from connecting.
	if (src.initialize_drivers() || src.initialize_users())
		src.max_users = 0
		return

	src.ping_accept = 4
	src.master.timeout = 1
	src.master.timeout_alert = FALSE
	SPAWN(0.5 SECONDS)
		src.master.post_status("ping", "data", "DWAINE", "net", "[src.master.net_number]")

	// Run "init" program, if present.
	src.master.run_program(src.get_file_name(src.setup_progname_init, src.sys_folder), null, src)

// Input from any terminal, be it user or device.
/datum/computer/file/mainframe_program/os/kernel/term_input(data, termid, datum/computer/file/file, is_break = FALSE)
	if (..())
		return

	if (!src.users[termid])
		var/datum/computer/file/mainframe_program/driver/driver = src.parse_file_directory("[setup_filepath_drivers]/[termid]", src.holder.root, FALSE)
		if (istype(driver))
			driver.terminal_input(data, file)

		return

	var/datum/mainframe2_user_data/user = src.users[termid]
	if (!istype(user))
		src.login_user(termid, "TEMP")
		return

	if (is_break)
		user.current_prog.receive_progsignal(1, list("command" = DWAINE_COMMAND_BREAK, "user" = termid))
		return

	if (user.current_prog)
		if (file)
			user.current_prog.receive_progsignal(1, list("command" = DWAINE_COMMAND_RECVFILE, "user" = termid), file)
		else
			user.current_prog.input_text(data)
	else
		if (user.full_user)
			user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_shell, src.sys_folder), user, src)
		else
			user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_login, src.sys_folder), user, src)

// Called by the mainframe object when a new terminal connection datum is ready for us to handle.
/datum/computer/file/mainframe_program/os/kernel/new_connection(datum/terminal_connection/conn, datum/computer/file/connect_file)
	if (!conn)
		return

	var/term_type = lowertext(conn.term_type)
	if (dd_hasprefix(term_type, "pnet_"))
		term_type = copytext(term_type, 6)

	if (term_type == "hui_terminal")
		var/datum/mainframe2_user_data/user = src.users[conn.net_id]

		// If the user does not yet exist, set them up as a temporary user so that they may log in.
		if (!istype(user))
			src.login_temp_user(conn.net_id, connect_file)
			return

		// No need to set up a program if the user is already running one.
		if (user.current_prog)
			return

		// If they are logged in with nothing currently running for them, then send them to the shell.
		if (user.full_user)
			user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_shell, src.sys_folder, src))

		// If they already exist, but haven't logged in, then give them a chance to do that now.
		else
			user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_login, src.sys_folder, src))

		return

	// Find relevant directories for device initialisation.
	var/datum/computer/folder/prototype_folder = src.parse_directory(setup_filepath_drivers_proto, src.holder.root, TRUE)
	var/datum/computer/folder/device_folder = src.parse_directory(setup_filepath_drivers, src.holder.root, TRUE)
	if (!prototype_folder || !device_folder)
		return

	// Ensure that we have a known device prototype.
	var/datum/computer/file/mainframe_program/driver/driver = src.get_file_name(term_type, prototype_folder)
	if (!istype(driver))
		return

	// Build the working driver instance in the device folder.
	driver = driver.copy_file()
	driver.name = conn.net_id
	driver.termtag = term_type
	if (src.get_file_name(driver.name, device_folder) || !device_folder.add_file(driver))
		driver.dispose()
		return

	driver.master = src.master
	src.initialize_driver(driver, connect_file)

// Called by mainframe object when one of the terminal connection datums is about to be deleted.
/datum/computer/file/mainframe_program/os/kernel/closed_connection(datum/terminal_connection/conn)
	if (!conn)
		return

	if (!src.users[conn.net_id])
		var/datum/computer/file/file = src.parse_file_directory("[setup_filepath_drivers]/[conn.net_id]", src.holder.root, 0)
		file?.dispose()

	var/datum/mainframe2_user_data/user = src.users[conn.net_id]
	if (istype(user))
		src.logout_user(user, TRUE)

/datum/computer/file/mainframe_program/os/kernel/ping_reply(senderid, sendertype)
	if (..() || !src.ping_accept)
		return

	if (src.master.status & (NOPOWER | BROKEN | MAINT))
		return

	if (!(src.holder in src.master.contents))
		return

	if (senderid in src.master.terminals)
		return

	if (dd_hasprefix(sendertype, "pnet_"))
		sendertype = copytext(sendertype, 6)

	if (!src.get_file_name(sendertype, src.parse_directory(setup_filepath_drivers_proto, src.holder.root, FALSE)))
		return

	SPAWN(rand(1, 4))
		src.master.post_status(senderid, "command", "term_connect", "device", src.master.device_tag)

// Receive a signal sent by another program or driver on the mainframe. This is where system calls are interpreted.
/datum/computer/file/mainframe_program/os/kernel/receive_progsignal(sendid, list/data, datum/computer/file/file)
	if (!src.master || (sendid == src.progid))
		return ESIG_GENERIC

	if (!isnum(data["command"]))
		return ESIG_GENERIC

	if (data["command"] > src.syscalls.len)
		return ESIG_BADCOMMAND

	var/datum/dwaine_syscall/syscall = src.syscalls[data["command"]]
	if (!istype(syscall))
		return ESIG_BADCOMMAND

	return syscall.execute(sendid, data, file)

/datum/computer/file/mainframe_program/os/kernel/process()
	if (..())
		return

	if (src.ping_accept)
		src.ping_accept--

	if (src.rescan_timer && !--src.rescan_timer)
		src.rescan_timer = src.rescan_period
		src.ping_accept = 4

		SPAWN(1 DECI SECOND)
			src.master.post_status("ping", "data", "DWAINE", "net", "[src.master.net_number]")

/// Initialise all users and user data, logging in connected terminals, and setting up home directories and user record files.
/datum/computer/file/mainframe_program/os/kernel/proc/initialize_users()
	for (var/uid in src.users)
		var/datum/mainframe2_user_data/user = src.users[uid]
		user.dispose()

	src.users = list()

	var/datum/computer/folder/user_folder = src.parse_directory(setup_filepath_users, src.holder.root, TRUE)
	var/datum/computer/folder/home_folder = src.parse_directory(setup_filepath_users_home, src.holder.root, TRUE)
	if (!user_folder || !home_folder)
		return TRUE

	user_folder.metadata["permission"] = COMP_HIDDEN

	for (var/i in src.master.terminals)
		var/datum/terminal_connection/conn = src.master.terminals[i]
		if (!istype(conn) || (conn.term_type != "HUI_TERMINAL"))
			continue

		src.login_temp_user(conn.net_id)

	for (var/datum/computer/file/record/user_record in user_folder.contents)
		// Dispose of the record if it is invalid.
		if (isnull(user_record.fields["name"]) || isnull(user_record.fields["id"]) || isnull(user_record.fields["group"]))
			user_record.dispose()
			continue

		// Ensure that all files are correctly named.
		if (!dd_hassuffix(user_record.fields["id"]))
			if (!isnull(src.get_file_name("usr[user_record.fields["id"]]", user_folder)))
				user_record.dispose()
				continue

			user_record.name = "usr[user_record.fields["id"]]"

		// Create a home directory for this user.
		var/datum/computer/folder/new_home = src.get_folder_name("usr[user_record.fields["name"]]", home_folder)
		if (istype(new_home))
			return FALSE

		new_home = new /datum/computer/folder()
		new_home.name = "usr[user_record.fields["name"]]"
		new_home.metadata["owner"] = user_record.fields["name"]
		new_home.metadata["permission"] = COMP_ROWNER | COMP_WOWNER | COMP_DOWNER

		user_record.metadata["owner"] = user_record.fields["name"]
		user_record.metadata["permission"] = COMP_ROWNER | COMP_WOWNER

		if (!home_folder.add_file(new_home))
			new_home.dispose()
			continue

	return FALSE

/// Log a connection in as a temporary user, starting the full login program, or logging in fully if a valid login record is provided.
/datum/computer/file/mainframe_program/os/kernel/proc/login_temp_user(user_netid, datum/computer/file/record/login_record, datum/computer/file/mainframe_program/caller_prog_override)
	if (length(src.users) >= src.max_users)
		return TRUE

	if (!user_netid)
		return TRUE

	var/datum/computer/file/mainframe_program/helloprog = src.get_file_name(src.setup_progname_login, src.sys_folder)
	if (!istype(helloprog))
		return TRUE

	var/datum/mainframe2_user_data/new_user = new /datum/mainframe2_user_data()
	new_user.user_name = "TEMP"
	new_user.user_id = user_netid
	src.users[new_user.user_id] = new_user

	if (istype(login_record) && login_record.fields && login_record.fields["registered"] && login_record.fields["assignment"] && !src.login_user(new_user, login_record.fields["registered"], FALSE))
		var/datum/computer/file/mainframe_program/shellbase = src.get_file_name(src.setup_progname_shell, src.sys_folder)
		if (istype(shellbase))
			src.master.run_program(shellbase, new_user, istype(caller_prog_override) ? caller_prog_override : src)
			return FALSE

	helloprog = src.master.run_program(helloprog, new_user, istype(caller_prog_override) ? caller_prog_override : src)
	if (!istype(helloprog))
		return TRUE

	return FALSE

/// Attempt to login as a full user, setting up a home directories and user record file if successful.
/datum/computer/file/mainframe_program/os/kernel/proc/login_user(datum/mainframe2_user_data/account, user_name, sysop = FALSE, interactive = TRUE)
	if (!account || account.full_user || !user_name)
		return TRUE

	var/datum/computer/folder/user_folder = src.parse_directory(setup_filepath_users, src.holder.root, TRUE)
	var/datum/computer/folder/home_folder = src.parse_directory(setup_filepath_users_home, src.holder.root, TRUE)

	if (!user_folder || !home_folder || !src.sys_folder)
		return TRUE

	user_name = global.format_username(user_name)

	user_folder.metadata["permission"] = COMP_HIDDEN
	home_folder.metadata["permission"] = COMP_ROWNER | COMP_RGROUP | COMP_ROTHER

	var/name_attempt = 0
	var/attemptedname = null

	var/datum/computer/file/record/user_record = null
	while (name_attempt < 10)
		attemptedname = "usr[user_name][name_attempt]"
		if (length(attemptedname) > 16)
			attemptedname = copytext(attemptedname, 1, 15) + "[name_attempt]"

		var/datum/computer/file/record/existing_record = src.get_computer_datum(attemptedname, user_folder)
		if (existing_record)
			// If a service terminal is attempting to login, prevent duplicate files from being created.
			if (!interactive)
				existing_record.dispose()
			else
				name_attempt++
				continue

		user_record = new /datum/computer/file/record(src)
		user_record.name = attemptedname
		if (!user_folder.add_file(user_record))
			user_record.dispose()
			return TRUE

		break

	if (!user_record)
		return TRUE

	account.user_name = "[user_name][name_attempt]"
	account.user_file = user_record
	account.user_file_folder = user_record.holding_folder
	account.user_filename = user_record.name
	account.full_user = TRUE

	user_record.fields["name"] = account.user_name
	user_record.fields["id"] = account.user_id
	user_record.fields["group"] = !sysop
	user_record.fields["logtime"] = world.realtime
	user_record.fields["accept_msg"] = "1"
	user_record.metadata["owner"] = user_record.fields["name"]
	user_record.metadata["permission"] = COMP_ROWNER | COMP_WOWNER

	// If not interactive, no need to create a home directory for the user.
	if (!interactive)
		return FALSE

	var/datum/computer/folder/new_home = src.get_computer_datum(attemptedname, home_folder)
	if (istype(new_home))
		return FALSE

	new_home = new /datum/computer/folder()
	new_home.name = attemptedname
	new_home.metadata["owner"] = user_record.fields["name"]
	new_home.metadata["permission"] = COMP_ROWNER | COMP_WOWNER | COMP_DOWNER
	if (!home_folder.add_file(new_home))
		new_home.dispose()
		return TRUE

	return FALSE

/// Log a user out, terminating any running programs, and removing the user's record file.
/datum/computer/file/mainframe_program/os/kernel/proc/logout_user(datum/mainframe2_user_data/user, disconnect = FALSE)
	if (!user)
		return TRUE

	// The terminal device is no longer connected, so no need to wait for a new login from them.
	if (disconnect)
		src.users -= user.user_id

	user.current_prog?.handle_quit()
	user.user_file?.dispose()
	user.dispose()
	return FALSE

/// Log out all users, terminating any programs that they are using, and removing all user record files.
/datum/computer/file/mainframe_program/os/kernel/proc/logout_all_users(disconnect = FALSE)
	for (var/user_id in src.users)
		var/datum/mainframe2_user_data/user = src.users[user_id]
		if (!istype(user) || !istype(user.user_file))
			continue

		src.logout_user(user, disconnect)

/// Initialise all drivers, setting up driver data and initialising them individually.
/datum/computer/file/mainframe_program/os/kernel/proc/initialize_drivers()
	var/datum/computer/folder/prototype_folder = src.parse_directory(setup_filepath_drivers_proto, src.holder.root, TRUE)
	var/datum/computer/folder/device_folder = src.parse_directory(setup_filepath_drivers, src.holder.root, TRUE)
	if (!prototype_folder || !device_folder)
		return TRUE

	device_folder.metadata["permission"] = COMP_HIDDEN

	// Clear out any active drivers.
	for (var/datum/computer/file/mainframe_program/driver/driver in device_folder.contents)
		driver.dispose()

	var/driver_no = 0
	for (var/datum/computer/file/mainframe_program/driver/special_driver in prototype_folder.contents)
		if (!cmptext(copytext(special_driver.name, 1, 5), "int_"))
			continue

		special_driver = special_driver.copy_file()
		var/new_tag = copytext(special_driver.name, 5)

		special_driver.name = global.add_zero("[driver_no++]", 8)
		special_driver.master = src.master
		special_driver.termtag = copytext(new_tag, 5)

		if (!device_folder.add_file(special_driver))
			special_driver.dispose()
			continue

		src.initialize_driver(special_driver)

	// Iterate through current devices and create drivers for them.
	for (var/i in src.master.terminals)
		var/datum/terminal_connection/conn = src.master.terminals[i]
		if (!istype(conn) || (conn.term_type == "HUI_TERMINAL"))
			continue

		var/conn_type = lowertext(conn.term_type)
		if (copytext(conn_type, 1, 6) == "pnet_")
			conn_type = copytext(conn_type, 6)

		var/datum/computer/file/mainframe_program/driver/new_driver = src.get_file_name(conn_type, prototype_folder)
		if (!istype(new_driver))
			continue

		new_driver = new_driver.copy_file()
		new_driver.name = i
		new_driver.termtag = conn_type
		new_driver.master = src.master
		new_driver.initialized = TRUE

		if (!device_folder.add_file(new_driver))
			new_driver.dispose()
			continue

		src.initialize_driver(new_driver)

	return FALSE

/// Set up an individual driver, registering them for processing if necessary.
/datum/computer/file/mainframe_program/os/kernel/proc/initialize_driver(datum/computer/file/mainframe_program/driver/driver, datum/computer/file/connect_file)
	if (driver.setup_processes)
		if (!(driver in src.processing_drivers))
			src.processing_drivers += driver
		if (!(driver in src.master.processing))
			var/success = FALSE
			for (var/i in 1 to length(src.master.processing))
				if (!isnull(src.master.processing[i]))
					continue

				src.master.processing[i] = driver
				driver.progid = i
				success = TRUE
				break

			if (!success)
				src.master.processing += driver
				driver.progid = length(src.master.processing)

	driver.initialize(connect_file)

/// Check whether this user is a superuser.
/datum/computer/file/mainframe_program/os/kernel/proc/is_sysop(datum/mainframe2_user_data/udat)
	if (!udat?.user_file)
		return FALSE

	if (udat.user_file.fields["group"] != 0)
		return FALSE

	return TRUE

/// Alter the metadata of a specified file.
/datum/computer/file/mainframe_program/os/kernel/proc/change_metadata(datum/computer/file/file, field, newval)
	if (!file || !field)
		return FALSE

	if (istype(file.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
		var/datum/computer/file/mainframe_program/driver/mountable/mountable = file.holding_folder
		return mountable.change_metadata(file, field, newval)

	file.metadata[field] = newval
	return TRUE

/// Send a message to all logged in users.
/datum/computer/file/mainframe_program/os/kernel/proc/message_all_users(message, sender_name, ignore_user_file_setting)
	if (!sender_name)
		sender_name = "System"

	for (var/user_id in src.users)
		var/datum/mainframe2_user_data/user = src.users[user_id]
		if (!istype(user))
			continue

		if (!istype(user.user_file))
			continue

		if (ignore_user_file_setting || (user.user_file.fields["accept_msg"] == "1"))
			src.message_term("MSG from \[[sender_name]]: [message]", user_id, "multiline")
