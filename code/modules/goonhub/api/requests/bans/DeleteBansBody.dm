
/datum/apiBody/bans/delete
	fields = list(
		"game_admin_ckey", // string
	)

/datum/apiBody/bans/delete/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"])
	)
		return FALSE
