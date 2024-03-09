
/datum/apiBody/rounds/update
	fields = list(
		"game_type", // string
	)

/datum/apiBody/rounds/update/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_type"]) \
	)
		return FALSE
