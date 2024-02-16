
/datum/apiBody/PlayerSavesAddData
	fields = list(
		"player_id", // integer
		"key", // string
		"value" //string
	)

/datum/apiBody/PlayerSavesAddData/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["key"])
	)
		return FALSE
