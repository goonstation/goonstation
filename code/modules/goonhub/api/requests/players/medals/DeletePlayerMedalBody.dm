
/datum/apiBody/players/medals/delete
	fields = list(
		"player_id", // integer
		"medal", // string
	)

/datum/apiBody/players/medals/delete/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["medal"]) \
	)
		return FALSE
