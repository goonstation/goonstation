/datum/client_auth_gate/version
	check(client/C)
		#ifndef LIVE_SERVER
		UNLINT(return TRUE)
		#endif

		if (IsLocalClient(C)) return TRUE

		// Set the minimum client version required here
		if (C.byond_version >= 515 && C.byond_build >= 1633) return TRUE

		if (C.byond_version >= 517)
			if (tgui_alert(C, "You have connected with an unsupported BYOND beta version, and you may encounter major issues. For the best experience, please downgrade BYOND to the current stable release. Would you like to visit the download page?", "ALERT", list("Yes", "No"), 30 SECONDS) == "Yes")
				// TODO: mirror for download url
				C << link("https://www.byond.com/download/build/516")
			return TRUE

		SPAWN(-1)
			logTheThing(LOG_ADMIN, C, "connected with outdated client version [C.byond_version].[C.byond_build]. Request to update client sent to user.")

			if (tgui_alert(C, "Consider UPDATING BYOND to the latest version! Would you like to be taken to the download page now? Make sure to download the latest 515 version (at the bottom of the page).", "ALERT", list("Yes", "No"), 30 SECONDS) == "Yes")
				// TODO: mirror for download url
				C << link("https://www.byond.com/download/build/516")

			C.Browse({"
				<!doctype html>
				<html>
					<head>
						<title>Outdated Client Version</title>
						<style>
							h1 {
								font-color:#F00;
							}
						</style>
					</head>
					<body>
						<h1>Outdated Client Version</h1>
						Please update your client to the latest version.
					</body>
				</html>
			"}, "window=versionoutdated")

		return FALSE
