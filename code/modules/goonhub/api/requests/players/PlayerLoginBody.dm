
/datum/apiBody/players/login
	fields = list(
		"ckey", // string
		"key", // string
		"ip", // string
		"comp_id", // string
		"byond_major", // integer
		"byond_minor", // integer
		"round_id", // integer
		"server_id", // string
	)

/datum/apiBody/players/login/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["ckey"]) \
		|| isnull(src.values["key"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["server_id"])
	)
		return FALSE
