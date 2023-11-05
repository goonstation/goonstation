
/datum/apiBody/players/medals/add
	fields = list(
		"player_id", // integer
		"medal", // string
		"round_id", // integer
	)

/datum/apiBody/players/medals/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["medal"]) \
		|| isnull(src.values["round_id"]) \
	)
		return FALSE
