/datum/client_auth_gate/telnet
	check(client/C)
		if (!findtext(C.key, "Telnet @") || IsLocalClient(C)) return TRUE
		return FALSE

/datum/client_auth_gate/telnet/get_failure_message(client/C)
	return {"
		<h1>Telnet Login Denied</h1>
		Sorry, this game does not support Telnet.
	"}
