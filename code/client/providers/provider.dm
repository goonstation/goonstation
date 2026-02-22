/datum/client_auth_provider
	var/name = ""
	var/client/owner = null
	var/valid = FALSE
	var/authenticated = FALSE
	var/start_state = CLIENT_AUTH_SUCCESS
	var/can_logout = FALSE

/datum/client_auth_provider/New(client/owner)
	. = ..()
	if (!isclient(owner)) return
	src.owner = owner
	src.valid = TRUE

/datum/client_auth_provider/proc/on_auth()
	SHOULD_CALL_PARENT(TRUE)
	src.authenticated = TRUE
	if (src.can_logout && src.owner) winset(src.owner, "menu.auth_logout", "is-disabled=false")
	logTheThing(LOG_DEBUG, src.owner, "authenticated via [src.name]")
	src.owner?.on_auth()

/datum/client_auth_provider/proc/on_auth_failed()
	SHOULD_CALL_PARENT(TRUE)
	src.authenticated = FALSE
	if (src.can_logout && src.owner) winset(src.owner, "menu.auth_logout", "is-disabled=true")
	logTheThing(LOG_DEBUG, src.owner, "failed to authenticate via [src.name]")
	src.owner?.on_auth_failed()

/datum/client_auth_provider/proc/logout()

/datum/client_auth_provider/proc/on_logout()
	SHOULD_CALL_PARENT(TRUE)
	src.authenticated = FALSE
	if (src.owner) winset(src.owner, "menu.auth_logout", "is-disabled=true")
	logTheThing(LOG_DEBUG, src.owner, "logged out via [src.name]")
	src.owner?.on_logout()

/datum/client_auth_provider/proc/post_auth()

/datum/client_auth_provider/proc/post_auth_failed()
