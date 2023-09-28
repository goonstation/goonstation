/datum/apiBody/rounds/end
	var/crashed = FALSE	//boolean

/datum/apiBody/rounds/end/New(
	crashed
)
	. = ..()
	src.crashed = crashed

/datum/apiBody/rounds/end/VerifyIntegrity()
	if (
		isnull(src.crashed)
	)
		return FALSE

/datum/apiBody/rounds/end/toJson()
	return json_encode(list(
		"crashed"	= src.crashed,
	))
