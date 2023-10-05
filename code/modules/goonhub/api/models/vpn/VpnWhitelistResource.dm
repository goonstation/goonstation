
/// VpnWhitelistResource
/datum/apiModel/VpnWhitelistResource
	var/id 						= null // integer
	var/game_admin_id	= null // integer
	var/ckey			= null // string
	var/created_at		= null // date-time
	var/updated_at		= null // date-time
	var/game_admin		= null // { id: integer, ckey: string, name: string } - not required

/datum/apiModel/VpnWhitelistResource/New(
	id,
	game_admin_id,
	ckey,
	created_at,
	updated_at,
	game_admin
)
	. = ..()
	src.id = id
	src.game_admin_id = game_admin_id
	src.ckey = ckey
	src.created_at = created_at
	src.updated_at = updated_at
	src.game_admin = game_admin

/datum/apiModel/VpnWhitelistResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(game_admin_id) \
		|| isnull(ckey) \
		|| isnull(created_at) \
		|| isnull(updated_at) \
		|| isnull(game_admin) \
	)
		return FALSE

/datum/apiModel/VpnWhitelistResource/ToString()
	. = list()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["ckey"] = src.ckey
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["game_admin"] = src.game_admin
	return json_encode(.)
