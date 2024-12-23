
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

/datum/apiModel/Message/ToList()
	. = ..()
	.["message"] = src.message
