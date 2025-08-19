/datum/client_auth_gate/version
	check(client/C)
		#ifndef LIVE_SERVER
		. = TRUE
		UNLINT(return)
		#endif

		if (IsLocalClient(C)) return TRUE

		// Set the minimum client version required here
		if (C.byond_version >= 516 && C.byond_build >= 1665) return TRUE

		if (C.byond_version >= 517)
			if (tgui_alert(C, "You have connected with an unsupported BYOND beta version, and you may encounter major issues. For the best experience, please downgrade BYOND to the current stable release. Would you like to visit the download page?", "ALERT", list("Yes", "No"), 30 SECONDS) == "Yes")
				C << link("https://spacestation13.github.io/byond-builds/516/516.latest_byond.exe")
			return TRUE

		logTheThing(LOG_ADMIN, C, "connected with outdated client version [C.byond_version].[C.byond_build]. Request to update client sent to user.")
		return FALSE

/datum/client_auth_gate/version/get_failure_message(client/C)
	return {"
		<h1>Outdated Client Version</h1>
		Please update your client to the latest version.
		<br><br>
		<a href="https://spacestation13.github.io/byond-builds/516/516_latest.exe">Download the latest version</a>
		<br>
		Or, download the <a href="https://github.com/goonstation/launcher/releases/latest">Goonstation Launcher</a> to be prompted to update automatically.
	"}
