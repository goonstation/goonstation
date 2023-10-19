
/// PlayerMetadataArray
/datum/apiModel/PlayerMetadataArray
	var/list/data = null // [string]

/datum/apiModel/PlayerMetadataArray/SetupFromResponse(response)
	. = ..()
	src.data = response

/datum/apiModel/PlayerMetadataArray/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.data) \
	)
		return FALSE

/datum/apiModel/PlayerMetadataArray/ToString()
	. = list()
	.["data"] = src.data
	return json_encode(.)
