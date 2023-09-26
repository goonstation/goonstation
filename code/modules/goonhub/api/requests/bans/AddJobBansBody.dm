
/datum/apiBody/jobbans/add
	var/game_admin_ckey	= "string"
	var/round_id	= 0
	var/server_id	= "string"
	var/ckey		= "string"
	var/job			= "string"
	var/reason		= "string"
	var/duration	= 0

/datum/apiBody/jobbans/add/New(
	game_admin_ckey,
	round_id,
	server_id,
	ckey,
	job,
	reason,
	duration
)
	. = ..()
	src.game_admin_ckey = game_admin_ckey
	src.round_id = round_id
	src.server_id = server_id
	src.ckey = ckey
	src.job = job
	src.reason = reason
	src.duration = duration

/datum/apiBody/jobbans/add/VerifyIntegrity()
	if (
		isnull(src.game_admin_ckey) \
		|| isnull(src.round_id) \
		|| isnull(src.server_id) \
		|| isnull(src.ckey) \
		|| isnull(src.job) \
		|| isnull(src.reason) \
		|| isnull(src.duration) \
	)
		return FALSE

/datum/apiBody/jobbans/add/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"round_id"			= src.round_id,
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"job"				= src.job,
		"reason"			= src.reason,
		"duration"			= src.duration
	))
