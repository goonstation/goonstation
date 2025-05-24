/datum/apiBody/gameauth/verify
	fields = list(
		"session", // string
		"server_id" // string
	)

/datum/apiBody/gameauth/verify/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["session"]) \
		|| isnull(src.values["server_id"])
	)
		return FALSE
