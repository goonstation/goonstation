
/datum/apiBody/PlayerSavesBulkData
	var/data	= null

/datum/apiBody/PlayerSavesBulkData/New(
	data
)
	. = ..()
	src.data = data

/datum/apiBody/PlayerSavesBulkData/VerifyIntegrity()
	if (
		isnull(src.data)
	)
		return FALSE

/datum/apiBody/PlayerSavesBulkData/toJson()
	return json_encode(list(
		"data"	= src.data
	))
