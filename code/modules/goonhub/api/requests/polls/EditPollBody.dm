
/datum/apiBody/polls/edit
	fields = list(
		"question", // string
		"expires_at", // date-time
		"servers" // [string]
	)

/datum/apiBody/polls/edit/VerifyIntegrity()
	. = ..()
