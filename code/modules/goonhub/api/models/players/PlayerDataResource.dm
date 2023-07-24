
/// PlayerDataResource
/datum/apiModel/Tracked/PlayerRes/PlayerDataResource
	var/key			= null // string
	var/value		= null // integer

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/New(
	id,
	player_id,
	key,
	value,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.key = key
	src.value = value
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.key) \
		|| isnull(src.value) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["key"] = src.key
	.["value"] = src.value
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
