
/// Message
/datum/apiModel/Message
	var/message = null // string

/datum/apiModel/Message/SetupFromResponse(response)
	. = ..()
	src.message = response["message"]

/datum/apiModel/Message/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.message)
	)
		return FALSE

/datum/apiModel/Message/ToString()
	. = list()
	.["message"] = src.message
	return json_encode(.)
