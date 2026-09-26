
/datum/apiBody/players/metadata/addbulk
	fields = list(
		"player_id", // integer
		"metadata" // [string]
	)

/datum/apiBody/players/metadata/addbulk/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| !length(src.values["metadata"])
	)
		return FALSE
