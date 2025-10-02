
/// JobBanResource
/datum/apiModel/Tracked/JobBanResource
	var/round_id 				= null // integer
	var/game_admin_id 	= null // integer
	var/server_id				= null // string
	var/ckey						= null // string
	var/banned_from_job = null // string
	var/reason					= null // string
	var/expires_at 			= null // date-time
	var/deleted_at 			= null // date-time
	var/datum/apiModel/Tracked/PlayerAdmin/game_admin	= null // Model - not required

/datum/apiModel/Tracked/JobBanResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.game_admin_id = response["game_admin_id"]
	src.server_id = response["server_id"]
	src.ckey = response["ckey"]
	src.banned_from_job = response["banned_from_job"]
	src.reason = response["reason"]
	src.expires_at = response["expires_at"]
	src.deleted_at = response["deleted_at"]

	if (("game_admin" in response) && islist(response["game_admin"]))
		src.game_admin = new
		src.game_admin.SetupFromResponse(response["game_admin"])

/datum/apiModel/Tracked/JobBanResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey) \
		|| isnull(src.banned_from_job)
	)
		return FALSE

/datum/apiModel/Tracked/JobBanResource/ToList()
	. = ..()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["ckey"] = src.ckey
	.["banned_from_job"] = src.banned_from_job
	.["reason"] = src.reason
	.["expires_at"] = src.expires_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["deleted_at"] = src.deleted_at
	.["game_admin"] = src.game_admin ? src.game_admin.ToList() : src.game_admin
