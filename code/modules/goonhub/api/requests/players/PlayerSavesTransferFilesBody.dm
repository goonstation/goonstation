
/datum/apiBody/PlayerSavesTransferFiles
	fields = list(
		"from_ckey", // integer
		"to_ckey", // string
	)

/datum/apiBody/PlayerSavesTransferFiles/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["from_ckey"]) \
		|| isnull(src.values["to_ckey"]) \
	)
		return FALSE
