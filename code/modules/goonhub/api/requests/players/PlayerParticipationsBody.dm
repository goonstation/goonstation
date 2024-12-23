
/datum/apiBody/PlayerParticipation
	fields = list(
		"player_id", // integer
		"round_id", // integer
		"job" // string
	)

/datum/apiBody/PlayerParticipation/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["round_id"]) \
	)
		return FALSE
