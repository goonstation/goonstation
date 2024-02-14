
/datum/apiBody/PlayerParticipationBulk
	fields = list(
		"players", // list
		"round_id" // integer
	)

/datum/apiBody/PlayerParticipationBulk/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["players"]) \
		|| isnull(src.values["round_id"]) \
	)
		return FALSE
