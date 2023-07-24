

/// PollAnswer
/datum/apiModel/Tracked/PlayerRes/PollAnswer
	var/poll_option_id	= null // integer

/datum/apiModel/Tracked/PlayerRes/PollAnswer/New(
	id,
	player_id,
	poll_option_id,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.poll_option_id = poll_option_id
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/PlayerRes/PollAnswer/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.player_id) \
		|| isnull(src.poll_option_id) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PollAnswer/ToString()
	. = list()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["poll_option_id"] = src.poll_option_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
