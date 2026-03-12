/datum/client_auth_gate/whitelist
	check(client/C)
		if (!config.whitelistEnabled || IsLocalClient(C)) return TRUE

		// Active admins are always allowed
		if (C.client_auth_intent.admin && C.client_auth_intent.admin_rank != "Inactive") return TRUE

		// Check if the client is on the whitelist
		if (C.client_auth_intent.whitelisted) return TRUE

		return FALSE

/datum/client_auth_gate/whitelist/get_failure_message(client/C)
	return {"
		<h1>Server Whitelist Enabled</h1>
		This server has a player whitelist ON. You are not on the whitelist and will now be disconnected.
	"}
