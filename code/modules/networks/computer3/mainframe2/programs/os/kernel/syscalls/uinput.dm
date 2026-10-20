/datum/dwaine_syscall/uinput
	id = DWAINE::SYSCALL::UINPUT

/datum/dwaine_syscall/uinput/execute(sendid, list/data, datum/computer/file/file)
	var/net_id = ckey(data["term"])
	var/datum/mainframe2_user_data/user = src.kernel.users[net_id]

	if (!user)
		return DWAINE::ERR::SIG::NOUSR

	if (!istype(user))
		src.kernel.login_user(net_id, "TEMP")
		return DWAINE::ERR::SIG::SUCCESS

	if (user.current_prog)
		if (file)
			user.current_prog.receive_progsignal(1, list("command" = DWAINE::SYSCALL::RECVFILE, "user" = net_id), file)
		else
			user.current_prog.input_text(data["data"])
	else
		if (user.full_user)
			user.current_prog = src.kernel.master.run_program(src.kernel.get_file_name(src.kernel.setup_progname_shell, src.kernel.sys_folder), user, src.kernel)
		else
			user.current_prog = src.kernel.master.run_program(src.kernel.get_file_name(src.kernel.setup_progname_login, src.kernel.sys_folder), user, src.kernel)

	return DWAINE::ERR::SIG::SUCCESS
