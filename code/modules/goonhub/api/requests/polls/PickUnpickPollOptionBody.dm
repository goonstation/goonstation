
/datum/apiBody/polls/options/pickUnpick
	fields = list(
		"player_id", // integer
	)

/datum/apiBody/polls/options/pickUnpick/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
	)
		return FALSE
