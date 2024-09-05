
/datum/apiBody/jobbans/delete
	fields = list(
		"game_admin_ckey", // string
		"server_id", // string
		"ckey", // string
		"job" // string
	)

/datum/apiBody/jobbans/delete/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["ckey"]) \
		|| isnull(src.values["job"]) \
	)
		return FALSE
