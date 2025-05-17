
/// PlayerDataResource
/datum/apiModel/Tracked/PlayerRes/PlayerDataResource
	var/key		= null // string
	var/value	= null // any

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/SetupFromResponse(response)
	. = ..()
	src.key =	response["key"]
	src.value =	response["value"]

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.key)
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["key"] = src.key
	.["value"] = src.value
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
