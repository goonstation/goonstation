/datum/apiBody/rounds/update/put
	var/game_type = "string"

/datum/apiBody/rounds/update/put/New(
	game_type
)
	. = ..()
	src.game_type = game_type

/datum/apiBody/rounds/update/put/VerifyIntegrity()
	if (
		isnull(src.game_type)
	)
		return FALSE

/datum/apiBody/rounds/update/put/toJson()
	return json_encode(list(
		"game_type"	= src.game_type,
	))
