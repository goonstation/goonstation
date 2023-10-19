
/datum/apiBody/bans/add_detail
	fields = list(
		"ckey", // string
		"comp_id", // string
		"ip" // string
	)

/datum/apiBody/bans/add_detail/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["ckey"]) \
		|| isnull(src.values["comp_id"]) \
		|| isnull(src.values["ip"]) \
	)
		return FALSE
