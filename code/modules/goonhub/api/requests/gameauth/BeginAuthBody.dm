/datum/apiBody/gameauth/begin
	fields = list(
		"server_id", // string
		"ckey", // string
		"key", // string
		"ip", // string
		"comp_id", // string
		"byond_major", // integer
		"byond_minor", // integer
		"round_id", // integer
	)

/datum/apiBody/gameauth/begin/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["server_id"]) \
		|| isnull(src.values["ckey"])
	)
		return FALSE
