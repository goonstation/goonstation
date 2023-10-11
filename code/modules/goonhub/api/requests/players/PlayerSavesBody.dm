
/datum/apiBody/PlayerSavesData
	fields = list(
		"player_id", // integer
		"key", // string
		"value" //string
	)

/datum/apiBody/PlayerSavesData/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["key"]) \
		|| isnull(src.values["value"])
	)
		return FALSE
