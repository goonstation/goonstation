
/// MedalResource
/datum/apiModel/Tracked/MedalResource
	var/uuid				= null // string
	var/title				= null // string
	var/description	= null // string
	var/hidden			= null // boolean

/datum/apiModel/Tracked/MedalResource/SetupFromResponse(response)
	. = ..()
	src.uuid = response["uuid"]
	src.title = response["title"]
	src.description = response["description"]
	src.hidden = response["hidden"]

/datum/apiModel/Tracked/MedalResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.uuid) \
		|| isnull(src.title)
	)
		return FALSE

/datum/apiModel/Tracked/MedalResource/ToList()
	. = ..()
	.["uuid"] = src.uuid
	.["title"] = src.title
	.["description"] = src.description
	.["hidden"] = src.hidden
