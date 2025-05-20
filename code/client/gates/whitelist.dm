/datum/client_auth_gate/whitelist
	check(client/C)
		if (!config.whitelistEnabled || IsLocalClient(C)) return TRUE

		// Admins are always allowed
		if (C.client_auth_intent.admin) return TRUE

		// Check if the client is on the whitelist
		if (C.ckey in whitelistCkeys) return TRUE

		// If the client is not on the whitelist, show them a message and boot them
		SPAWN(-1)
			C.Browse({"
				<!doctype html>
				<html>
					<head>
						<title>Server Whitelist Enabled</title>
						<style>
							h1 {
								font-color:#F00;
							}
						</style>
					</head>
					<body>
						<h1>Server whitelist enabled</h1>
						This server has a player whitelist ON. You are not on the whitelist and will now be forcibly disconnected.
					</body>
				</html>
			"}, "window=whiteout")

		return FALSE
