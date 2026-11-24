
/datum/apiBody/players/metadata/bulk
	fields = list(
		"metadata", // [string]
		"limit" // integer
	)

/datum/apiBody/players/metadata/bulk/VerifyIntegrity()
	. = ..()
	if (
		!length(src.values["metadata"]) \
		|| !isnum(src.values["limit"])
	)
		return FALSE
