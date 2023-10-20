
/datum/apiBody/dectalk/play
	fields = list(
		"text", // string
	)

/datum/apiBody/dectalk/play/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["text"]) \
	)
		return FALSE
