
/datum/apiBody/polls/options/add
	fields = list(
		"option", // string
	)

/datum/apiBody/polls/options/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["option"]) \
	)
		return FALSE
