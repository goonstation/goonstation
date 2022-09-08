//CONTENTS
//OS Constants
//OS Kernel
//User login program

//Progsignal errors
#define ESIG_SUCCESS 0
#define ESIG_GENERIC 1
#define ESIG_NOTARGET 2
#define ESIG_BADCOMMAND 4
#define ESIG_NOUSR 8
#define ESIG_IOERR 16
#define ESIG_NOFILE 32
#define ESIG_NOWRITE 64
#define ESIG_USR1 128
#define ESIG_USR2 256
#define ESIG_USR3 512
#define ESIG_USR4 1024

#define ESIG_DATABIT 32768

#define DWAINE_COMMAND_MSG_TERM	1
#define DWAINE_COMMAND_ULOGIN	2
#define DWAINE_COMMAND_UGROUP	3
#define DWAINE_COMMAND_ULIST	4
#define DWAINE_COMMAND_UMSG		5
#define DWAINE_COMMAND_UINPUT	6
#define DWAINE_COMMAND_DMSG		7
#define DWAINE_COMMAND_DLIST	8
#define DWAINE_COMMAND_DGET		9
#define DWAINE_COMMAND_DSCAN	10
#define DWAINE_COMMAND_EXIT		11
#define DWAINE_COMMAND_TSPAWN	12
#define DWAINE_COMMAND_TFORK	13
#define DWAINE_COMMAND_TKILL	14
#define DWAINE_COMMAND_TLIST	15
#define DWAINE_COMMAND_TEXIT	16
#define DWAINE_COMMAND_FGET		17
#define DWAINE_COMMAND_FKILL	18
#define DWAINE_COMMAND_FMODE	19
#define DWAINE_COMMAND_FOWNER	20
#define DWAINE_COMMAND_FWRITE	21
#define DWAINE_COMMAND_CONFGET	22
#define DWAINE_COMMAND_MOUNT	23
#define DWAINE_COMMAND_RECVFILE	24
#define DWAINE_COMMAND_BREAK	25

#define DWAINE_COMMAND_REPLY	30

var/global/list/generic_exit_list = list("command"=DWAINE_COMMAND_EXIT)
#define mainframe_prog_exit signal_program(1, generic_exit_list)

#define setup_filepath_users "/usr"
#define setup_filepath_users_home "/home"
#define setup_filepath_drivers "/dev" //Device file zone
#define setup_filepath_drivers_proto "/sys/drvr" //Device file prototypes, named after the pnet id of their respective device (Sans "pnet_" prefix)
#define setup_filepath_volumes "/mnt" //Mounted filesystems, i.e. databanks.
#define setup_filepath_system "/sys"
#define setup_filepath_config "/conf"
#define setup_filepath_commands "/bin"
#define setup_filepath_process "/proc"

//Kernel
/datum/computer/file/mainframe_program/os/kernel
	name = "Kernel"
	size = 16
	var/tmp/list/users
	var/tmp/user_max = 0
	var/tmp/ping_accept = 0
	var/tmp/rescan_timer = 60

	var/tmp/datum/computer/folder/sysfolder = null
	var/tmp/list/processing_drivers = list()

	var/setup_progname_hello = "login"
	var/setup_progname_shell = "msh"
	var/setup_progname_init =  "init"

	disposing()
		users = null
		if (processing_drivers)
			processing_drivers.len = 0
			processing_drivers = null
		sysfolder = null

		if (master && master.os == src)
			master.os = null

		..()

	initialize()
		if(..())
			return

		users = list()
		src.processing_drivers.len = 0
		sysfolder = parse_directory(setup_filepath_system, src.holder.root, 1)
		if (!sysfolder)
			user_max = 0
			return

		sysfolder.metadata["permission"] = COMP_HIDDEN

		user_max = max( round((src.holder.file_amount-128)/32), 0)
		if(src.initialize_drivers() || src.initialize_users())
			user_max = 0 //These only return 1 if we can't start up properly, so...
			return

		src.ping_accept = 4
		src.master.timeout = 1
		src.master.timeout_alert = 0
		SPAWN(0.5 SECONDS)
			src.master.post_status("ping","data","DWAINE","net","[src.master.net_number]")

		//Run "init" program, if present.
		master.run_program(get_file_name(setup_progname_init, sysfolder), null, src)

		return

	term_input(var/data, var/termid, var/datum/computer/file/file, isBreak) //Input from any terminal, be it user or device.
		if (..())
			return

		if (termid in src.users)
			var/datum/mainframe2_user_data/the_user = src.users[termid]
			if (!istype(the_user))
				login_user(termid, "TEMP")
				return

			if (the_user.current_prog)
				if (isBreak)
					the_user.current_prog.receive_progsignal(1, list("command"=DWAINE_COMMAND_BREAK, "user"=termid))
					return

				if (file)
					the_user.current_prog.receive_progsignal(1, list("command"=DWAINE_COMMAND_RECVFILE, "user"=termid), file)
				else
					the_user.current_prog.input_text(data)
			else
				if (isBreak)
					the_user.current_prog.receive_progsignal(1, list("command"=DWAINE_COMMAND_BREAK, "user"=termid))
					return

				if (the_user.full_user)
					the_user.current_prog = master.run_program(get_file_name(setup_progname_shell, sysfolder), the_user, src)
				else
					the_user.current_prog = master.run_program(get_file_name(setup_progname_hello, sysfolder), the_user, src)

			return

		var/datum/computer/file/mainframe_program/driver/D = parse_file_directory("[setup_filepath_drivers]/[termid]", src.holder.root, 0)
		if (istype(D))
			D.terminal_input(data, file)
			return
		return

	//Called by the mainframe object when a new terminal connection datum is ready for us to handle.
	new_connection(datum/terminal_connection/conn, datum/computer/file/connect_file)
		if (!conn)
			return

		var/term_type = lowertext(conn.term_type)
		if (dd_hasprefix(term_type , "pnet_"))
			term_type = copytext(term_type, 6)

		//if (copytext(term_type, 4) == "_terminal")
		if (term_type == "hui_terminal")
			if (!(conn.net_id in src.users) || !istype(src.users[conn.net_id], /datum/mainframe2_user_data))
				//User does not yet exist, set them up as temporary so they can log in.
				login_temp_user(conn.net_id, connect_file)
			else //User already exists.
				var/datum/mainframe2_user_data/the_user = src.users[conn.net_id]
				if (!the_user.current_prog)
					if (the_user.full_user) //They are logged in, with nothing currently running for them. Send them to the shell.
						the_user.current_prog = master.run_program(get_file_name(setup_progname_shell, sysfolder, src))
					else //They already exist, but they never logged in!  Give them a chance to do that now.
						the_user.current_prog = master.run_program(get_file_name(setup_progname_hello, sysfolder, src))

			return


		//Find relevant directories for device initialization...
		var/datum/computer/folder/pF = parse_directory(setup_filepath_drivers_proto, src.holder.root, 1)
		var/datum/computer/folder/dF = parse_directory(setup_filepath_drivers, src.holder.root, 1)
		if (!pF || !dF)
			return

		//See if we have a known device prototype...
		var/datum/computer/file/mainframe_program/driver/D = get_file_name(term_type, pF)
		if (!istype(D)) //We do not! What a pity.
			return

		//Now build our working driver instance in dF.
		D = D.copy_file()
		D.name = conn.net_id
		D.termtag = term_type
		if (get_file_name(D.name, dF) || !dF.add_file(D))
			//qdel(D)
			D.dispose()
			return

		D.master = src.master
		if (D.setup_processes) //The driver either processes, or wants to make use of the processing list for communication.
			if(!(D in src.processing_drivers))
				src.processing_drivers += D
			if(!(D in src.master.processing))
				var/success = 0
				for (var/x = 1, x <= src.master.processing.len, x++)
					if (src.master.processing[x] != null)
						continue

					src.master.processing[x] = D
					D.progid = x
					success = 1
					break

				if (!success)
					src.master.processing.len++
					src.master.processing[src.master.processing.len]= D
					D.progid = length(src.master.processing)

		D.initialize(connect_file)
		return

	//Called by mainframe object when one of the terminal connection datums is about to be deleted.
	closed_connection(datum/terminal_connection/conn)
		if (!conn)
			return
		if (conn.net_id in src.users)
			if (istype(src.users[conn.net_id], /datum/mainframe2_user_data))
				var/datum/mainframe2_user_data/the_user = src.users[conn.net_id]
				logout_user(the_user, 1)
			return

		var/datum/computer/file/F = parse_file_directory("[setup_filepath_drivers]/[conn.net_id]", src.holder.root, 0)
		if (F)
			//qdel(F)
			F.dispose()

		return

	ping_reply(var/senderid,var/sendertype)
		if(..() || !ping_accept)
			return

		if (dd_hasprefix(sendertype, "pnet_"))
			sendertype = copytext(sendertype, 6)

		if( !(senderid in master.terminals) && (get_file_name(sendertype, parse_directory(setup_filepath_drivers_proto, src.holder.root, 0))) )
			if(master.status & (NOPOWER|BROKEN|MAINT))
				return

			if(!(holder in src.master.contents))
				return

			SPAWN(rand(1,4))
				src.master.post_status(senderid, "command", "term_connect", "device", master.device_tag)

			return

		return

	//Receive a signal sent by another program or driver on the mainframe.
	//This is where system calls are interpreted.
	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (!src.master || (sendid == src.progid))
			return ESIG_GENERIC

		if (!data["command"])
			return ESIG_GENERIC

		switch (data["command"])
			if (DWAINE_COMMAND_MSG_TERM)
				if (!data["term"])
					return ESIG_NOTARGET

				if (file)
					return file_term(file, data["term"], data["data"])
				else
					//boutput(world, "message term of \[[data["data"]]] to \[[data["term"]]]")
					return message_term(data["data"], data["term"], data["render"])

			if (DWAINE_COMMAND_ULOGIN)
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller || !data["name"])
					return ESIG_GENERIC

				if (data["name"] == "TEMP" && data["data"])
					return (login_temp_user(data["data"], null, caller)) ? ESIG_GENERIC : ESIG_SUCCESS

				else
					if (!caller.useracc)
						return ESIG_NOUSR

					if (login_user(caller.useracc, data["name"], (data["sysop"] == 1), (data["service"] != 1)))
						return ESIG_GENERIC

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_UGROUP) //Manipulate the group of the caller's user account to ["group"]
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller || !isnum(data["group"]))
					return ESIG_GENERIC

				if (!caller.useracc || !caller.useracc.user_file)
					return ESIG_NOUSR

				caller.useracc.user_file.fields["group"] = clamp(0, data["group"], 255)
				return ESIG_SUCCESS

			if (DWAINE_COMMAND_ULIST) //List current users.
				var/list/ulist = list()
				for (var/uid in src.users)
					var/datum/mainframe2_user_data/udat = src.users[uid]
					if (!istype(udat) || !istype(udat.user_file))
						continue

					var/groupnum = udat.user_file.fields["group"]
					if (!isnum(groupnum))
						groupnum = "N"
					var/logtime = udat.user_file.fields["logtime"]
					if (isnum(logtime))
						logtime = time2text(logtime, "hh:mm")
					else
						logtime = "??:??"

					ulist[uid] = "[logtime] [groupnum] [udat.user_file.fields["name"]]"

				if (ulist.len)
					return ulist
				else
					return ESIG_GENERIC

			if (DWAINE_COMMAND_UMSG) //Send message to a user terminal, and ONLY user terminals (In contrast with msg_term)
				var/uid = data["term"]
				var/message = data["data"]
				if (!ckeyEx(message))
					return ESIG_GENERIC

				if (!uid)
					return ESIG_NOTARGET

				var/datum/mainframe2_user_data/target = src.users[uid]
				if (!istype(target))
					for (var/n in src.users)
						var/datum/mainframe2_user_data/testTarget = src.users[n]
						if (testTarget && testTarget.user_file && (lowertext(testTarget.user_file.fields["name"]) == uid))
							target = testTarget
							uid = n
							break

					if (!istype(target))
						return ESIG_NOTARGET

				else if (!istype(target.user_file))
					return ESIG_NOTARGET

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller || !caller.useracc)
					return ESIG_NOUSR

				if (caller.useracc == target)
					return ESIG_NOTARGET

				var/senderName = caller.useracc.user_name
				if (!senderName)
					return ESIG_NOUSR

				if (target.user_file.fields["accept_msg"] == "1")
					message_term("MSG from \[[senderName]]: [message]", uid, "multiline")
					return ESIG_SUCCESS
				else
					return ESIG_IOERR

			if (DWAINE_COMMAND_UINPUT) //Alternate path for user input
				. = ckey(data["term"])
				if (. in src.users)
					var/datum/mainframe2_user_data/the_user = src.users[.]
					if (!istype(the_user))
						login_user(., "TEMP")
						return ESIG_SUCCESS

					if (the_user.current_prog)
						if (file)
							the_user.current_prog.receive_progsignal(1, list("command"=DWAINE_COMMAND_RECVFILE, "user"=.), file)
						else
							the_user.current_prog.input_text(data["data"])
					else
						if (the_user.full_user)
							the_user.current_prog = master.run_program(get_file_name(setup_progname_shell, sysfolder), the_user, src)
						else
							the_user.current_prog = master.run_program(get_file_name(setup_progname_hello, sysfolder), the_user, src)

					return ESIG_SUCCESS

				return ESIG_NOUSR

			if (DWAINE_COMMAND_DMSG) //Send message to processing driver.
				var/driver_id = data["target"]
				if (data["mode"] == 1)
					for (var/datum/computer/file/mainframe_program/driver/D in processing_drivers)
						if (cmptext("[driver_id]",D.name))
							data["command"] = data["dcommand"]
							data["target"] = data["dtarget"]
							return D.receive_progsignal(sendid, data, file)

					return ESIG_NOTARGET


				if (!isnum(driver_id) || driver_id < 1 || driver_id > src.processing_drivers.len)
					return ESIG_NOTARGET

				var/datum/computer/file/mainframe_program/driver/D = src.processing_drivers[driver_id]
				if (istype(D))
					data["command"] = data["dcommand"]
					data["target"] = data["dtarget"]
					return D.receive_progsignal(sendid, data, file)

				return ESIG_NOTARGET

			if (DWAINE_COMMAND_DLIST) //List processing drivers.
				var/list/dlist = list()
				var/target_tag = lowertext(data["dtag"])
				var/omitWrongTags = (data["mode"] == 1 ? 1 : 0)
				for (var/x = 1, x <= processing_drivers.len, x++)
					if (target_tag && !omitWrongTags)
						dlist.len = x

					var/datum/computer/file/mainframe_program/driver/D = processing_drivers[x]
					if (istype(D))
						if (D.disposed)
							processing_drivers[x] = null
							continue

						if (target_tag && omitWrongTags)
							if(target_tag != D.termtag)
								continue
							dlist.Add("[D.name]")
							dlist["[D.name]"] = D.status
						else
							if (target_tag && target_tag != D.termtag)
								continue

							dlist[x] = "[D.name]"
							dlist[dlist[x]] = D.status
					else if (!omitWrongTags)
						if (x > dlist.len)
							break
						dlist[x] = ""

				if (dlist.len)
					return dlist
				else
					return ESIG_GENERIC

			if (DWAINE_COMMAND_DGET) //Get ID of processing driver.
				var/target_tag = lowertext(data["dtag"])
				if (!target_tag)
					target_tag = lowertext(data["dnetid"])

					if (!target_tag)
						return ESIG_NOTARGET

				for (var/x = 1, x <= processing_drivers.len, x++)
					var/datum/computer/file/mainframe_program/driver/D = processing_drivers[x]
					if (istype(D) && (D.termtag == target_tag || D.name == target_tag))
						if (D.disposed)
							processing_drivers[x] = null
							continue

						return (x | ESIG_DATABIT)

				return ESIG_NOTARGET

			if (DWAINE_COMMAND_DSCAN) //Instruct the mainframe to recheck for devices now instead of waiting for the full timeout.
				if (src.ping_accept)
					return ESIG_GENERIC

				src.master.reconnect_all_devices()
				src.master.timeout_alert = 0
				src.master.timeout = 5
				src.ping_accept = 5
				SPAWN(2 SECONDS)
					src.master.post_status("ping","data","DWAINE","net","[src.master.net_number]")

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_EXIT)
				if (!sendid)
					return ESIG_GENERIC
				var/datum/computer/file/mainframe_program/quitter = master.processing[sendid]
				if (!quitter || quitter == src)
					return ESIG_GENERIC

				if (!quitter.useracc)
					quitter.handle_quit()
					return ESIG_NOUSR

				var/datum/mainframe2_user_data/quituser = quitter.useracc
				var/datum/computer/file/mainframe_program/shellbase = get_file_name(setup_progname_shell, sysfolder)
				var/shellexit = (shellbase && shellbase.type == quitter.type && quitter.parent_id == src.progid)

				var/datum/computer/file/mainframe_program/quitparent = quitter.parent_task
				quitter.handle_quit()

				if (istype(quitparent) && (quitparent != src) && !istype(quitparent, /datum/computer/file/mainframe_program/driver/mountable/radio)) //Hello, this last istype() is a dirty hack.
					if (quituser.current_prog == quitter)
						quituser.current_prog = quitparent
					quitparent.useracc = quituser
					quitparent.receive_progsignal(1, list("command"=DWAINE_COMMAND_TEXIT,"id"=sendid))

				else if (shellexit && quituser) //Outermost shell should only exit if things go really wrong or the user logs out.  big shell....  buddy gear....
					var/quituser_id = quituser.user_id
					logout_user(quituser, 0)
					login_temp_user(quituser_id) //As they didn't disconnect the the terminal, we should present a new login screen there.
				else
					src.master.run_program(shellbase, quituser, quitparent ? quitparent : src)

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_TSPAWN) //Spawn task
				if (!data["path"])
					return ESIG_NOTARGET

				if (!sendid)
					return ESIG_GENERIC

				var/pass_user = (data["passusr"] == 1)

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/task_model = parse_file_directory(data["path"], src.holder.root, 0)
				if (!task_model || !task_model.executable)
					return ESIG_NOTARGET

				task_model = src.master.run_program(task_model, (pass_user ? caller.useracc : null), caller, data["args"])
				if (!task_model)
					return ESIG_GENERIC

				return task_model

			if (DWAINE_COMMAND_TFORK)
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/fork = src.master.run_program(caller, null, caller, data["args"], 1)
				if (!fork)
					return ESIG_GENERIC

				return fork.progid | ESIG_DATABIT

			if (DWAINE_COMMAND_TKILL) //Kill a child task of the calling program.
				if (!sendid)
					return ESIG_NOTARGET

				var/target_id = data["target"]
				if (!isnum(target_id) || target_id < 0 || target_id > master.processing.len)
					return ESIG_NOTARGET

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/target_task = master.processing[target_id]
				if (!target_task)
					return ESIG_SUCCESS

				if (target_task.parent_task != caller)
					return ESIG_GENERIC

				var/datum/mainframe2_user_data/target_user = target_task.useracc

				if (target_user && (!caller.useracc || target_user.current_prog == target_task))
					target_user.current_prog = caller
					caller.useracc = target_user

				target_task.handle_quit()

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_TLIST) //List all child tasks of the calling program.
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!caller)
					return ESIG_GENERIC

				. = list()

				for (var/x = 1, x <= master.processing.len, x++)
					var/datum/computer/file/mainframe_program/MP = master.processing[x]
					if (MP && MP.parent_task == caller)
						.[x] = MP
					else
						.[x] = null

				return .

			if (DWAINE_COMMAND_FGET) //Return the computer datum at the provided path, if it exists.
				//boutput(world, "entering fget with path \"[data["path"]]\"")
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!data["path"] || !caller)
					return ESIG_NOTARGET

				. = parse_datum_directory(data["path"], src.holder.root, 0, caller.useracc)
				if (.)
					//boutput(world, "F is [F.name], a [istype(F, /datum/computer/file) ? "FILE" : "FOLDER"]")
					return .
				else
					//boutput(world, "a bad F")
					return ESIG_NOFILE

			if (DWAINE_COMMAND_FKILL) //Delete the computer datum at the provided path, if possible.
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!data["path"] || !caller)
					return ESIG_NOTARGET

				var/datum/mainframe2_user_data/the_user = caller.useracc

				var/datum/computer/F = parse_datum_directory(data["path"], src.holder.root, 0, the_user)
				if (F && (F.holding_folder != master.runfolder && F != master.runfolder && F != src.holder.root) && (!the_user || check_mode_permission(F, the_user)))
					if (istype(F.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
						F.holding_folder.remove_file(F)
						return ESIG_SUCCESS

//					qdel(F)
					F.dispose()
					return ESIG_SUCCESS
				else
					return ESIG_NOFILE

			if (DWAINE_COMMAND_FMODE) //Adjust the permissions of the file at the provided path, if possible.
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!data["path"] || !caller)
					return ESIG_NOTARGET

				if (!isnum(data["permission"]))
					return ESIG_GENERIC

				var/datum/computer/target_datum = parse_datum_directory(data["path"], src.holder.root, 0, caller.useracc)
				if (!istype(target_datum))
					return ESIG_NOFILE

				if (caller.useracc && !check_mode_permission(target_datum, caller.useracc))
					return ESIG_GENERIC

				change_metadata(target_datum, "permission", data["permission"])

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_FOWNER)
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!data["path"] || !caller)
					return ESIG_NOTARGET

				if (!isnum(data["group"]) && !data["owner"])
					return ESIG_GENERIC

				var/datum/computer/target_datum = parse_datum_directory(data["path"], src.holder.root, 0, caller.useracc)
				if (!istype(target_datum))
					return ESIG_NOFILE

				if (caller.useracc && !check_mode_permission(target_datum, caller.useracc))
					return ESIG_GENERIC

				if (data["owner"])
					change_metadata(target_datum, "owner", copytext(data["owner"], 1, 16))

				if (isnum(data["group"]))
					change_metadata(target_datum, "group", clamp(data["group"], 0, 255))

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_FWRITE) //Write a provided file to the provided path.  If it already exists and ["replace"] is 1, overwrite it.  If ["append"] is 1, add to it.
				if (!sendid)
					return ESIG_GENERIC

				var/datum/computer/file/mainframe_program/caller = master.processing[sendid]
				if (!data["path"] || !caller || !file)
					return ESIG_NOTARGET

				if (is_name_invalid(file.name))
					return ESIG_GENERIC

				var/datum/mainframe2_user_data/the_user = caller.useracc
				var/create_path = (data["mkdir"] == 1)

				var/datum/computer/folder/destination = parse_directory(data["path"], src.holder.root, create_path, the_user)
				if (!destination || destination == master.runfolder)
					return ESIG_NOTARGET

				var/datum/computer/file/record/destfile = get_computer_datum(file.name, destination)
				var/delete_dest = 0
				if (destfile)
					if (istype(destfile, /datum/computer/folder))
						destination = destfile

					if (istype(destination, /datum/computer/folder/link) && destination:target)
						if (the_user && !check_write_permission(destination:target, the_user))
							return ESIG_NOWRITE
					else
						if (the_user && !check_write_permission(destination, the_user))
							return ESIG_NOWRITE

					//We can append if instructed (And currently just if both files are records).
					if (data["append"] == 1 && (!the_user || check_write_permission(destfile, the_user)) && (istype(destfile) && istype(file, /datum/computer/file/record)))
						file:fields = destfile.fields + file:fields
						delete_dest = 1

					 //We could also instead just overwrite the file.
					else if (data["replace"] == 1 && (!the_user || check_mode_permission(destfile, the_user)))
						delete_dest = 1

					else if (istype(destfile, /datum/computer/file))
						return ESIG_GENERIC

				if (!destination.can_add_file(file, the_user))
					return ESIG_GENERIC

				if (the_user && !check_write_permission(destination, the_user))
					return ESIG_NOWRITE

				if (delete_dest && destfile)
					//qdel(destfile)
					destfile.dispose()

				destination.add_file(file, the_user)

				return ESIG_SUCCESS

			if (DWAINE_COMMAND_CONFGET)
				if (!data["fname"])
					return ESIG_NOTARGET

				var/datum/computer/folder/confDir = parse_directory(setup_filepath_config, src.holder.root, 0)
				if (!confDir)
					return ESIG_NOTARGET

				var/datum/computer/file/F = get_file_name(data["fname"], confDir)
				if (F)
					return F
				else
					return ESIG_NOFILE

			if (DWAINE_COMMAND_MOUNT)
				if (!data["id"])
					return ESIG_NOTARGET

				var/datum/computer/file/mainframe_program/driver/mountable/Mcheck = parse_file_directory("[setup_filepath_drivers]/_[data["id"]]", src.holder.root, 0)
				if (!istype(Mcheck))
					return ESIG_NOTARGET

				var/datum/computer/folder/mountfolder = parse_directory(setup_filepath_volumes, src.holder.root, 1)
				if (!istype(mountfolder))
					return ESIG_NOTARGET

				var/datum/computer/folder/mountpoint/mountpoint = get_computer_datum("_[data["id"]]", mountfolder)
				if (!istype(mountpoint))
					if (istype(mountpoint, /datum/computer)) //Name is taken B(
						return ESIG_GENERIC

				else
					//qdel(mountpoint)
					mountpoint.dispose()

				mountpoint = new /datum/computer/folder/mountpoint( Mcheck )
				mountpoint.name = "_[data["id"]]"
				if (!mountfolder.add_file(mountpoint))
					//qdel(mountpoint)
					mountpoint.dispose()
					return ESIG_GENERIC

				if (data["link"])
					var/datum/computer/folder/link/symlink = get_computer_datum(data["link"], mountfolder)
					if (istype(symlink) || (!istype(symlink, /datum/computer)) )
						//qdel(symlink)
						if (symlink)
							symlink.dispose()

						symlink = new /datum/computer/folder/link( mountpoint )
						symlink.name = data["link"]
						if (!mountfolder.add_file(symlink))
							//qdel(symlink)
							symlink.dispose()

				mountpoint.metadata["permission"] = Mcheck.default_permission
				mountpoint.metadata["group"] = 1
				mountpoint.metadata["owner"] = "Nobody"
				return ESIG_SUCCESS

			else
				return ESIG_BADCOMMAND

	process()
		if (..())
			return

		if (src.ping_accept)
			src.ping_accept--

		if (src.rescan_timer)
			src.rescan_timer--
			if (src.rescan_timer <= 0)
				src.rescan_timer = initial(src.rescan_timer)
				src.ping_accept = 4
				SPAWN(1 DECI SECOND)
					src.master.post_status("ping","data","DWAINE","net","[src.master.net_number]")

		return

	proc
		initialize_users()
			for (var/i in src.users) //Clear out the user list...
				var/datum/mainframe2_user_data/D = src.users[i]
				//qdel(D)
				D.dispose()

			users.len = 0

			//User data folder.
			var/datum/computer/folder/uF = parse_directory(setup_filepath_users, src.holder.root, 1)
			//User home folder
			var/datum/computer/folder/hF = parse_directory(setup_filepath_users_home, src.holder.root, 1)

			if (!uF || !hF)
				return 1

			uF.metadata["permission"] = COMP_HIDDEN

			//To-do: Kinda merge this and stuff.
			for (var/i in master.terminals)
				var/datum/terminal_connection/conn = master.terminals[i]
				if(!istype(conn) || conn.term_type != "HUI_TERMINAL")
					continue

				//src.users += conn.net_id
				login_temp_user(conn.net_id)

			for (var/datum/computer/file/record/uRec in uF.contents)
				if (isnull(uRec.fields["name"]) || isnull(uRec.fields["id"]) || isnull(uRec.fields["group"])) //This record isn't a valid user file!
					//qdel(uRec) //Clean house!!
					uRec.dispose()
					continue

				//Make sure our PRECISE NAME SCHEME is preserved!
				if (!dd_hassuffix(uRec.fields["id"]))
					if ( isnull(get_file_name("usr[uRec.fields["id"]]", uF)) )
						uRec.name = "usr[uRec.fields["id"]]"
					else
						//qdel(uRec)
						uRec.dispose()
						continue

				//Now to create a home directory for this user
				var/datum/computer/folder/new_home = get_folder_name("usr[uRec.fields["name"]]", hF)
				if (istype(new_home))
					return 0

				new_home = new /datum/computer/folder(  )
				new_home.name = "usr[uRec.fields["name"]]"
				new_home.metadata["owner"] = uRec.fields["name"]
				uRec.metadata["owner"] = uRec.fields["name"]
				new_home.metadata["permission"] = COMP_ROWNER|COMP_WOWNER|COMP_DOWNER
				uRec.metadata["permission"] = COMP_ROWNER|COMP_WOWNER
				if (!hF.add_file(new_home))
					//qdel(new_home)
					new_home.dispose()
					continue

			return 0

		login_temp_user(var/user_netid, var/datum/computer/file/record/login_record, var/datum/computer/file/mainframe_program/caller_override)
			if (users.len >= user_max)
				return 1

			if (!user_netid)
				return 1

			var/datum/computer/file/mainframe_program/helloprog = get_file_name(setup_progname_hello, sysfolder)
			if (!istype(helloprog))
				return 1

			var/datum/mainframe2_user_data/new_user = new /datum/mainframe2_user_data(  )
			new_user.user_name = "TEMP"
			new_user.user_id = user_netid
			//new_user.user_file = uRec

			users[user_netid] = new_user

			if (istype(login_record) && login_record.fields && login_record.fields["registered"] && login_record.fields["assignment"])
				if (login_user(new_user, login_record.fields["registered"], 0) != 1)

					var/datum/computer/file/mainframe_program/shellbase = get_file_name(setup_progname_shell, sysfolder)
					if (istype(shellbase))
						master.run_program(shellbase, new_user, istype(caller_override) ? caller_override : src)
						return 0

			helloprog = master.run_program(helloprog, new_user, istype(caller_override) ? caller_override : src)
			if (!istype(helloprog))
				return 1

			return 0

		login_user(var/datum/mainframe2_user_data/account, var/user_name, var/sysop = 0, var/interactive = 1)
			if (!account || account.full_user || !user_name)
				return 1

			//User data folder.
			var/datum/computer/folder/uF = parse_directory(setup_filepath_users, src.holder.root, 1)
			//User home folder
			var/datum/computer/folder/hF = parse_directory(setup_filepath_users_home, src.holder.root, 1)

			if (!uF || !hF || !sysfolder)
				return 1

			user_name = format_username(user_name)

			uF.metadata["permission"] = COMP_HIDDEN
			hF.metadata["permission"] = COMP_ROWNER|COMP_RGROUP|COMP_ROTHER

			var/name_attempt = 0
			var/attemptedname = null

			var/datum/computer/file/record/uRec = null
			while (name_attempt < 10)
				attemptedname = "usr[user_name][name_attempt]"
				if (length(attemptedname) > 16)
					attemptedname = copytext(attemptedname, 1, 15) + "[name_attempt]"
				var/datum/computer/file/record/check = get_computer_datum(attemptedname, uF)
				if (check)
					if (!interactive)	//Prevent a billion duplicate copies from a service terminal reconnecting
						check.dispose()
					else
						name_attempt++
						continue

				uRec = new /datum/computer/file/record(src)
				uRec.name = attemptedname
				if (get_computer_datum(uRec.name, uF))
					//qdel(uRec)
					uRec.dispose()
					name_attempt++
					continue

				if (!uF.add_file(uRec))
					//qdel(uRec)
					uRec.dispose()
					return 1

				break

			if (!uRec)
				return 1

			user_name = "[user_name][name_attempt]"

			account.user_name = user_name
			account.user_file = uRec
			account.user_file_folder = uRec.holding_folder
			account.user_filename = uRec.name
			account.full_user = 1

			uRec.fields["name"] = user_name
			uRec.fields["id"] = account.user_id
			uRec.fields["group"] = !sysop
			uRec.fields["logtime"] = world.realtime
			uRec.fields["accept_msg"] = "1"
			uRec.metadata["owner"] = uRec.fields["name"]
			uRec.metadata["permission"] = COMP_ROWNER|COMP_WOWNER

			//Now to create a home directory for the user
			if (interactive)
				var/datum/computer/folder/new_home = get_computer_datum(attemptedname, hF)
				if (!istype(new_home))
					new_home = new /datum/computer/folder(  )
					new_home.name = attemptedname
					new_home.metadata["owner"] = uRec.fields["name"]
					new_home.metadata["permission"] = COMP_ROWNER|COMP_WOWNER|COMP_DOWNER
					if (!hF.add_file(new_home))
						//qdel(new_home)
						new_home.dispose()
						return 1
/*
			helloprog = master.run_program(helloprog, account)
			if (!istype(helloprog))
				return 1
*/
			return 0


		logout_user(var/datum/mainframe2_user_data/the_user, disconnect = 0)
			if (!the_user)
				return 1

			if (disconnect) //The terminal device is no longer connected, so no need to wait for a new login from them.
				src.users -= the_user.user_id
			if (the_user.current_prog)
				the_user.current_prog.handle_quit()

			if (the_user.user_file)
				//qdel(the_user.user_file)
				the_user.user_file.dispose()

			the_user.dispose()

			return 0

		initialize_drivers()
			//Active driver folder
			var/datum/computer/folder/dF = parse_directory(setup_filepath_drivers, src.holder.root, 1)
			//Driver prototype folder
			var/datum/computer/folder/pF = parse_directory(setup_filepath_drivers_proto, src.holder.root, 1)

			if (!dF || !pF)
				return 1

			dF.metadata["permission"] = COMP_HIDDEN

			//Might as well clear out any active drivers, they might have out of date information or something.
			for (var/datum/computer/file/mainframe_program/driver/D in dF.contents)
				//qdel(D)
				D.dispose()

			. = 0
			for (var/datum/computer/file/mainframe_program/driver/special_driver in pF.contents)
				if (!cmptext(copytext(special_driver.name, 1, 5), "int_"))
					continue

				special_driver = special_driver.copy_file()
				var/newtag = special_driver.name
				special_driver.name = "000000[. > 9 ? .++ : "0[.++]"]"
				special_driver.master = src.master
				special_driver.termtag = copytext(newtag, 5)

				if (!dF.add_file(special_driver))
					special_driver.dispose()
				else
					if (special_driver.setup_processes)
						if (!(special_driver in src.processing_drivers))
							src.processing_drivers += special_driver
						if(!(special_driver in src.master.processing))
							var/success = 0
							for (var/x = 1, x <= src.master.processing.len, x++)
								if (src.master.processing[x] != null)
									continue

								src.master.processing[x] = special_driver
								special_driver.progid = x
								success = 1
								break

							if (!success)
								src.master.processing += special_driver
								special_driver.progid = length(src.master.processing)

					special_driver.initialize()
/*
			//See if there's a user terminal driver to set up
			var/datum/computer/file/mainframe_program/driver/hui_driver = get_file_name("hui_terminal", pF)
			if (istype(hui_driver))
				hui_driver = hui_driver.copy_file()
				hui_driver.name = "00000000"
				hui_driver.termtag = "hui_terminal"
				hui_driver.master = src.master
				if (!dF.add_file(hui_driver))
					hui_driver.dispose()
				else
					if (hui_driver.setup_processes)
						if (!(hui_driver in src.processing_drivers))
							src.processing_drivers += hui_driver
						if(!(hui_driver in src.master.processing))
							var/success = 0
							for (var/x = 1, x <= src.master.processing.len, x++)
								if (src.master.processing[x] != null)
									continue

								src.master.processing[x] = hui_driver
								hui_driver.progid = x
								success = 1
								break

							if (!success)
								src.master.processing += hui_driver
								hui_driver.progid = length(src.master.processing)

					hui_driver.initialize()
*/
			//Iterate through current devices and use that to make some active device files.
			for (var/i in src.master.terminals)
				var/datum/terminal_connection/TC = src.master.terminals[i]
				if (!istype(TC))
					continue

				if (TC.term_type == "HUI_TERMINAL")
					continue

				var/TCtype = lowertext(TC.term_type)
				if (copytext(TCtype, 1, 6) == "pnet_")
					TCtype = copytext(TCtype,6)

				var/datum/computer/file/mainframe_program/driver/newdriver = get_file_name(TCtype, pF)
				if (!istype(newdriver))
					continue

				newdriver = newdriver.copy_file()
				newdriver.name = i
				newdriver.termtag = TCtype
				newdriver.master = src.master
				newdriver.initialized = 1
				if (!dF.add_file(newdriver))
					//qdel(newdriver)
					newdriver.dispose()
					continue

				if (newdriver.setup_processes)
					if (!(newdriver in src.processing_drivers))
						src.processing_drivers += newdriver
					if(!(newdriver in src.master.processing))
						var/success = 0
						for (var/x = 1, x <= src.master.processing.len, x++)
							if (src.master.processing[x] != null)
								continue

							src.master.processing[x] = newdriver
							newdriver.progid = x
							success = 1
							break

						if (!success)
							src.master.processing += newdriver
							newdriver.progid = length(src.master.processing)

				newdriver.initialize()

			return 0

		is_sysop(var/datum/mainframe2_user_data/udat)
			if (!udat || !udat.user_file)
				return 0

			if (udat.user_file.fields["group"] != 0)
				return 0

			return 1

		change_metadata(var/datum/computer/file/file, var/field, var/newval)
			if (!field || !file)
				return 0

			if (istype(file.holding_folder, /datum/computer/file/mainframe_program/driver/mountable))
				var/datum/computer/file/mainframe_program/driver/mountable/M = file.holding_folder
				return M.change_metadata(file, field, newval)

			file.metadata[field] = newval
			return 1

		message_all_users(var/message, var/senderName, var/ignore_user_file_setting)
			if (!senderName)
				senderName = "System"

			for (var/user_id in src.users)
				var/datum/mainframe2_user_data/target = src.users[user_id]
				if (!istype(target))
					continue

				if (!istype(target.user_file))
					continue

				if (ignore_user_file_setting || target.user_file.fields["accept_msg"] == "1")
					message_term("MSG from \[[senderName]]: [message]", user_id, "multiline")

			return

//User login manager
/datum/computer/file/mainframe_program/login
	name = "Login"
	size = 2
	executable = 0

	var/motd = "Welcome to DWAINE System VI!|nCopyright 2050 Thinktronic Systems, LTD."
	var/setup_filename_motd = "motd"

	initialize()
		if(..())
			return

		var/datum/computer/file/record/R = signal_program(1, list("command"=DWAINE_COMMAND_CONFGET,"fname"=setup_filename_motd))
		if (istype(R))
			src.motd = ""
			var/imax = min(5, R.fields.len)
			for (var/i = 1, i <= imax, i++)
				src.motd += (R.fields[i] + (i < imax ? "|n" : null))

			src.motd = copytext(src.motd, 1, 255)
		else
			src.motd = initial(src.motd)

		message_user("[src.motd]|nPlease enter card and \"term_login\"", "multiline")
		return

	receive_progsignal(var/sendid, var/list/data, var/datum/computer/file/file)
		if (..() || (data["command"] != DWAINE_COMMAND_RECVFILE) || !istype(file, /datum/computer/file/record))
			return ESIG_GENERIC

		if (!src.useracc)
			return ESIG_NOUSR

		var/datum/computer/file/record/usdat = file
		if (!usdat.fields["registered"] || !usdat.fields["assignment"])
			return ESIG_GENERIC

		if (signal_program(1, list("command"=DWAINE_COMMAND_ULOGIN, "name"=usdat.fields["registered"])) != ESIG_SUCCESS)
			message_user("Error: Login failure.  Please try again.")
			return ESIG_GENERIC

		mainframe_prog_exit
		return


#undef setup_filepath_users
#undef setup_filepath_users_home
#undef setup_filepath_drivers
#undef setup_filepath_drivers_proto
#undef setup_filepath_volumes
#undef setup_filepath_system
#undef setup_filepath_config
#undef setup_filepath_commands
#undef setup_filepath_process
