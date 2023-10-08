
/// PlayerMetadataResource
/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource
	var/player	= null // { id: integer, ckey: string } - TODO
	var/ckey	= null // string
	var/data	= null // integer

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/SetupFromResponse(response)
	. = ..()
	src.player = response["player"]
	src.ckey = response["ckey"]
	src.data = response["data"]

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.player) \
		|| isnull(src.ckey) \
		|| isnull(src.data) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["player"] = src.player
	.["ckey"] = src.ckey
	.["data"] = src.data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
