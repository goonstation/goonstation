
/// PlayerNoteResource
/datum/apiModel/Tracked/PlayerRes/PlayerNoteResource
	var/ckey			= null // string
	var/game_admin_id	= null // integer
	var/server_id		= null // string
	var/round_id		= null // integer
	var/note			= null // string
	var/legacy_data		= null // [string]

/datum/apiModel/Tracked/PlayerRes/PlayerNoteResource/SetupFromResponse(response)
	. = ..()
	src.ckey = response["ckey"]
	src.game_admin_id = response["game_admin_id"]
	src.server_id = response["server_id"]
	src.round_id = response["round_id"]
	src.note = response["note"]
	src.legacy_data = response["legacy_data"]

/datum/apiModel/Tracked/PlayerRes/PlayerNoteResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.ckey) \
		|| isnull(src.game_admin_id) \
		|| isnull(src.server_id) \
		|| isnull(src.round_id) \
		|| isnull(src.note) \
		|| isnull(src.legacy_data) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerNoteResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["ckey"] = src.ckey
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["round_id"] = src.round_id
	.["note"] = src.note
	.["legacy_data"] = src.legacy_data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
