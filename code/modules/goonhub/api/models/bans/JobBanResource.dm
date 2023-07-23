
/// JobBanResource
/datum/apiModel/JobBanResource
	var/server_id	= null // string
	var/map			= null // string
	var/game_type	= null // string
	var/rp_mode		= null // boolean
	var/crashed		= null // boolean
	var/ended_at	= null // date-time
	var/created_at	= null // date-time
	var/updated_at	= null // date-time
	var/game_admin	= null // { id: integer, ckey: string, name: string } - not required

/datum/apiModel/JobBanResource/New(
	id,
	server_id,
	map,
	game_type,
	rp_mode,
	crashed,
	ended_at,
	created_at,
	updated_at,
	game_admin
)
	. = ..()
	src.id = id
	src.server_id = server_id
	src.map = map
	src.game_type = game_type
	src.rp_mode = rp_mode
	src.crashed = crashed
	src.ended_at = ended_at
	src.created_at = created_at
	src.updated_at = updated_at
	src.game_admin = game_admin

/datum/apiModel/JobBanResource/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(server_id)
		|| isnull(map)
		|| isnull(game_type)
		|| isnull(rp_mode)
		|| isnull(crashed)
		|| isnull(ended_at)
		|| isnull(created_at)
		|| isnull(updated_at)
		|| isnull(game_admin)
	)
		return FALSE

/datum/apiModel/JobBanResource/ToString()
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
