
/datum/apiBody/polls/add
	fields = list(
		"game_admin_ckey", // string
		"question", // string
		"multiple_choice", // boolean
		"expires_at", // date-time
		"options", // [string]
		"servers" // [string]
	)

/datum/apiBody/polls/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["question"]) \
		|| isnull(src.values["options"]) \
	)
		return FALSE
