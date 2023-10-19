
/// PollAnswerResource
/datum/apiModel/Tracked/PollAnswerResource
	var/poll_option_id	= null // integer
	var/poll_id			= null // integer

/datum/apiModel/Tracked/PollAnswerResource/SetupFromResponse(response)
	. = ..()
	src.poll_option_id = response["poll_option_id"]
	src.poll_id = response["poll_id"]

/datum/apiModel/Tracked/PollAnswerResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.poll_option_id) \
		|| isnull(src.poll_id) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/PollAnswerResource/ToString()
	. = list()
	.["id"] = src.id
	.["poll_option_id"] = src.poll_option_id
	.["poll_id"] = src.poll_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
