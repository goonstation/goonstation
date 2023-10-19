

/// PlayerAntagResource
/datum/apiModel/Tracked/PlayerRes/PlayerAntagResource
	var/round_id		= null // integer
	var/antag_role		= null // string
	var/late_join		= null // boolean
	var/weight_exempt	= null // string

/datum/apiModel/Tracked/PlayerRes/PlayerAntagResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.antag_role = response["antag_role"]
	src.late_join = response["late_join"]
	src.weight_exempt = response["weight_exempt"]

/datum/apiModel/Tracked/PlayerRes/PlayerAntagResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.round_id) \
		|| isnull(src.antag_role) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerAntagResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["round_id"] = src.round_id
	.["antag_role"] = src.antag_role
	.["late_join"] = src.late_join
	.["weight_exempt"] = src.weight_exempt
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
