
/datum/apiBody/mapswitch
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"server_id", // string
		"map", // string
		"votes" // integer
	)

/datum/apiBody/mapswitch/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["round_id"]) \
		|| isnull(src.values["map"]) \
	)
		return FALSE
