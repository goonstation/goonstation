
/// PlayerSaveResource
/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource
	var/name	= null // string
	var/data	= null // integer

/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/SetupFromResponse(response)
	. = ..()
	src.name = response["name"]
	src.data = response["data"]

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
