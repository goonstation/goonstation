/datum/dwaine_syscall/dscan
	id = DWAINE_COMMAND_DSCAN

/datum/dwaine_syscall/dscan/execute(sendid, list/data, datum/computer/file/file)
	if (src.kernel.ping_accept)
		return ESIG_GENERIC

	src.kernel.master.reconnect_all_devices()
	src.kernel.master.timeout_alert = FALSE
	src.kernel.master.timeout = 5
	src.kernel.ping_accept = 5

	SPAWN(2 SECONDS)
		src.kernel.master.post_status("ping", "data", "DWAINE", "net", "[src.kernel.master.net_number]")

	return ESIG_SUCCESS
