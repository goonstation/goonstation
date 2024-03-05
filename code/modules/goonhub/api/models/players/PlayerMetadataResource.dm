
/// PlayerMetadataResource
/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource
	var/player = null // { id: integer, ckey: string }
	var/metadata	 = null // string

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/SetupFromResponse(response)
	. = ..()
	if ("player" in response)
		src.player = response["player"]
	src.metadata = response["metadata"]

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.metadata) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["player"] = src.player
	.["metadata"] = src.metadata
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
