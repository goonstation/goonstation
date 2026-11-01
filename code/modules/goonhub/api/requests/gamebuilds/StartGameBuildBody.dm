
/datum/apiBody/gamebuilds/build
	fields = list(
		"game_admin_ckey", // string
		"server_id", // string
		"round_id", // int
		"map", // string
		"votes" // int
	)

/datum/apiBody/gamebuilds/build/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["server_id"]) \
	)
		return FALSE
