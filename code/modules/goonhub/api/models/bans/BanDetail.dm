
/// BanDetail
/datum/apiModel/Tracked/BanDetail
	var/ban_id		= null // integer
	var/ckey		= null // string
	var/comp_id		= null // integer
	var/ip			= null // integer
	var/deleted_at	= null // date-time

/datum/apiModel/Tracked/BanDetail/SetupFromResponse(response)
	. = ..()
	src.id = response["id"]
	src.ban_id = response["ban_id"]
	src.ckey = response["ckey"]
	src.comp_id = response["comp_id"]
	src.ip = response["ip"]
	src.created_at = response["created_at"]
	src.updated_at = response["updated_at"]
	src.deleted_at = response["deleted_at"]

/datum/apiModel/Tracked/BanDetail/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ban_id) \
	)
		return FALSE

/datum/apiModel/Tracked/BanDetail/ToString()
	. = list()
	.["id"] = src.id
	.["ban_id"] = src.ban_id
	.["ckey"] = src.ckey
	.["comp_id"] = src.comp_id
	.["ip"] = src.ip
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["deleted_at"] = src.deleted_at
	return json_encode(.)
