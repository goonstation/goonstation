
/datum/apiBody/players/playtime
	var/server_id										= "string"
	var/datum/apiBody/players/playtime/internal/players	= null		// defined below

/datum/apiBody/players/playtime/New(
	server_id,
	players
)
	. = ..()
	src.server_id = server_id
	src.players = players

/datum/apiBody/players/playtime/VerifyIntegrity()
	if (
		isnull(src.server_id) \
		|| isnull(src.players) \
	)
		return FALSE

/datum/apiBody/players/playtime/toJson()
	return json_encode(list(
		"server_id"				= src.server_id,
		"players"			= src.players
	))


// The internal body: the players list
/datum/apiBody/players/playtime/internal
	var/id				= 0
	var/seconds_played	= 0

/datum/apiBody/players/playtime/internal/New(
	id,
	seconds_played
)
	. = ..()
	src.id = id
	src.seconds_played = seconds_played

/datum/apiBody/players/playtime/internal/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.seconds_played) \
	)
		return FALSE

/datum/apiBody/players/playtime/internal/toJson()
	return json_encode(list(
		"id"				= src.id,
		"seconds_played"	= src.seconds_played
	))
