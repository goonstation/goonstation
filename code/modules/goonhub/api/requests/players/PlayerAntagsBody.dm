
/datum/apiBody/PlayerAntags
	var/player_id			= 0
	var/round_id			= 0
	var/antag_role			= "string"
	var/late_join			= "string"
	var/weight_exempt		= "string"

/datum/apiBody/PlayerAntags/New(
	player_id,
	round_id,
	antag_role,
	late_join,
	weight_exempt
)
	. = ..()
	src.player_id = player_id
	src.round_id = round_id
	src.antag_role = antag_role
	src.late_join = late_join
	src.weight_exempt = weight_exempt

/datum/apiBody/PlayerAntags/VerifyIntegrity()
	if (
		isnull(src.player_id) \
		|| isnull(src.round_id) \
		|| isnull(src.antag_role) \
		|| isnull(src.late_join) \
		|| isnull(src.weight_exempt) \
	)
		return FALSE

/datum/apiBody/PlayerAntags/toJson()
	return json_encode(list(
		"player_id"			= src.player_id,
		"round_id"			= src.round_id,
		"antag_role"		= src.antag_role,
		"late_join"			= src.late_join,
		"weight_exempt"		= src.weight_exempt,
	))
