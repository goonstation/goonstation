
/datum/apiBody/PlayerSavesAddSave
	fields = list(
		"player_id", // integer
		"ckey", // string
		"name", // string
		"data" //string
	)

/datum/apiBody/PlayerSavesAddSave/VerifyIntegrity()
	. = ..()
	if (
		(isnull(src.values["player_id"]) && isnull(src.values["ckey"])) \
		|| isnull(src.values["name"])
	)
		return FALSE
