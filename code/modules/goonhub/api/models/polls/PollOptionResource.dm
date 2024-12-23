
/// PollOptionResource
/datum/apiModel/PollOptionResource
	var/id 					= null // integer
	var/poll_id				= null // integer
	var/option				= null // integer
	var/position			= null // string
	var/answers_count		= null // integer
	var/answers_player_ids	= null // [integer]

/datum/apiModel/PollOptionResource/SetupFromResponse(response)
	. = ..()
	src.id = response["id"]
	src.poll_id = response["poll_id"]
	src.option = response["option"]
	src.position = response["position"]
	src.answers_count = response["answers_count"]
	src.answers_player_ids = response["answers_player_ids"]

/datum/apiModel/PollOptionResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.id) \
		|| isnull(src.poll_id) \
		|| isnull(src.option) \
		|| isnull(src.answers_player_ids) \
	)
		return FALSE

/datum/apiModel/PollOptionResource/ToList()
	. = ..()
	.["id"] = src.id
	.["poll_id"] = src.poll_id
	.["option"] = src.option
	.["position"] = src.position
	.["answers_count"] = src.answers_count
	.["answers_player_ids"] = src.answers_player_ids
