
/// VpnWhitelistResource
/datum/apiModel/Tracked/VpnWhitelistResource
	var/game_admin_id	= null // integer
	var/ckey			= null // string
	var/datum/apiModel/Tracked/PlayerAdmin/game_admin	= null // Model

/datum/apiModel/Tracked/VpnWhitelistResource/SetupFromResponse(response)
	. = ..()
	src.game_admin_id = response["game_admin_id"]
	src.ckey = response["ckey"]
	if (("game_admin" in response) && islist(response["game_admin"]))
		src.game_admin = new
		src.game_admin.SetupFromResponse(response["game_admin"])

/datum/apiModel/Tracked/VpnWhitelistResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.game_admin_id) \
		|| isnull(src.ckey) \
	)
		return FALSE

/datum/apiModel/Tracked/VpnWhitelistResource/ToList()
	. = ..()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["ckey"] = src.ckey
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["game_admin"] = src.game_admin ? src.game_admin.ToList() : src.game_admin
