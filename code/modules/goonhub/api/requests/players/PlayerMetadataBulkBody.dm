
/datum/apiBody/players/metadatabulk
	fields = list(
		"metadata", // [string]
		"limit" // integer
	)

/datum/apiBody/players/metadatabulk/VerifyIntegrity()
	. = ..()
	if (
		!length(src.values["metadata"]) \
		|| !isnum(src.values["limit"])
	)
		return FALSE
