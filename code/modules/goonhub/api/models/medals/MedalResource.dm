
/// MedalResource
/datum/apiModel/Tracked/MedalResource
	var/title				= null // string
	var/description	= null // string
	var/hidden			= null // boolean

/datum/apiModel/Tracked/MedalResource/SetupFromResponse(response)
	. = ..()
	src.title = response["title"]
	src.description = response["description"]
	src.hidden = response["hidden"]

/datum/apiModel/Tracked/MedalResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.title) \
	)
		return FALSE

/datum/apiModel/Tracked/MedalResource/ToList()
	. = ..()
	.["title"] = src.title
	.["description"] = src.description
	.["hidden"] = src.hidden
