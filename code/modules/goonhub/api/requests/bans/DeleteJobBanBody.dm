
/datum/apiBody/jobbans/delete
	fields = list(
		"server_id", // string
		"ckey", // string
		"job" // string
	)

/datum/apiBody/jobbans/delete/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["ckey"]) \
		|| isnull(src.values["job"]) \
	)
		return FALSE
