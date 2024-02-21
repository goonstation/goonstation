
/datum/apiBody/polls/options/edit
	fields = list(
		"option", // string
		"position" // integer
	)

/datum/apiBody/polls/options/edit/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["option"]) \
	)
		return FALSE
