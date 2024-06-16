
/datum/apiBody/players/medals/transfer
	fields = list(
		"source_ckey", // string
		"target_ckey", // string
	)

/datum/apiBody/players/medals/transfer/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["source_ckey"]) \
		|| isnull(src.values["target_ckey"]) \
	)
		return FALSE
