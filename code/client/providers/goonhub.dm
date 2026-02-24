/datum/client_auth_provider/goonhub
	name = "Goonhub"
	start_state = CLIENT_AUTH_PENDING
	can_logout = TRUE
	var/timeout = 20 MINUTES
	var/token = ""
	var/pending_success_message = FALSE

/datum/client_auth_provider/goonhub/New(client/owner)
	. = ..()
	if (!src.valid) return
	RegisterSignal(owner, COMSIG_CLIENT_CHAT_LOADED, PROC_REF(on_chat_loaded))
	src.owner.verbs += list(/client/proc/open_goonhub_auth)
	src.setup_logout()
	src.hide_ui()
	if (src.begin_auth())
		src.show_external()
	else
		logTheThing(LOG_ADMIN, null, "Failed to begin auth for [src.owner]", "admin")
		src.on_error("Failed to load login window. Please reconnect and try again.")
		return

	SPAWN(src.timeout)
		src.on_timeout()

/datum/client_auth_provider/goonhub/Topic(href, href_list)
	if (href_list["logout"])
		src.on_logout()

/**
	* On error
	*
	* Called when the auth process errors
	*
	* Arguments:
	* * error (string) - The error message
*/
/datum/client_auth_provider/goonhub/proc/on_error(error)
	src.owner << output(list2params(list(error)), "mainwindow.authexternal:GoonhubAuth.onError")
	src.on_auth_failed()

/**
	* On timeout
	*
	* Called when the auth process times out
	*/
/datum/client_auth_provider/goonhub/proc/on_timeout()
	if (!src.owner || src.authenticated) return
	src.on_error("You failed to authenticate in time and have been disconnected. Please reconnect and try again.")

/**
	* Begin auth
	*
	* Begins the auth process for the client
	*
	* Returns TRUE if the auth process was successful, FALSE otherwise
	*/
/datum/client_auth_provider/goonhub/proc/begin_auth()
	var/datum/apiRoute/gameauth/begin/beginAuth = new
	beginAuth.buildBody(
		src.timeout / 10,
		config.server_id,
		src.owner.ckey,
		src.owner.key,
		src.owner.address ? src.owner.address : "127.0.0.1", // fallback for local dev
		src.owner.computer_id,
		src.owner.byond_version,
		src.owner.byond_build,
		roundId
	)
	try
		var/datum/apiModel/BeginAuthResource/begin = apiHandler.queryAPI(beginAuth)
		src.token = begin.token
		return TRUE
	catch (var/exception/e)
		var/datum/apiModel/Error/errorModel = e.name
		logTheThing(LOG_ADMIN, null, "Failed to begin auth for [src.owner] because: [errorModel.message]", "admin")
		return FALSE

/**
	* On auth
	*
	* Called in world/Topic "auth_callback" route
	*
	* Arguments:
	* * verification (string) - The verification data
	*/
/datum/client_auth_provider/goonhub/on_auth(verification)
	src.token = "" // Token consumed
	try
		verification = json_decode(verification)
	catch (var/exception/e)
		logTheThing(LOG_ADMIN, null, "Failed to decode auth data for [src.owner] because: [e]", "admin")
		src.on_error("Failed to verify your account. Please reconnect and try again.")
		return

	//so I have a theory
	//Byond has a nasty habit of not deleting clients immediately on the game closing (worse if it's an improper disconnect)
	//what if all our issues are due to the key we're trying to assign to already being logged in on a stale client that has yet to del?
	for (var/client/C as anything in global.clients)
		if (C.key == verification["key"])
			del(C)
			logTheThing(LOG_DEBUG, src.owner, "During goonhub auth, client [src.owner] requested key [C.key], which is already in use by client [C]. Assuming the old one is a stale client and deleting.")
			break

	src.pending_success_message = TRUE
	src.owner.verbs -= list(/client/proc/open_goonhub_auth)

	src.owner.client_auth_intent.ckey = verification["ckey"]
	src.owner.client_auth_intent.key = verification["key"] || verification["ckey"]
	src.owner.client_auth_intent.player_id = verification["player_id"]
	src.owner.client_auth_intent.admin = verification["is_admin"]
	src.owner.client_auth_intent.admin_rank = verification["admin_rank"]
	src.owner.client_auth_intent.mentor = verification["is_mentor"]
	src.owner.client_auth_intent.hos = verification["is_hos"]
	src.owner.client_auth_intent.whitelisted = verification["is_whitelisted"]
	src.owner.client_auth_intent.can_bypass_cap = verification["can_bypass_cap"]
	src.owner.client_auth_intent.can_skip_player_login = TRUE

	assign_goonhub_abilities(verification["ckey"], verification)

	. = ..()

/datum/client_auth_provider/goonhub/post_auth()
	src.owner.key = src.owner.client_auth_intent.key

	if (isnewplayer(src.owner.mob))
		src.owner.mob.key = src.owner.client_auth_intent.key
		src.owner.mob.name = src.owner.client_auth_intent.key
		if (!src.owner.mob.mind)
			src.owner.mob.mind = new(src.owner.mob)

		src.owner.mob.mind.key = src.owner.client_auth_intent.key
		src.owner.mob.mind.ckey = src.owner.client_auth_intent.ckey
		src.owner.mob.mind.displayed_key = src.owner.client_auth_intent.key

	src.hide_ui()

/datum/client_auth_provider/goonhub/post_auth_failed()
	src.hide_ui()

/datum/client_auth_provider/goonhub/on_logout()
	src.hide_ui()
	src.owner << output(list2params(list(
		"Logged Out",
		"You have been logged out. Goodbye!"
	)), "browseroutput:showAuthMessage")
	. = ..()

/datum/client_auth_provider/goonhub/proc/on_chat_loaded()
	UnregisterSignal(src.owner, COMSIG_CLIENT_CHAT_LOADED)

	if (src.pending_success_message)
		src.pending_success_message = FALSE
		src.owner << output(list2params(list(
			"Authentication successful",
			"You have been successfully authenticated, have fun!"
		)), "browseroutput:showAuthMessage")

/**
	* Setup logout
	*
	* Sets up the logout page
	*/
/datum/client_auth_provider/goonhub/proc/setup_logout()
	var/html = grabResource("html/auth/goonhub/logout.html")
	html = replacetext(html, "{$goonhub_url}", config.goonhub_url)
	html = replacetext(html, "{$ref}", "\ref[src]")
	src.owner << browse(html, list2params(list(
		"window" = "authlogout",
		"size" = "1x1",
		"can_close" = FALSE,
		"can_resize" = FALSE,
		"can_minimize" = FALSE,
		"titlebar" = FALSE,
	)))
	winshow(src.owner, "authlogout", FALSE)
	winset(src.owner, "menu.auth_logout", "command=\".output authlogout.browser:doLogout\"")

/**
	* Show external
	*
	* Shows the external auth page
	*
	* Arguments:
	* * route (string) - The route to show
	*/
/datum/client_auth_provider/goonhub/proc/show_external()
	var/url = "[config.goonhub_url]/game-auth/login?ref=\ref[src]&token=[src.token]"
	winset(src.owner, "authexternal", list2params(list(
		"parent" = "mainwindow",
		"type" = "browser",
		"pos" = "0,0",
		"size" = "0x0",
		"anchor1" = "0,0",
		"anchor2" = "100,100",
		"background-color" = "#0f0f0f",
	)))
	src.owner << browse(
		{"<html style="background-color: #0f0f0f;"><head><meta http-equiv="refresh" content="0; url=[url]" /></head></html>"},
		"window=mainwindow.authexternal"
	)

/datum/client_auth_provider/goonhub/proc/hide_ui()
	if (winexists(src.owner, "mainwindow.authexternal"))
		winset(src.owner, "mainwindow.authexternal", "parent=none")

/**
	* Open goonhub auth
	*
	* A way to open the login window, just in case
  */
/client/proc/open_goonhub_auth()
	set name = "Goonhub Auth"
	set category = "Commands"
	set desc = "Open the Goonhub auth window"
	if (src.authenticated) return
	if (istype(src.client_auth_provider, /datum/client_auth_provider/goonhub))
		var/datum/client_auth_provider/goonhub/provider = src.client_auth_provider
		provider.show_external()
