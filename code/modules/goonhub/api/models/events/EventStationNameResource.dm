
/// EventStationNameResource
/datum/apiModel/EventStationNameResource
	var/round_id	= null // string
	var/player_id	= null // string
	var/name		= null // string
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/EventStationNameResource/New(
	id,
	round_id,
	player_id,
	name,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.round_id = round_id
	src.player_id = player_id
	src.name = name
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/EventStationNameResource/VerifyIntegrity()
	if (
		isnull(id) \
		|| isnull(src.round_id) \
		|| isnull(src.player_id) \
		|| isnull(src.name) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/EventStationNameResource/ToString()
	. = list()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["player_id"] = src.player_id
	.["name"] = src.name
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
