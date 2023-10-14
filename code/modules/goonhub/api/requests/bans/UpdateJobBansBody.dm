
/datum/apiBody/jobbans/update
	fields = list(
		"server_id", // string
		"job", // string
		"reason", // string
		"duration" // integer
	)

/datum/apiBody/jobbans/update/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["job"]) \
	)
		return FALSE

