
/// PlayerMetadataList
/datum/apiModel/Paginated/PlayerMetadataList

/datum/apiModel/Paginated/PlayerMetadataList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource/playerMetadata = new()
		playerMetadata.SetupFromResponse(item)
		src.data.Add(playerMetadata)
