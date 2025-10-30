
/datum/apiBody/bans/add_detail
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"ckey", // string
		"comp_id", // string
		"ip", // string
		"player_id", // integer
		"evasion" // boolean
	)

/datum/apiBody/bans/add_detail/VerifyIntegrity()
	. = ..()
