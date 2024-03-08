
ABSTRACT_TYPE(/datum/apiModel/Tracked/PlayerRes)
/// PlayerRes - ABSTRACT
/// All PlayerResourceXYZ inherit from this - shared player id field
/datum/apiModel/Tracked/PlayerRes
	var/player_id	= null // integer

/datum/apiModel/Tracked/PlayerRes/SetupFromResponse(response)
	. = ..()
	src.player_id = response["player_id"]

/datum/apiModel/Tracked/PlayerRes/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.player_id) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/ToList()
	. = ..()
	.["player_id"] = src.player_id
