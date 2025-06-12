/datum/apiBody/gameauth/verify
	fields = list(
		"session", // string
		"server_id", // string
		"ip", // string
		"comp_id", // integer
		"byond_major", // integer
		"byond_minor", // integer
		"round_id" // integer
	)

/datum/apiBody/gameauth/verify/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["session"]) \
		|| isnull(src.values["server_id"])
	)
		return FALSE
