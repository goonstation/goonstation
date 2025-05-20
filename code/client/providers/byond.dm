/datum/client_auth_provider/byond
	start_state = CLIENT_AUTH_SUCCESS

/datum/client_auth_provider/byond/New(client/owner)
	. = ..()
	if (admins.Find(src.owner.ckey))
		src.owner.client_auth_intent.admin = TRUE

	if (mentors.Find(src.owner.ckey))
		src.owner.client_auth_intent.mentor = TRUE
