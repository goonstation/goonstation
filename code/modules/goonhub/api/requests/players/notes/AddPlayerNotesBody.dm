
/datum/apiBody/players/notes/post
	var/game_admin_ckey	= "string"
	var/round_id			= 0
	var/server_id			= "string"
	var/ckey				= "string"
	var/note				= "string"

/datum/apiBody/players/notes/post/New(
	game_admin_ckey,
	round_id,
	server_id,
	ckey,
	note
)
	. = ..()
	src.game_admin_ckey = game_admin_ckey
	src.round_id = round_id
	src.server_id = server_id
	src.ckey = ckey
	src.note = note

/datum/apiBody/players/notes/post/VerifyIntegrity()
	if (
		isnull(src.game_admin_ckey) \
		|| isnull(src.round_id) \
		|| isnull(src.server_id) \
		|| isnull(src.ckey) \
		|| isnull(src.note) \
	)
		return FALSE

/datum/apiBody/players/notes/post/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"round_id"			= src.round_id,
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"note"				= src.note,
	))
