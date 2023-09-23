
/// MapSwitch
/datum/apiModel/Tracked/MapSwitch
	var/datum/apiModel/Tracked/MapSwitchInternal/map_switch	= null // Model
	var/status												= null // string

/datum/apiModel/Tracked/MapSwitch/New(
	map_switch,
	status
)
	. = ..()
	src.map_switch	= map_switch
	src.status		= status

/datum/apiModel/Tracked/MapSwitch/VerifyIntegrity()
	if (
		isnull(src.map_switch) \
		|| isnull(src.status) \
	)
		return FALSE

/datum/apiModel/Tracked/MapSwitch/ToString()
	. = list()
	.["map_switch"]	= src.map_switch
	.["status"]		= src.status
	return json_encode(.)


/// MapSwitchInternal
/datum/apiModel/Tracked/MapSwitchInternal
	var/game_admin_id	= null // integer
	var/round_id		= null // integer
	var/server_id		= null // string
	var/map				= null // string
	var/votes			= null // integer

/datum/apiModel/Tracked/MapSwitchInternal/New(
	id,
	game_admin_id,
	round_id,
	server_id,
	map,
	votes,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.game_admin_id = game_admin_id
	src.round_id = round_id
	src.server_id = server_id
	src.map = map
	src.votes = votes
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/MapSwitchInternal/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.game_admin_id) \
		|| isnull(src.round_id) \
		|| isnull(src.server_id) \
		|| isnull(src.map) \
		|| isnull(src.votes) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/MapSwitchInternal/ToString()
	. = list()
	.["id"] = src.id
	.["game_admin_id"] = src.game_admin_id
	.["round_id"] = src.round_id
	.["server_id"] = src.server_id
	.["map"] = src.map
	.["votes"] = src.votes
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
