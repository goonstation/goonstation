
/// PlayerParticipationResource
/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource
	var/round_id		= null // string
	var/legacy_data		= null // string

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/New(
	id,
	player_id,
	round_id,
	legacy_data,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.round_id = round_id
	src.legacy_data = legacy_data
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.round_id) \
		|| isnull(src.legacy_data) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["round_id"] = src.round_id
	.["legacy_data"] = src.legacy_data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
