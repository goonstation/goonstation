
/// BanDetail
/datum/apiModel/Tracked/BanDetail
	var/ban_id		= null // integer
	var/ckey		= null // string
	var/comp_id		= null // integer
	var/ip			= null // integer
	var/player_id	= null // integer
	var/deleted_at	= null // date-time | null
	var/datum/apiModel/Tracked/BanDetail/original_ban_detail = null // Model - not required

/datum/apiModel/Tracked/BanDetail/SetupFromResponse(response)
	. = ..()
	src.ban_id = response["ban_id"]
	src.ckey = response["ckey"]
	src.comp_id = response["comp_id"]
	src.ip = response["ip"]
	src.player_id = response["player_id"]
	src.deleted_at = response["deleted_at"]

	if (("original_ban_detail" in response) && islist(response["original_ban_detail"]))
		src.original_ban_detail = new
		src.original_ban_detail.SetupFromResponse(response["original_ban_detail"])

/datum/apiModel/Tracked/BanDetail/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ban_id) \
	)
		return FALSE

/datum/apiModel/Tracked/BanDetail/ToList()
	. = ..()
	.["ban_id"] = src.ban_id
	.["ckey"] = src.ckey
	.["comp_id"] = src.comp_id
	.["ip"] = src.ip
	.["player_id"] = src.player_id
	.["deleted_at"] = src.deleted_at
	.["original_ban_detail"] = src.original_ban_detail
	if (src.original_ban_detail)
		.["original_ban_detail"] = src.original_ban_detail.ToList()
