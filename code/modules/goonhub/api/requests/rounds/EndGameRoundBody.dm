
/datum/apiBody/rounds/end
	fields = list(
		"crashed", // boolean
	)

/datum/apiBody/rounds/end/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["crashed"]) \
	)
		return FALSE
