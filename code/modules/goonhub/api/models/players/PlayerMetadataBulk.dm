
/// PlayerMetadataBulk
/datum/apiModel/PlayerMetadataBulk
	var/list/data = null // { [metadata: string]: { count: integer, ckeys: [string] } }

/datum/apiModel/PlayerMetadataBulk/SetupFromResponse(response)
	. = ..()
	src.data = response

/datum/apiModel/PlayerMetadataBulk/VerifyIntegrity()
	. = ..()
	if (
		!islist(src.data) \
	)
		return FALSE

/datum/apiModel/PlayerMetadataBulk/ToList()
	. = ..()
	.["data"] = src.data
