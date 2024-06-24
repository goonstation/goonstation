
/datum/apiBody/PlayerSavesDeleteSave
	fields = list(
		"player_id", // integer
		"ckey", // string
		"name", // string
	)

/datum/apiBody/PlayerSavesDeleteSave/VerifyIntegrity()
	. = ..()
	if (
		(isnull(src.values["player_id"]) && isnull(src.values["ckey"])) \
		|| isnull(src.values["name"]) \
	)
		return FALSE
