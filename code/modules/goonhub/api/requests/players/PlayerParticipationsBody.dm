
/datum/apiBody/PlayerParticipation
	var/player_id			= 0
	var/round_id			= 0

/datum/apiBody/PlayerParticipation/New(
	player_id,
	round_id
)
	. = ..()
	src.player_id = player_id
	src.round_id = round_id

/datum/apiBody/PlayerParticipation/VerifyIntegrity()
	if (
		isnull(src.player_id) \
		|| isnull(src.round_id) \
	)
		return FALSE

/datum/apiBody/PlayerParticipation/toJson()
	return json_encode(list(
		"player_id"			= src.player_id,
		"round_id"			= src.round_id
	))
