/datum/client_auth_gate/telnet
	check(client/C)
		if (!findtext(C.key, "Telnet @") || IsLocalClient(C)) return TRUE

		SPAWN(-1)
			C.Browse({"
				<!doctype html>
				<html>
					<head>
						<title>Telnet Login Denied</title>
						<style>
							h1 {
								font-color:#F00;
							}
						</style>
					</head>
					<body>
						<h1>Sorry, this game does not support Telnet.</h1>
					</body>
				</html>
			"}, "window=getout")

		return FALSE
