
/datum/apiBody/players/notes/update
	var/game_admin_ckey		= "string"
	var/server_id			= "string"
	var/ckey				= "string"
	var/note				= "string"

/datum/apiBody/players/notes/update/New(
	game_admin_ckey,
	server_id,
	ckey,
	note
)
	. = ..()
	src.game_admin_ckey = game_admin_ckey
	src.server_id = server_id
	src.ckey = ckey
	src.note = note

/datum/apiBody/players/notes/update/VerifyIntegrity()
	if (
		isnull(src.game_admin_ckey) \
		|| isnull(src.server_id) \
		|| isnull(src.ckey) \
		|| isnull(src.note) \
	)
		return FALSE

/datum/apiBody/players/notes/update/toJson()
	return json_encode(list(
		"game_admin_ckey"	= src.game_admin_ckey,
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"note"				= src.note,
	))
