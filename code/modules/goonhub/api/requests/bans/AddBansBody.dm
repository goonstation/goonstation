
/datum/apiBody/bans/add
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"server_id", // string
		"ckey", // string
		"comp_id", // string
		"ip", // string
		"reason", // string
		"duration", // integer
		"requires_appeal" // boolean
	)

/datum/apiBody/bans/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["reason"]) \
	)
		return FALSE
