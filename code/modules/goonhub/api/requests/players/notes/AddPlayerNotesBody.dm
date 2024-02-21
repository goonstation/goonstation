
/datum/apiBody/players/notes/post
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"server_id", // string
		"ckey", // string
		"note" // string
	)

/datum/apiBody/players/notes/post/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["server_id"]) \
		|| isnull(src.values["ckey"]) \
		|| isnull(src.values["note"]) \
	)
		return FALSE
