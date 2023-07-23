
ABSTRACT_TYPE(/datum/apiModel/PlayerRes)
/// PlayerRes - ABSTRACT
/// All PlayerResourceXYZ inherit from this due to shared fields
/datum/apiModel/PlayerRes
	var/player_id	= null // integer
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/PlayerSaveResource/New(
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

/datum/apiModel/PlayerSaveResource/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(src.player_id)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
	)
		return FALSE

/datum/apiModel/PlayerSaveResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
