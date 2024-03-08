
/datum/apiBody/PlayerSavesDeleteData
	fields = list(
		"player_id", // integer
		"ckey", // string
		"key", // string
	)

/datum/apiBody/PlayerSavesDeleteData/VerifyIntegrity()
	. = ..()
	if (
		(isnull(src.values["player_id"]) && isnull(src.values["ckey"])) \
		|| isnull(src.values["key"]) \
	)
		return FALSE
