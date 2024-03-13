
/// PlayerSaveResource
/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource
	var/name = null // string
	var/data = null // string

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/SetupFromResponse(response)
	. = ..()
	src.name = response["name"]
	src.data = response["data"]

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.name) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["name"] = src.name
	.["data"] = src.data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
