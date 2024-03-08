
/// BanResource
/datum/apiModel/Tracked/BanResource
	var/round_id										= null // integer
	var/game_admin_id									= null // integer
	var/server_id										= null // string
	var/reason											= null // string
	var/duration_human									= null // string
	var/expires_at										= null // date-time | null
	var/deleted_at										= null // date-time | null
	var/game_admin										= null // { id: integer, ckey: string, name: string } - not required
	var/datum/apiModel/Tracked/GameRound/game_round		= null // /datum/apiModel/GameRound - not required
	var/original_ban_detail								= null // { id: integer, ban_id: integer, ckey: string, comp_id: string, ip: string }
	var/list/datum/apiModel/Tracked/BanDetail/details	= null // [/datum/apiModel/BanDetail] - not required
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
	src.game_admin = response["game_admin"]

	if (response["game_round"])
		src.game_round = new
		src.game_round.SetupFromResponse(response["game_round"])

	src.original_ban_detail = response["original_ban_detail"]
	src.requires_appeal = response["requires_appeal"]

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
		|| isnull(src.game_admin) \
		|| isnull(src.original_ban_detail)
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
	.["game_round"] = src.game_round
	if (src.game_round)
		.["game_round"] = src.game_round.ToList()
	.["original_ban_detail"] = src.original_ban_detail
	.["details"] = list()
	for (var/datum/apiModel/Tracked/BanDetail/detail in src.details)
		.["details"] += list(detail.ToList())
	.["requires_appeal"] = src.requires_appeal
