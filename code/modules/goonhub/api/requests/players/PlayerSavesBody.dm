
/datum/apiBody/PlayerSavesData
	var/player_id	= 0
	var/key			= null
	var/value		= null

/datum/apiBody/PlayerSavesData/New(
	player_id,
	key,
	value
)
	. = ..()
	src.player_id = player_id
	src.key = key
	src.value = value

/datum/apiBody/PlayerSavesData/VerifyIntegrity()
	if (
		isnull(src.player_id) \
		|| isnull(src.key) \
		|| isnull(src.value)
	)
		return FALSE

/datum/apiBody/PlayerSavesData/toJson()
	return json_encode(list(
		"player_id"		= src.player_id,
		"key"			= src.key,
		"value"			= src.value
	))
