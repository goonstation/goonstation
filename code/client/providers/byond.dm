/datum/client_auth_provider/byond
	name = "Byond"
	start_state = CLIENT_AUTH_SUCCESS

/datum/client_auth_provider/byond/New(client/owner)
	. = ..()

	src.owner.client_auth_intent.ckey = src.owner.ckey
	src.owner.client_auth_intent.key = src.owner.key

	if (admins.Find(src.owner.ckey))
		src.owner.client_auth_intent.admin = TRUE
		src.owner.client_auth_intent.admin_rank = admins[src.owner.ckey]

	if (mentors.Find(src.owner.ckey))
		src.owner.client_auth_intent.mentor = TRUE

	if (NT.Find(src.owner.ckey))
		src.owner.client_auth_intent.hos = TRUE

	if (whitelistCkeys.Find(src.owner.ckey))
		src.owner.client_auth_intent.whitelisted = TRUE

	if (bypassCapCkeys.Find(src.owner.ckey))
		src.owner.client_auth_intent.can_bypass_cap = TRUE
