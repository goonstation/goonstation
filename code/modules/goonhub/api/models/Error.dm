
/// Error
/datum/apiModel/Error
	var/message	= null // string
	var/errors	= null // null or list
	var/status_code = 500 // null or int

/datum/apiModel/Error/SetupFromResponse(response)
	. = ..()
	src.message = response["message"]
	src.errors = response["errors"]
	src.status_code = response["status_code"]

/datum/apiModel/Error/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.message) \
	)
		return FALSE

/datum/apiModel/Error/ToList()
	. = ..()
	.["message"] = src.message
	.["errors"] = src.errors
	.["status_code"] = src.status_code
