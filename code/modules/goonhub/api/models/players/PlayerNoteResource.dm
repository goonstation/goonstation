
/// PlayerNoteResource
/datum/apiModel/PlayerRes/PlayerNoteResource
	var/ckey			= null // string
	var/game_admin_id	= null // integer
	var/server_id		= null // string
	var/round_id		= null // integer
	var/note			= null // string

/datum/apiModel/PlayerRes/PlayerNoteResource/New(
	id,
	player_id,
	ckey,
	game_admin_id,
	server_id,
	round_id,
	note,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.ckey = ckey
	src.game_admin_id = game_admin_id
	src.server_id = server_id
	src.round_id = round_id
	src.note = note
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PlayerRes/PlayerNoteResource/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(src.player_id)
		|| isnull(src.ckey)
		|| isnull(src.game_admin_id)
		|| isnull(src.server_id)
		|| isnull(src.round_id)
		|| isnull(src.note)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
	)
		return FALSE

/datum/apiModel/PlayerRes/PlayerNoteResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["ckey"] = src.ckey
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["round_id"] = src.round_id
	.["note"] = src.note
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
