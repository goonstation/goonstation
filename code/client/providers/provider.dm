/datum/client_auth_provider
	var/client/owner = null
	var/authenticated = FALSE
	var/start_state = CLIENT_AUTH_SUCCESS

/datum/client_auth_provider/New(client/owner)
	. = ..()
	src.owner = owner

/datum/client_auth_provider/proc/on_auth()
	SHOULD_CALL_PARENT(TRUE)
	src.authenticated = TRUE
	src.owner.on_auth()
