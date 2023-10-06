
/// PollOptionResource
/datum/apiModel/PollOptionResource
	var/id 						= null // integer
	var/poll_id				= null // integer
	var/option				= null // integer
	var/position			= null // string
	var/answers_count		= null // integer
	var/answers_player_ids	= null // [integer]

/datum/apiModel/PollOptionResource/New(
	id,
	poll_id,
	option,
	position,
	answers_count,
	answers_player_ids,
)
	. = ..()
	src.id = id
	src.poll_id = poll_id
	src.option = option
	src.position = position
	src.answers_count = answers_count
	src.answers_player_ids = answers_player_ids

/datum/apiModel/PollOptionResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.poll_id) \
		|| isnull(src.option) \
		|| isnull(src.position) \
		|| isnull(src.answers_count) \
		|| isnull(src.answers_player_ids) \
	)
		return FALSE

/datum/apiModel/PollOptionResource/ToString()
	. = list()
	.["id"] = src.id
	.["poll_id"] = src.poll_id
	.["option"] = src.option
	.["position"] = src.position
	.["answers_count"] = src.answers_count
	.["answers_player_ids"] = src.answers_player_ids
	return json_encode(.)
