
/datum/apiBody/players/playtime
	fields = list(
		"server_id", // string
		"players" /// [{id: string, seconds_played: integer}]
	)

/datum/apiBody/players/playtime/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["server_id"]) \
		|| isnull(src.values["players"]) \
	)
		return FALSE
