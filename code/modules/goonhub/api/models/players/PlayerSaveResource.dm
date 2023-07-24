
/// PlayerSaveResource
/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource
	var/name		= null // string
	var/data		= null // integer

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/New(
	id,
	player_id,
	name,
	data,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.name = name
	src.data = data
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.name) \
		|| isnull(src.data) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["name"] = src.name
	.["data"] = src.data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
