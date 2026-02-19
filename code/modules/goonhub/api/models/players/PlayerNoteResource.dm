
/// PlayerNoteResource
/datum/apiModel/Tracked/PlayerNoteResource
	var/player_id = null // integer
	var/datum/apiModel/Tracked/Player/player = null // Model
	var/ckey			= null // string
	var/game_admin_id	= null // integer
	var/datum/apiModel/Tracked/PlayerAdmin/game_admin	= null // Model
	var/server_id		= null // string
	var/round_id		= null // integer
	var/note			= null // string
	var/legacy_data		= null // [string]

/datum/apiModel/Tracked/PlayerNoteResource/SetupFromResponse(response)
	. = ..()
	src.player_id = response["player_id"]
	if (("player" in response) && islist(response["player"]))
		src.player = new
		src.player.SetupFromResponse(response["player"])
	src.ckey = response["ckey"]
	src.game_admin_id = response["game_admin_id"]
	if (("game_admin" in response) && islist(response["game_admin"]))
		src.game_admin = new
		src.game_admin.SetupFromResponse(response["game_admin"])
	src.server_id = response["server_id"]
	src.round_id = response["round_id"]
	src.note = response["note"]
	src.legacy_data = response["legacy_data"]

/datum/apiModel/Tracked/PlayerNoteResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.note) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerNoteResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	if (src.player)
		.["player"] = src.player.ToList()
	.["ckey"] = src.ckey
	.["game_admin_id"] = src.game_admin_id
	if (src.game_admin)
		.["game_admin"] = src.game_admin.ToList()
	.["server_id"] = src.server_id
	.["round_id"] = src.round_id
	.["note"] = src.note
	.["legacy_data"] = src.legacy_data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
