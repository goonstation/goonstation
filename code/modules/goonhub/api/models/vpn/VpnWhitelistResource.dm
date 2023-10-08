
/// VpnWhitelistResource
/datum/apiModel/Tracked/VpnWhitelistResource
	var/game_admin_id	= null // integer
	var/ckey			= null // string
	var/game_admin		= null // { id: integer, ckey: string, name: string } - not required

/datum/apiModel/Tracked/VpnWhitelistResource/SetupFromResponse(response)
	. = ..()
	src.game_admin_id = response["game_admin_id"]
	src.ckey = response["ckey"]
	src.game_admin = response["game_admin"]

/datum/apiModel/Tracked/VpnWhitelistResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(game_admin_id) \
		|| isnull(ckey) \
		|| isnull(created_at) \
		|| isnull(updated_at) \
		|| isnull(game_admin) \
	)
		return FALSE

/datum/apiModel/Tracked/VpnWhitelistResource/ToString()
	. = list()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["ckey"] = src.ckey
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["game_admin"] = src.game_admin
	return json_encode(.)
