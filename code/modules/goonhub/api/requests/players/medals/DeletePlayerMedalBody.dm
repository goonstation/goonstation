
/datum/apiBody/players/medals/delete
	fields = list(
		"player_id", // integer
		"ckey", // string
		"medal", // string
	)

/datum/apiBody/players/medals/delete/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["medal"]) \
	)
		return FALSE
