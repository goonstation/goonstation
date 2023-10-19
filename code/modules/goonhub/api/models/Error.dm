
/// Error
/datum/apiModel/Error
	var/message	= null // string
	var/errors	= null // null or list

/datum/apiModel/Error/SetupFromResponse(response)
	. = ..()
	src.message = response["message"]
	src.errors = response["errors"]

/datum/apiModel/Error/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.message) \
	)
		return FALSE

/datum/apiModel/Error/ToString()
	. = list()
	.["message"] = src.message
	.["errors"] = src.errors
	return json_encode(.)
