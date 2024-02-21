
/datum/apiBody/dectalk/play
	fields = list(
		"text", // string
		"round_id" // integer
	)

/datum/apiBody/dectalk/play/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["text"]) \
		|| isnull(src.values["round_id"])
	)
		return FALSE
