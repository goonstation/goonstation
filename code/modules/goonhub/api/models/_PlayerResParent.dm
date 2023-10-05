
ABSTRACT_TYPE(/datum/apiModel/Tracked/PlayerRes)
/// PlayerRes - ABSTRACT
/// All PlayerResourceXYZ inherit from this - shared player id field
/datum/apiModel/Tracked/PlayerRes
	var/player_id	= null // integer

/datum/apiModel/Tracked/PlayerRes/New(
	id,
	player_id,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/PlayerRes/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE
	return TRUE

/datum/apiModel/Tracked/PlayerRes/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
