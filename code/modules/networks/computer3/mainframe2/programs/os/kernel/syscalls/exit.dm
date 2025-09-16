/datum/dwaine_syscall/exit
	id = DWAINE_COMMAND_EXIT

/datum/dwaine_syscall/exit/execute(sendid, list/data, datum/computer/file/file)
	if (!sendid)
		return ESIG_GENERIC

	var/datum/computer/file/mainframe_program/caller_prog = src.kernel.master.processing[sendid]
	if (!caller_prog || (caller_prog == src.kernel))
		return ESIG_GENERIC

	if (!caller_prog.useracc)
		caller_prog.handle_quit()
		return ESIG_NOUSR

	var/datum/mainframe2_user_data/user = caller_prog.useracc
	var/datum/computer/file/mainframe_program/shellbase = src.kernel.get_file_name(src.kernel.setup_progname_shell, src.kernel.sys_folder)
	var/shellexit = (shellbase && (shellbase.type == caller_prog.type) && (caller_prog.parent_id == src.kernel.progid))

	var/datum/computer/file/mainframe_program/quitparent = caller_prog.parent_task
	caller_prog.handle_quit()

	if (istype(quitparent) && !QDELETED(quitparent) && (quitparent != src.kernel) && !istype(quitparent, /datum/computer/file/mainframe_program/driver/mountable/radio)) // Hello, this last istype() is a dirty hack.
		if (user.current_prog == caller_prog)
			user.current_prog = quitparent
		quitparent.useracc = user
		quitparent.receive_progsignal(1, list("command" = DWAINE_COMMAND_TEXIT, "id" = sendid))

	else if (QDELETED(quitparent) && !QDELETED(user.base_shell_instance)) // We can't use quitparent if it is already queued for deletion! Lets hope our shellbase didn't get randomly deleted!
		if (user.current_prog == caller_prog)
			user.current_prog = user.base_shell_instance // So instead, we return user back to the main shell-
		user.base_shell_instance.useracc = user

	else if (shellexit && user) // Outermost shell should only exit if things go really wrong or the user logs out.
		var/user_id = user.user_id
		src.kernel.logout_user(user, FALSE)

		// As they didn't disconnect the the terminal, we should present a new login screen there.
		src.kernel.login_temp_user(user_id)

	else
		src.kernel.master.run_program(shellbase, user, (quitparent || src.kernel))

	return ESIG_SUCCESS
