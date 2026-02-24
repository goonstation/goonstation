
/// Ban
/datum/apiModel/Tracked/Ban
	var/round_id 				= null // integer
	var/game_admin_id 	= null // integer
	var/server_id				= null // string
	var/server_group_id	= null // integer
	var/reason					= null // string
	var/active					= null // boolean
	var/duration				= null // integer
	var/duration_human	= null // string|null
	var/requires_appeal	= null // boolean
	var/expires_at			= null // date-time|null
	var/deleted_at			= null // date-time|null
	var/datum/apiModel/Tracked/PlayerAdmin/game_admin	  		 = null // Model - not required
	var/datum/apiModel/Tracked/GameRound/game_round					 = null // Model - not required
	var/datum/apiModel/Tracked/BanDetail/original_ban_detail = null // Model - not required
	var/list/datum/apiModel/Tracked/BanDetail/details				 = null // [Model] - not required

/datum/apiModel/Tracked/Ban/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.game_admin_id = response["game_admin_id"]
	src.server_id = response["server_id"]
	src.server_group_id = response["server_group_id"]
	src.reason = response["reason"]
	src.active = response["active"]
	src.duration = response["duration"]
	src.duration_human = response["duration_human"]
	src.requires_appeal = response["requires_appeal"]
	src.expires_at = response["expires_at"]
	src.deleted_at = response["deleted_at"]

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

/datum/apiModel/Tracked/Ban/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.game_admin_id) \
		|| isnull(src.reason) \
		|| isnull(src.game_admin)
	)
		return FALSE

/datum/apiModel/Tracked/Ban/ToList()
	. = ..()
	.["round_id"] = src.round_id
	.["game_admin_id"] = src.game_admin_id
	.["server_id"] = src.server_id
	.["server_group_id"] = src.server_group_id
	.["reason"] = src.reason
	.["active"] = src.active
	.["duration"] = src.duration
	.["duration_human"] = src.duration_human
	.["requires_appeal"] = src.requires_appeal
	.["expires_at"] = src.expires_at
	.["deleted_at"] = src.deleted_at
	.["game_admin"] = src.game_admin ? src.game_admin.ToList() : src.game_admin
	.["game_round"] = src.game_round ? src.game_round.ToList() : src.game_round
	.["original_ban_detail"] = src.original_ban_detail ? src.original_ban_detail.ToList() : src.original_ban_detail
	.["details"] = list()
	for (var/datum/apiModel/Tracked/BanDetail/detail in src.details)
		.["details"] += list(detail.ToList())
