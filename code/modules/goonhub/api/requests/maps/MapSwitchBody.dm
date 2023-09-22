
/datum/apiBody/mapswitch
	var/game_admin_ckey		= "string"
	var/round_id			= 0
	var/server_id			= "string"
	var/map					= "string"
	var/votes				= 0

/datum/apiBody/mapswitch/New(
	game_admin_ckey,
	round_id,
	server_id,
	map,
	votes
)
	. = ..()
	src.game_admin_ckey = game_admin_ckey
	src.round_id = round_id
	src.server_id = server_id
	src.map = map
	src.votes = votes

/datum/apiBody/mapswitch/VerifyIntegrity()
	if (
		isnull(src.game_admin_ckey) \
		|| isnull(src.round_id) \
		|| isnull(src.server_id) \
		|| isnull(src.map) \
		|| isnull(src.votes) \
	)
		return FALSE

/datum/apiBody/mapswitch/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"round_id"			= src.round_id,
		"server_id"			= src.server_id,
		"map"				= src.map,
		"votes"				= src.votes,
	))
