
/datum/apiBody/PlayerSavesBulkData
	fields = list(
		"data" // string
	)

/datum/apiBody/PlayerSavesBulkData/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["data"])
	)
		return FALSE
