
/// PlayerParticipationResource
/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource
	var/round_id	= null // string
	var/job				= null // string
	var/legacy_data	= null // string

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.job = response["job"]
	src.legacy_data = response["legacy_data"]

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.round_id)
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["round_id"] = src.round_id
	.["job"] = src.job
	.["legacy_data"] = src.legacy_data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
