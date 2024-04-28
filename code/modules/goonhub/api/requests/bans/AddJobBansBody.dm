
/datum/apiBody/jobbans/add
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"server_id", // string
		"ckey", // string
		"job", // string
		"reason", // string
		"duration" // integer
	)

/datum/apiBody/jobbans/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["ckey"]) \
		|| isnull(src.values["job"]) \
	)
		return FALSE
