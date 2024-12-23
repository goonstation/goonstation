
/datum/apiBody/rounds/post
	fields = list(
		"map", // string
		"server_id", // string
		"rp_mode", // boolean
		"test_merges" // array
	)

/datum/apiBody/rounds/post/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["map"]) \
		|| isnull(src.values["server_id"]) \
	)
		return FALSE
