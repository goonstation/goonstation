
/// BeginAuthResource
/datum/apiModel/BeginAuthResource
	var/token = null // string

/datum/apiModel/BeginAuthResource/SetupFromResponse(response)
	. = ..()
	src.token = response["token"]

/datum/apiModel/BeginAuthResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.token)
	)
		return FALSE

/datum/apiModel/BeginAuthResource/ToList()
	. = ..()
	.["token"] = src.token
