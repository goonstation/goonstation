
/datum/apiBody/PlayerAntags
	fields = list(
		"player_id", // integer
		"round_id", // integer
		"antag_role", // string
		"late_join", // boolean
		"weight_exempt" // boolean
	)

/datum/apiBody/PlayerAntags/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["player_id"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["antag_role"]) \
	)
		return FALSE
