/datum/client_auth_gate/guest
	check(client/C)
		if (!IsGuestKey(C.key) || IsLocalClient(C)) return TRUE
		return FALSE

/datum/client_auth_gate/guest/get_failure_message(client/C)
	return {"
		<h1>Guest Login Denied</h1>
		Don't forget to log in to your Byond account prior to connecting to this server.
	"}
