
/datum/apiBody/PlayerSavesAddSave
	fields = list(
		"player_id", // integer
		"name", // string
		"data" //string
	)

/datum/apiBody/PlayerSavesAddSave/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["name"])
	)
		return FALSE
