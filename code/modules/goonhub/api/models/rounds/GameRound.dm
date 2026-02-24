
/// GameRound
/datum/apiModel/Tracked/GameRound
	var/server_id	= null // string
	var/map				= null // string
	var/game_type	= null // string
	var/rp_mode		= null // boolean
	var/crashed		= null // boolean
	var/ended_at	= null // date-time

/datum/apiModel/Tracked/GameRound/SetupFromResponse(response)
	. = ..()
	src.server_id = response["server_id"]
	src.map = response["map"]
	src.game_type = response["game_type"]
	src.rp_mode = response["rp_mode"]
	src.crashed = response["crashed"]
	src.ended_at = response["ended_at"]

/datum/apiModel/Tracked/GameRound/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.server_id) \
		|| isnull(src.rp_mode) \
	)
		return FALSE

/datum/apiModel/Tracked/GameRound/ToList()
	. = ..()
	.["server_id"] = src.server_id
	.["map"] = src.map
	.["game_type"] = src.game_type
	.["rp_mode"] = src.rp_mode
	.["crashed"] = src.crashed
	.["ended_at"] = src.ended_at
