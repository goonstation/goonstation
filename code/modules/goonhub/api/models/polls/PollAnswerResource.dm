

// TODO ZEWAKA CREATED NO PLAYER ID BUT CREATE/UPDAE

/// PollAnswerResource
/datum/apiModel/PlayerRes/PollAnswerResource
	var/poll_option_id	= null // integer
	var/poll_id			= null // integer
/datum/apiModel/PlayerRes/PollAnswerResource/New(
	id,
	player_id,
	poll_option_id,
	poll_id,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.poll_option_id = poll_option_id
	src.poll_id = poll_id
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PlayerRes/PollAnswerResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.poll_option_id) \
		|| isnull(src.poll_id) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/PlayerRes/PollAnswerResource/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["poll_option_id"] = src.poll_option_id
	.["poll_id"] = src.poll_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
