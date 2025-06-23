/datum/client_auth_gate
	proc/check(client/C)
		return TRUE

	proc/fail(client/C)
		logTheThing(LOG_DEBUG, C, "failed to pass gate check: [src]")
		C.on_auth_failed()
