

/// PlayerAntagResource
/datum/apiModel/PlayerRes/PlayerAntagResource
	var/round_id		= null // integer
	var/antag_role		= null // string
	var/late_join		= null // boolean
	var/weight_exempt	= null // string

/datum/apiModel/PlayerRes/PlayerAntagResource/New(
	id,
	player_id,
	round_id,
	antag_role,
	late_join,
	weight_exempt,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.round_id = round_id
	src.antag_role = antag_role
	src.late_join = late_join
	src.weight_exempt = weight_exempt
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PlayerRes/PlayerAntagResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.round_id) \
		|| isnull(src.antag_role) \
		|| isnull(src.late_join) \
		|| isnull(src.weight_exempt) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/PlayerRes/PlayerAntagResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["round_id"] = src.round_id
	.["antag_role"] = src.antag_role
	.["late_join"] = src.late_join
	.["weight_exempt"] = src.weight_exempt
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
