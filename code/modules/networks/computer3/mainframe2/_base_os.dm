//------------ Program Signal Errors ------------//
/// The command was carried out successfully.
#define ESIG_SUCCESS	0
/// The command could not be carried out successfully.
#define ESIG_GENERIC	(1 << 0)
/// The command could not be carried out successfully, as a target was required and could not be found.
#define ESIG_NOTARGET	(1 << 1)
/// The command could not be carried out successfully, as the command was not recognised.
#define ESIG_BADCOMMAND	(1 << 2)
/// The command could not be carried out successfully, as a user was required and could not be found.
#define ESIG_NOUSR		(1 << 3)
/// The command could not be carried out successfully, as a result of an I/O error.
#define ESIG_IOERR		(1 << 4)
/// The command could not be carried out successfully, as a file was required and could not be found.
#define ESIG_NOFILE		(1 << 5)
/// The command could not be carried out successfully, as write permission was required.
#define ESIG_NOWRITE	(1 << 6)

/// User defined signal 1. This indicates an application-specific error condition has occured.
#define ESIG_USR1		(1 << 7)
/// User defined signal 2. This indicates an application-specific error condition has occured.
#define ESIG_USR2		(1 << 8)
/// User defined signal 3. This indicates an application-specific error condition has occured.
#define ESIG_USR3		(1 << 9)
/// User defined signal 4. This indicates an application-specific error condition has occured.
#define ESIG_USR4		(1 << 10)

/// If a command is expected to return a number, it will be signed with the databit to signify that it is not an error condition.
#define ESIG_DATABIT	(1 << 15)


//------------ DWAINE System Calls ------------//
/**
 *	Send a message or file to a connected terminal device.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the target terminal.
 *	- `"data"`: If sending a message, the content of that message. Otherwise acts as file data.
 *	- `"render"`: If sending a message, determines how that message should be displayed. Values may be combined using `|`.
 *		Accepted values:
 *		- `"clear"`: The screen should be cleared before the message is displayed.
 *		- `"multiline"`: `|n` should be interpreted as a line break.
 */
#define DWAINE_COMMAND_MSG_TERM	1

/**
 *	Send a log in request to the kernel.
 *	Accepted data fields:
 *	- `"name"`: The username of the user attempting to log in. Set to `"TEMP"` if attempting to login as a temporary user.
 *	- `"sysop"`: Whether the user is a superuser.
 *	- `"service"`: Whether the user connecting is a service terminal.
 *	- `"data"`: If attempting to login as a temporary user, the net ID of the user terminal.
 */
#define DWAINE_COMMAND_ULOGIN	2

/**
 *	Update the user's group.
 *	Accepted data fields:
 *	- `"group"`: The desired value of the `group` field on the user's record file.
 */
#define DWAINE_COMMAND_UGROUP	3

/**
 *	List all current users.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_ULIST	4

/**
 *	Send message to a connected user terminal. Cannot send messages to non-user terminals.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the target user terminal.
 *	- `"data"`: The content of the message.
 */
#define DWAINE_COMMAND_UMSG		5

/**
 *	Acts as an alternate path for user input.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the user terminal.
 *	- `"data"`: If a file is not provided, the content of the input.
 */
#define DWAINE_COMMAND_UINPUT	6

/**
 *	Send message to a specified driver.
 *	Accepted data fields:
 *	- `"target"`: The name or ID of the target driver.
 *	- `"mode"`: If `1`, search for drivers by name, if `0`, search by ID.
 *	- `"dcommand"`: The `"command"` field to pass to the driver.
 *	- `"dtarget"`: The `"target"` field to pass to the driver.
 */
#define DWAINE_COMMAND_DMSG		7

/**
 *	List all drivers of a specific terminal type.
 *	Accepted data fields:
 *	- `"dtag"`: The terminal type of the drivers to search for.
 *	- `"mode"`: If `1`, omit empty or invalid indexes, if `0`, do not.
 */
#define DWAINE_COMMAND_DLIST	8

/**
 *	Get the ID of a specific driver.
 *	Accepted data fields:
 *	- `"dtag"`: The terminal type of the drivers to search for.
 *	- `"dnetid"`: If `"dtag"` is not specified, the driver name to search for. Driver names correspond to the net ID of their respective device, excluding the "pnet_" prefix.
 */
#define DWAINE_COMMAND_DGET		9

/**
 *	Instruct the mainframe to recheck for devices now instead of waiting for the full timeout.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_DSCAN	10

/**
 *	Instruct the caller_prog to exit the current running program.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_EXIT		11

/**
 *	Run a task located at a specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the task is located.
 *	- `"passusr"`: Whether to pass the user to the task.
 *	- `"args"`: The arguments to pass to the task.
 */
#define DWAINE_COMMAND_TSPAWN	12

/**
 *	Run a new child task of the calling program's type.
 *	Accepted data fields:
 *	- `"args"`: The arguments to pass to the task.
 */
#define DWAINE_COMMAND_TFORK	13

/**
 *	Terminate a child task of the calling program.
 *	Accepted data fields:
 *	- `"target"`: The ID of the target task.
 */
#define DWAINE_COMMAND_TKILL	14

/**
 *	List all child tasks of the calling program.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_TLIST	15

/**
 *	Instruct a program to exit the current running task.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_TEXIT	16

/**
 *	Get the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 */
#define DWAINE_COMMAND_FGET		17

/**
 *	Delete the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 */
#define DWAINE_COMMAND_FKILL	18

/**
 *	Adjust the permissions of the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 *	- `"permission"`: The desired permission level of the computer file.
 */
#define DWAINE_COMMAND_FMODE	19

/**
 *	Adjust the owner and group of the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 *	- `"owner"`: The desired owner of the computer file.
 *	- `"group"`: The desired group value of the computer file.
 */
#define DWAINE_COMMAND_FOWNER	20

/**
 *	Write a provided computer file to the specified path.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file should be written to.
 *	- `"mkdir"`: Whether to create the filepath if it does not exist.
 *	- `"replace"`: If the computer file already exists, whether to overwrite it.
 *	- `"append"`: If the computer file already exists, whether to append the contents of the new file to it.
 */
#define DWAINE_COMMAND_FWRITE	21

/**
 *	Get the config file of the specified name.
 *	Accepted data fields:
 *	- `"fname"`: The name of the config file.
 */
#define DWAINE_COMMAND_CONFGET	22

/**
 *	Set up a mountpoint for a device driver.
 *	Accepted data fields:
 *	- `"id"`: The name of the device driver to set up a mountpoint for.
 *	- `"link"`: If set, the name of the symbolic link folder to set up for the mountpoint.
 */
#define DWAINE_COMMAND_MOUNT	23

/**
 *	Instruct a program to receive and handle a file.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_RECVFILE	24

/**
 *	Instruct a program to halt processing a script.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_BREAK	25

/**
 *	Reply to a request for information.
 *	Has unique data fields for each implementation, depending on the data requested.
 */
#define DWAINE_COMMAND_REPLY	30


//------------ Generic Commands ------------//
/// Global list representing the standard exit command packet.
var/global/list/generic_exit_list = list("command" = DWAINE_COMMAND_EXIT)
/// Exit the current running program.
#define mainframe_prog_exit src.signal_program(1, global.generic_exit_list)


/// Filepath that corresponds to the directory for user record files.
#define setup_filepath_users "/usr"
/// Filepath that corresponds to the directory for personal user directories.
#define setup_filepath_users_home "/home"
/// Filepath that corresponds to the directory for device and pseudo-device files.
#define setup_filepath_drivers "/dev"
/// Filepath that corresponds to the directory for device file prototypes. Prototypes are named after the ID of their respective device, excluding the "pnet_" prefix.
#define setup_filepath_drivers_proto "/sys/drvr"
/// Filepath that corresponds to the directory for mounted file systems, such as databanks.
#define setup_filepath_volumes "/mnt"
/// Filepath that corresponds to the directory for the OS, including the kernel, shell, and login program.
#define setup_filepath_system "/sys"
/// Filepath that corresponds to the directory for configuration files.
#define setup_filepath_config "/conf"
/// Filepath that corresponds to the directory for binaries (executable files). It contains fundamental system utilities, including system commands, such as `ls` or `cd`.
#define setup_filepath_commands "/bin"
/// Filepath that corresponds to the directory for information files pertaining to active processes.
#define setup_filepath_process "/proc"


/**
 *	The kernel is the computer program at the core of the OS and is responsible for managing interactions with all hardware
 *	devices, such as terminals, databanks, scanners and so forth through device drivers; for handling inputs; for creating and
 *	terminating connections; for the execution of system calls; and for other basic system services.
 */
/datum/computer/file/mainframe_program/os/kernel
	name = "Kernel"
	size = 16

	/// A list of users currently connected to the OS, indexed by their user ID.
	VAR_PRIVATE/tmp/list/datum/mainframe2_user_data/users = null
	/// The maximum number of users that may connect to the OS.
	VAR_PRIVATE/tmp/max_users = 0
	/// The `/sys` directory that the kernel is located in.
	VAR_PRIVATE/tmp/datum/computer/folder/sys_folder = null
	/// A list of drivers that are open to receiving messages from the OS.
	VAR_PRIVATE/tmp/list/datum/computer/file/mainframe_program/driver/processing_drivers = null

	/// The number of cycles for which the kernel should reply to any pings made.
	VAR_PRIVATE/tmp/ping_accept = 0
	/// How often the mainframe should ping the network, in cycles.
	VAR_PRIVATE/tmp/rescan_period = 60
	/// The current number of cycles until the mainframe should ping the network.
	VAR_PRIVATE/tmp/rescan_timer = 0

	/// The default program name of the login program.
	VAR_PRIVATE/setup_progname_login = "login"
	/// The default program name of the shell.
	VAR_PRIVATE/setup_progname_shell = "msh"
	/// The default program name of the init program.
	VAR_PRIVATE/setup_progname_init = "init"

/datum/computer/file/mainframe_program/os/kernel/New()
	src.processing_drivers = list()
	src.rescan_timer = src.rescan_period

	. = ..()

/datum/computer/file/mainframe_program/os/kernel/disposing()
	src.users = null
	src.sys_folder = null
	src.processing_drivers = null

	if (src.master.os == src)
		src.master.os = null

	. = ..()

/datum/computer/file/mainframe_program/os/kernel/initialize()
	if (..())
		return

	src.users = list()
	src.processing_drivers = list()
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
		user.current_prog.receive_progsignal(TRUE, list("command" = DWAINE_COMMAND_BREAK, "user" = termid))
		return

	if (user.current_prog)
		if (file)
			user.current_prog.receive_progsignal(TRUE, list("command" = DWAINE_COMMAND_RECVFILE, "user" = termid), file)
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
	if (dd_hasprefix(term_type , "pnet_"))
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

	if (!data["command"])
		return ESIG_GENERIC

	switch (data["command"])
		if (DWAINE_COMMAND_MSG_TERM)
			if (!data["term"])
				return ESIG_NOTARGET

			if (file)
				return src.file_term(file, data["term"], data["data"])
			else
				return src.message_term(data["data"], data["term"], data["render"])

		if (DWAINE_COMMAND_ULOGIN)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog || !data["name"])
				return ESIG_GENERIC

			if (data["data"] && (data["name"] == "TEMP"))
				return (src.login_temp_user(data["data"], null, caller_prog)) ? ESIG_GENERIC : ESIG_SUCCESS

			if (!caller_prog.useracc)
				return ESIG_NOUSR

			if (src.login_user(caller_prog.useracc, data["name"], data["sysop"], (data["service"] != 1)))
				return ESIG_GENERIC

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_UGROUP)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog || !isnum(data["group"]))
				return ESIG_GENERIC

			if (!caller_prog.useracc || !caller_prog.useracc.user_file)
				return ESIG_NOUSR

			caller_prog.useracc.user_file.fields["group"] = clamp(0, data["group"], 255)
			return ESIG_SUCCESS

		if (DWAINE_COMMAND_ULIST)
			var/list/user_list = list()

			for (var/uid in src.users)
				var/datum/mainframe2_user_data/user = src.users[uid]
				if (!istype(user) || !istype(user.user_file))
					continue

				var/groupnum = user.user_file.fields["group"]
				if (!isnum(groupnum))
					groupnum = "N"

				var/logtime = user.user_file.fields["logtime"]
				if (isnum(logtime))
					logtime = time2text(logtime, "hh:mm")
				else
					logtime = "??:??"

				user_list[uid] = "[logtime] [groupnum] [user.user_file.fields["name"]]"

			if (!length(user_list))
				return ESIG_GENERIC

			return user_list

		if (DWAINE_COMMAND_UMSG)
			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog || !caller_prog.useracc)
				return ESIG_NOUSR

			var/sender_name = caller_prog.useracc.user_name
			if (!sender_name)
				return ESIG_NOUSR

			var/message = data["data"]
			if (!ckeyEx(message))
				return ESIG_GENERIC

			var/target_uid = data["term"]
			if (!target_uid)
				return ESIG_NOTARGET

			var/datum/mainframe2_user_data/target = src.users[target_uid]
			if (!istype(target))
				for (var/uid in src.users)
					var/datum/mainframe2_user_data/user = src.users[uid]
					if (!user?.user_file)
						continue

					if (!(lowertext(user.user_file.fields["name"]) == target_uid))
						continue

					target = user
					target_uid = uid
					break

				if (!istype(target))
					return ESIG_NOTARGET

			else if (!istype(target.user_file))
				return ESIG_NOTARGET

			if (caller_prog.useracc == target)
				return ESIG_NOTARGET

			if (!(target.user_file.fields["accept_msg"] == "1"))
				return ESIG_IOERR

			src.message_term("MSG from \[[sender_name]]: [message]", target_uid, "multiline")
			return ESIG_SUCCESS

		if (DWAINE_COMMAND_UINPUT)
			var/net_id = ckey(data["term"])
			var/datum/mainframe2_user_data/user = src.users[net_id]

			if (!user)
				return ESIG_NOUSR

			if (!istype(user))
				src.login_user(net_id, "TEMP")
				return ESIG_SUCCESS

			if (user.current_prog)
				if (file)
					user.current_prog.receive_progsignal(TRUE, list("command" = DWAINE_COMMAND_RECVFILE, "user" = net_id), file)
				else
					user.current_prog.input_text(data["data"])
			else
				if (user.full_user)
					user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_shell, src.sys_folder), user, src)
				else
					user.current_prog = src.master.run_program(src.get_file_name(src.setup_progname_login, src.sys_folder), user, src)

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_DMSG)
			var/driver_id = data["target"]
			var/datum/computer/file/mainframe_program/driver/driver

			if (data["mode"] == 1)
				for (var/datum/computer/file/mainframe_program/driver/D as anything in src.processing_drivers)
					if (!cmptext("[driver_id]", D.name))
						continue

					driver = D
					break

			else if (isnum(driver_id) && (driver_id >= 1) && (driver_id <= length(src.processing_drivers)))
				driver = src.processing_drivers[driver_id]

			if (!istype(driver))
				return ESIG_NOTARGET

			data["command"] = data["dcommand"]
			data["target"] = data["dtarget"]
			return driver.receive_progsignal(sendid, data, file)

		if (DWAINE_COMMAND_DLIST)
			var/list/driver_list = list()
			var/target_tag = lowertext(data["dtag"])
			var/omit_wrong_tags = (data["mode"] == 1)

			if (!omit_wrong_tags)
				driver_list.len = length(src.processing_drivers)

			for (var/i in 1 to length(src.processing_drivers))
				var/datum/computer/file/mainframe_program/driver/D = src.processing_drivers[i]
				if (!istype(D))
					continue

				if (D.disposed)
					src.processing_drivers[i] = null
					continue

				if (D.termtag != target_tag)
					continue

				if (!omit_wrong_tags)
					driver_list[i] = "[D.name]"

				driver_list["[D.name]"] = D.status

			if (!length(driver_list))
				return ESIG_GENERIC

			return driver_list

		if (DWAINE_COMMAND_DGET)
			var/target_tag = lowertext(data["dtag"] || data["dnetid"])
			if (!target_tag)
				return ESIG_NOTARGET

			for (var/i in 1 to length(src.processing_drivers))
				var/datum/computer/file/mainframe_program/driver/driver = src.processing_drivers[i]
				if (!istype(driver))
					continue

				if (driver.disposed)
					processing_drivers[i] = null
					continue

				if ((driver.termtag == target_tag) || (driver.name == target_tag))
					return (i | ESIG_DATABIT)

			return ESIG_NOTARGET

		if (DWAINE_COMMAND_DSCAN)
			if (src.ping_accept)
				return ESIG_GENERIC

			src.master.reconnect_all_devices()
			src.master.timeout_alert = FALSE
			src.master.timeout = 5
			src.ping_accept = 5

			SPAWN(2 SECONDS)
				src.master.post_status("ping", "data", "DWAINE", "net", "[src.master.net_number]")

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_EXIT)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog || (caller_prog == src))
				return ESIG_GENERIC

			if (!caller_prog.useracc)
				caller_prog.handle_quit()
				return ESIG_NOUSR

			var/datum/mainframe2_user_data/user = caller_prog.useracc
			var/datum/computer/file/mainframe_program/shellbase = src.get_file_name(src.setup_progname_shell, src.sys_folder)
			var/shellexit = (shellbase && (shellbase.type == caller_prog.type) && (caller_prog.parent_id == src.progid))

			var/datum/computer/file/mainframe_program/quitparent = caller_prog.parent_task
			caller_prog.handle_quit()

			if (istype(quitparent) && (quitparent != src) && !istype(quitparent, /datum/computer/file/mainframe_program/driver/mountable/radio)) // Hello, this last istype() is a dirty hack.
				if (user.current_prog == caller_prog)
					user.current_prog = quitparent
				quitparent.useracc = user
				quitparent.receive_progsignal(TRUE, list("command" = DWAINE_COMMAND_TEXIT, "id" = sendid))

			else if (shellexit && user) // Outermost shell should only exit if things go really wrong or the user logs out.
				var/user_id = user.user_id
				src.logout_user(user, FALSE)

				// As they didn't disconnect the the terminal, we should present a new login screen there.
				src.login_temp_user(user_id)

			else
				src.master.run_program(shellbase, user, (quitparent || src))

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_TSPAWN)
			if (!data["path"])
				return ESIG_NOTARGET

			if (!sendid)
				return ESIG_GENERIC

			var/pass_user = (data["passusr"] == 1)

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/task_model = src.parse_file_directory(data["path"], src.holder.root, FALSE)
			if (!task_model?.executable)
				return ESIG_NOTARGET

			task_model = src.master.run_program(task_model, (pass_user ? caller_prog.useracc : null), caller_prog, data["args"])
			if (!task_model)
				return ESIG_GENERIC

			return task_model

		if (DWAINE_COMMAND_TFORK)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/fork = src.master.run_program(caller_prog, null, caller_prog, data["args"], TRUE)
			if (!fork)
				return ESIG_GENERIC

			return fork.progid | ESIG_DATABIT

		if (DWAINE_COMMAND_TKILL)
			if (!sendid)
				return ESIG_NOTARGET

			var/target_id = data["target"]
			if (!isnum(target_id) || (target_id < 0) || (target_id > length(src.master.processing)))
				return ESIG_NOTARGET

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/target_task = src.master.processing[target_id]
			if (!target_task)
				return ESIG_SUCCESS

			if (target_task.parent_task != caller_prog)
				return ESIG_GENERIC

			var/datum/mainframe2_user_data/target_user = target_task.useracc
			if (target_user && (!caller_prog.useracc || (target_user.current_prog == target_task)))
				target_user.current_prog = caller_prog
				caller_prog.useracc = target_user

			target_task.handle_quit()

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_TLIST)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!caller_prog)
				return ESIG_GENERIC

			var/list/datum/computer/file/mainframe_program/progs = list()
			progs.len = length(src.master.processing)

			for (var/i in 1 to length(src.master.processing))
				var/datum/computer/file/mainframe_program/MP = src.master.processing[i]
				if (MP && (MP.parent_task == caller_prog))
					progs[i] = MP

			return progs

		if (DWAINE_COMMAND_FGET)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!data["path"] || !caller_prog)
				return ESIG_NOTARGET

			var/datum/computer/target_file = src.parse_datum_directory(data["path"], src.holder.root, FALSE, caller_prog.useracc)
			if (!target_file)
				return ESIG_NOFILE

			return target_file

		if (DWAINE_COMMAND_FKILL)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!data["path"] || !caller_prog)
				return ESIG_NOTARGET

			var/datum/mainframe2_user_data/user = caller_prog.useracc
			var/datum/computer/target_file = src.parse_datum_directory(data["path"], src.holder.root, FALSE, user)

			if (!target_file || (target_file.holding_folder == src.master.runfolder) || (target_file == src.master.runfolder) || (target_file == src.holder.root))
				return ESIG_NOFILE

			if (user && !src.check_mode_permission(target_file, user))
				return ESIG_NOFILE

			if (istype(target_file.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
				target_file.holding_folder.remove_file(target_file)
				return ESIG_SUCCESS

			target_file.dispose()
			return ESIG_SUCCESS

		if (DWAINE_COMMAND_FMODE)
			if (!sendid)
				return ESIG_GENERIC

			if (!isnum(data["permission"]))
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!data["path"] || !caller_prog)
				return ESIG_NOTARGET

			var/datum/computer/target_file = src.parse_datum_directory(data["path"], src.holder.root, FALSE, caller_prog.useracc)
			if (!istype(target_file))
				return ESIG_NOFILE

			if (caller_prog.useracc && !src.check_mode_permission(target_file, caller_prog.useracc))
				return ESIG_GENERIC

			src.change_metadata(target_file, "permission", data["permission"])
			return ESIG_SUCCESS

		if (DWAINE_COMMAND_FOWNER)
			if (!sendid)
				return ESIG_GENERIC

			if (!isnum(data["group"]) && !data["owner"])
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!data["path"] || !caller_prog)
				return ESIG_NOTARGET

			var/datum/computer/target_file = src.parse_datum_directory(data["path"], src.holder.root, FALSE, caller_prog.useracc)
			if (!istype(target_file))
				return ESIG_NOFILE

			if (caller_prog.useracc && !src.check_mode_permission(target_file, caller_prog.useracc))
				return ESIG_GENERIC

			if (data["owner"])
				src.change_metadata(target_file, "owner", copytext(data["owner"], 1, 16))

			if (isnum(data["group"]))
				src.change_metadata(target_file, "group", clamp(data["group"], 0, 255))

			return ESIG_SUCCESS

		if (DWAINE_COMMAND_FWRITE)
			if (!sendid)
				return ESIG_GENERIC

			var/datum/computer/file/mainframe_program/caller_prog = src.master.processing[sendid]
			if (!file || !data["path"] || !caller_prog)
				return ESIG_NOTARGET

			if (src.is_name_invalid(file.name))
				return ESIG_GENERIC

			var/datum/mainframe2_user_data/user = caller_prog.useracc
			var/datum/computer/folder/destination = src.parse_directory(data["path"], src.holder.root, (data["mkdir"] == 1), user)
			if (!destination || (destination == src.master.runfolder))
				return ESIG_NOTARGET

			var/datum/computer/file/record/destfile = src.get_computer_datum(file.name, destination)
			if (istype(destfile, /datum/computer/folder))
				destination = destfile

			if (user && !src.check_write_permission(destination, user))
				return ESIG_NOWRITE

			var/delete_dest = FALSE
			if (destfile)
				if ((data["append"] == 1) && (!user || src.check_write_permission(destfile, user)) && (istype(destfile) && istype(file, /datum/computer/file/record)))
					file:fields = destfile.fields + file:fields
					delete_dest = TRUE

				else if ((data["replace"] == 1) && (!user || src.check_mode_permission(destfile, user)))
					delete_dest = TRUE

				else if (istype(destfile, /datum/computer/file))
					return ESIG_GENERIC

			if (!destination.can_add_file(file, user))
				return ESIG_GENERIC

			if (delete_dest && destfile)
				destfile.dispose()

			destination.add_file(file, user)
			return ESIG_SUCCESS

		if (DWAINE_COMMAND_CONFGET)
			if (!data["fname"])
				return ESIG_NOTARGET

			var/datum/computer/folder/config_folder = src.parse_directory(setup_filepath_config, src.holder.root, FALSE)
			if (!config_folder)
				return ESIG_NOTARGET

			var/datum/computer/file/target_file = src.get_file_name(data["fname"], config_folder)
			if (!target_file)
				return ESIG_NOFILE

			return target_file

		if (DWAINE_COMMAND_MOUNT)
			if (!data["id"])
				return ESIG_NOTARGET

			var/datum/computer/file/mainframe_program/driver/mountable/mountable = src.parse_file_directory("[setup_filepath_drivers]/_[data["id"]]", src.holder.root, FALSE)
			if (!istype(mountable))
				return ESIG_NOTARGET

			var/datum/computer/folder/mount_folder = src.parse_directory(setup_filepath_volumes, src.holder.root, TRUE)
			if (!istype(mount_folder))
				return ESIG_NOTARGET

			var/datum/computer/folder/mountpoint/mountpoint = src.get_computer_datum("_[data["id"]]", mount_folder)
			if (istype(mountpoint))
				mountpoint.dispose()

			else if (istype(mountpoint, /datum/computer))
				return ESIG_GENERIC

			mountpoint = new /datum/computer/folder/mountpoint(mountable)
			mountpoint.name = "_[data["id"]]"
			if (!mount_folder.add_file(mountpoint))
				mountpoint.dispose()
				return ESIG_GENERIC

			if (data["link"])
				var/datum/computer/folder/link/symlink = src.get_computer_datum(data["link"], mount_folder)
				if (!symlink || istype(symlink))
					if (symlink)
						symlink.dispose()

					symlink = new /datum/computer/folder/link(mountpoint)
					symlink.name = data["link"]
					if (!mount_folder.add_file(symlink))
						symlink.dispose()

			mountpoint.metadata["permission"] = mountable.default_permission
			mountpoint.metadata["group"] = 1
			mountpoint.metadata["owner"] = "Nobody"
			return ESIG_SUCCESS

		else
			return ESIG_BADCOMMAND

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

	// Iterate through current devices and use that to create active device files.
	for (var/i in src.master.terminals)
		var/datum/terminal_connection/conn = src.master.terminals[i]
		if (!istype(conn))
			continue

		if (conn.term_type == "HUI_TERMINAL")
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


/**
 *	The user login manager is responsible for passing user login credentials from the user to the kernel to be authenticated,
 *	displaying the daily welcome message to the user, and for notifying the user in the event of a login failure.
 */
/datum/computer/file/mainframe_program/login
	name = "Login"
	size = 2
	executable = 0

	var/motd = "Welcome to DWAINE System VI!|nCopyright 2050 Thinktronic Systems, LTD."
	var/setup_filename_motd = "motd"

/datum/computer/file/mainframe_program/login/initialize()
	if (..())
		return

	var/datum/computer/file/record/record = src.signal_program(1, list("command" = DWAINE_COMMAND_CONFGET, "fname" = src.setup_filename_motd))
	if (istype(record))
		src.motd = jointext(record.fields, "|n")
		src.motd = copytext(src.motd, 1, 255)
	else
		src.motd = initial(src.motd)

	src.message_user("[src.motd]|nPlease enter card and \"term_login\"", "multiline")

/datum/computer/file/mainframe_program/login/receive_progsignal(sendid, list/data, datum/computer/file/record/file)
	if (..() || (data["command"] != DWAINE_COMMAND_RECVFILE) || !istype(file))
		return ESIG_GENERIC

	if (!src.useracc)
		return ESIG_NOUSR

	if (!file.fields["registered"] || !file.fields["assignment"])
		return ESIG_GENERIC

	if (src.signal_program(1, list("command" = DWAINE_COMMAND_ULOGIN, "name" = file.fields["registered"])) != ESIG_SUCCESS)
		src.message_user("Error: Login failure. Please try again.")
		return ESIG_GENERIC

	mainframe_prog_exit


#undef setup_filepath_users
#undef setup_filepath_users_home
#undef setup_filepath_drivers
#undef setup_filepath_drivers_proto
#undef setup_filepath_volumes
#undef setup_filepath_system
#undef setup_filepath_config
#undef setup_filepath_commands
#undef setup_filepath_process
