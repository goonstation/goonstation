
/// BanResource
/datum/apiModel/Tracked/BanResource
	var/round_id										= null // integer
	var/game_admin_id									= null // integer
	var/server_id										= null // string
	var/reason											= null // string
	var/expires_at										= null // date-time
	var/deleted_at										= null // string
	var/game_admin										= null // { id: integer, ckey: string, name: string } - not required
	var/datum/apiModel/Tracked/GameRound/game_round		= null // /datum/apiModel/GameRound - not required
	var/original_ban_detail								= null // { id: integer, ban_id: integer, ckey: string, comp_id: string, ip: string } - not required
	var/list/datum/apiModel/Tracked/BanDetail/details	= null // [/datum/apiModel/BanDetail] - not required

/datum/apiModel/Tracked/BanResource/setupFromResponse(response)
	src.id = response["id"]
	src.round_id = response["round_id"]
	src.game_admin_id = response["game_admin_id"]
	src.server_id = response["server_id"]
	src.reason = response["reason"]
	src.expires_at = response["expires_at"]
	src.created_at = response["created_at"]
	src.updated_at = response["updated_at"]
	src.deleted_at = response["deleted_at"]
	src.game_admin = response["game_admin"]
	src.game_round = response["game_round"]
	src.original_ban_detail = response["original_ban_detail"]
	src.details = response["details"]

/datum/apiModel/Tracked/BanResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.id) \
		|| isnull(src.game_admin_id) \
		|| isnull(src.reason) \
		|| isnull(src.created_at) \
		|| isnull(src.game_admin) \
		|| isnull(src.original_ban_detail)
	)
		return FALSE

/datum/apiModel/Tracked/BanResource/ToString()
	. = list()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["reason"] = src.reason
	.["expires_at"] = src.expires_at
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["deleted_at"] = src.deleted_at
	.["game_admin"] = src.game_admin
	.["game_round"] = src.game_round
	.["original_ban_detail"] = src.original_ban_detail
	.["details"] = src.details
	return json_encode(.)
