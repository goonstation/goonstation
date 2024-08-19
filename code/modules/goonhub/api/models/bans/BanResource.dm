
/// BanResource
/datum/apiModel/Tracked/BanResource
	var/round_id										= null // integer
	var/game_admin_id									= null // integer
	var/server_id										= null // string
	var/reason											= null // string
	var/duration_human									= null // string
	var/expires_at										= null // date-time | null
	var/deleted_at										= null // date-time | null
	var/datum/apiModel/GameAdminResource/game_admin	  = null // Model - not required
	var/datum/apiModel/Tracked/GameRound/game_round		= null // Model - not required
	var/datum/apiModel/Tracked/BanDetail/original_ban_detail = null // Model - not required
	var/list/datum/apiModel/Tracked/BanDetail/details	= null // [Model] - not required
	var/requires_appeal								= null // boolean

/datum/apiModel/Tracked/BanResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.game_admin_id = response["game_admin_id"]
	src.server_id = response["server_id"]
	src.reason = response["reason"]
	src.duration_human = response["duration_human"]
	src.expires_at = response["expires_at"]
	src.deleted_at = response["deleted_at"]
	src.requires_appeal = response["requires_appeal"]

	if (("game_admin" in response) && islist(response["game_admin"]))
		src.game_admin = new
		src.game_admin.SetupFromResponse(response["game_admin"])

	if (("game_round" in response) && islist(response["game_round"]))
		src.game_round = new
		src.game_round.SetupFromResponse(response["game_round"])

	if (("original_ban_detail" in response) && islist(response["original_ban_detail"]))
		src.original_ban_detail = new
		src.original_ban_detail.SetupFromResponse(response["original_ban_detail"])

	src.details = list()
	for (var/item in response["details"])
		var/datum/apiModel/Tracked/BanDetail/detail = new
		detail.SetupFromResponse(item)
		src.details.Add(detail)

/datum/apiModel/Tracked/BanResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.game_admin_id) \
		|| isnull(src.reason) \
		|| isnull(src.game_admin)
	)
		return FALSE

/datum/apiModel/Tracked/BanResource/ToList()
	. = ..()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["reason"] = src.reason
	.["duration_human"] = src.duration_human
	.["expires_at"] = src.expires_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["deleted_at"] = src.deleted_at
	.["game_admin"] = src.game_admin
	if (src.game_admin)
		.["game_admin"] = src.game_admin.ToList()
	.["game_round"] = src.game_round
	if (src.game_round)
		.["game_round"] = src.game_round.ToList()
	.["original_ban_detail"] = src.original_ban_detail
	if (src.original_ban_detail)
		.["original_ban_detail"] = src.original_ban_detail.ToList()
	.["details"] = list()
	for (var/datum/apiModel/Tracked/BanDetail/detail in src.details)
		.["details"] += list(detail.ToList())
	.["requires_appeal"] = src.requires_appeal
