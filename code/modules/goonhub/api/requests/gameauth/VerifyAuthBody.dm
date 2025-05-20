/datum/apiBody/gameauth/verify
	fields = list(
		"session" // string
	)

/datum/apiBody/gameauth/verify/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["session"])
	)
		return FALSE
