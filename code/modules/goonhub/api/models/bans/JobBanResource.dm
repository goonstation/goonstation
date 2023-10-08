
/// JobBanResource
/datum/apiModel/Tracked/JobBanResource
	var/server_id	= null // string
	var/map			= null // string
	var/game_type	= null // string
	var/rp_mode		= null // boolean
	var/crashed		= null // boolean
	var/ended_at	= null // date-time
	var/game_admin	= null // { id: integer, ckey: string, name: string } - not required

/datum/apiModel/Tracked/JobBanResource/SetupFromResponse(response)
	. = ..()
	src.server_id = response["server_id"]
	src.map = response["map"]
	src.game_type = response["game_type"]
	src.rp_mode = response["rp_mode"]
	src.crashed = response["crashed"]
	src.ended_at = response["ended_at"]
	src.game_admin = response["game_admin"]

/datum/apiModel/Tracked/JobBanResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.server_id) \
		|| isnull(src.map) \
		|| isnull(src.game_type) \
		|| isnull(src.rp_mode) \
		|| isnull(src.crashed) \
		|| isnull(src.ended_at) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
		|| isnull(src.game_admin) \
	)
		return FALSE

/datum/apiModel/Tracked/JobBanResource/ToString()
	. = list()
	.["id"] = src.id
	.["server_id"] = src.server_id
	.["map"] = src.map
	.["game_type"] = src.game_type
	.["rp_mode"] = src.rp_mode
	.["crashed"] = src.crashed
	.["ended_at"] = src.ended_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["game_admin"] = src.game_admin
	return json_encode(.)
