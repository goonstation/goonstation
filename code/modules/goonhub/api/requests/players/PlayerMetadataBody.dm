
/datum/apiBody/players/metadata
	var/player_id		= "string"
	var/data			= null		// defined below

/datum/apiBody/players/metadata/New(
	player_id,
	data
)
	. = ..()
	src.player_id	= player_id
	src.data		= data

/datum/apiBody/players/metadata/VerifyIntegrity()
	if (
		isnull(src.player_id) \
		|| isnull(src.data)
	)
		return FALSE

/datum/apiBody/players/metadata/toJson()
	return json_encode(list(
		"player_id"				= src.player_id,
		"data"					= src.data
	))
