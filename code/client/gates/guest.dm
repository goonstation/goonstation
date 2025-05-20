/datum/client_auth_gate/guest
	check(client/C)
		if (!IsGuestKey(C.key) || IsLocalClient(C)) return TRUE

		SPAWN(-1)
			C.Browse({"
				<!doctype html>
				<html>
					<head>
						<title>No guest logins allowed!</title>
						<style>
							h1 {
								font-color:#F00;
							}
						</style>
					</head>
					<body>
						<h1>Guest Login Denied</h1>
						Don't forget to log in to your byond account prior to connecting to this server.
					</body>
				</html>
			"}, "window=getout")

		return FALSE
