
/// EventStationNameResource
/datum/apiModel/Tracked/EventStationNameResource
	var/round_id	= null // string
	var/player_id	= null // string
	var/name		= null // string

/datum/apiModel/Tracked/EventStationNameResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.player_id = response["player_id"]
	src.name = response["name"]

/datum/apiModel/Tracked/EventStationNameResource/VerifyIntegrity()
	if (
		isnull(id) \
		|| isnull(src.round_id) \
		|| isnull(src.player_id) \
		|| isnull(src.name) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/EventStationNameResource/ToList()
	. = ..()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["player_id"] = src.player_id
	.["name"] = src.name
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
