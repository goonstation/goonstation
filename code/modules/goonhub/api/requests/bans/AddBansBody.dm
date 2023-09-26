
/datum/apiBody/bans/add
	var/game_admin_ckey	= "string"
	var/round_id	= 0
	var/server_id	= "string"
	var/ckey		= "string"
	var/comp_id		= "string"
	var/ip			= "string"
	var/reason		= "string"
	var/duration	= 0

/datum/apiBody/bans/add/New(
	game_admin_ckey,
	round_id,
	server_id,
	ckey,
	comp_id,
	ip,
	reason,
	duration
)
	. = ..()
	src.game_admin_ckey = game_admin_ckey
	src.round_id = round_id
	src.server_id = server_id
	src.ckey = ckey
	src.comp_id = comp_id
	src.ip = ip
	src.reason = reason
	src.duration = duration

/datum/apiBody/bans/add/VerifyIntegrity()
	if (
		isnull(src.game_admin_ckey) \
		|| isnull(src.round_id) \
		|| isnull(src.server_id) \
		|| isnull(src.ckey) \
		|| isnull(src.comp_id) \
		|| isnull(src.ip) \
		|| isnull(src.reason) \
		|| isnull(src.duration) \
	)
		return FALSE

/datum/apiBody/bans/add/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"round_id"			= src.round_id,
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"comp_id"			= src.comp_id,
		"ip"				= src.ip,
		"reason"			= src.reason,
		"duration"			= src.duration
	))
