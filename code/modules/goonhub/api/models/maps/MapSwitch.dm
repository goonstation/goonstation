
/// MapSwitch
/datum/apiModel/MapSwitch
	var/datum/apiModel/Tracked/MapSwitchInternal/map_switch	= null // Model
	var/status												= null // integer

/datum/apiModel/MapSwitch/SetupFromResponse(response)
	. = ..()
	src.map_switch = new
	src.map_switch.SetupFromResponse(response["map_switch"])
	src.status = response["status"]

/datum/apiModel/MapSwitch/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.map_switch) \
		|| isnull(src.status) \
	)
		return FALSE

/datum/apiModel/MapSwitch/ToList()
	. = ..()
	.["map_switch"]	= src.map_switch.ToList()
	.["status"]		= src.status


/// MapSwitchInternal
/datum/apiModel/Tracked/MapSwitchInternal
	var/game_admin_id	= null // integer
	var/round_id		= null // integer
	var/server_id		= null // string
	var/map				= null // string
	var/votes			= null // integer

/datum/apiModel/Tracked/MapSwitchInternal/SetupFromResponse(response)
	. = ..()
	src.game_admin_id = response["game_admin_id"]
	src.round_id = response["round_id"]
	src.server_id = response["server_id"]
	src.map = response["map"]
	src.votes = response["votes"]

/datum/apiModel/Tracked/MapSwitchInternal/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.round_id) \
		|| isnull(src.map) \
	)
		return FALSE

/datum/apiModel/Tracked/MapSwitchInternal/ToList()
	. = ..()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["round_id"] = src.round_id
	.["server_id"] = src.server_id
	.["map"] = src.map
	.["votes"] = src.votes
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
