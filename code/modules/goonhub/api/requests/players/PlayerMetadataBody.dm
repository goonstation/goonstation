
/datum/apiBody/players/metadata
	fields = list(
		"player_id"
		"data"
	)


/datum/apiBody/players/metadata/VerifyIntegrity()
	if (
		isnull(src.values[src.player_id]) \
		|| isnull(src.values[src.data])
	)
		return FALSE
