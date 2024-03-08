
/datum/apiBody/bans/add_detail
	fields = list(
		"ckey", // string
		"comp_id", // string
		"ip" // string
	)

/datum/apiBody/bans/add_detail/VerifyIntegrity()
	. = ..()
