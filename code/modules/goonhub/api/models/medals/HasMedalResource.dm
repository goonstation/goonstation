
/// HasMedalResource
/datum/apiModel/HasMedalResource
	var/has_medal = null // bool

/datum/apiModel/HasMedalResource/SetupFromResponse(response)
	. = ..()
	src.has_medal = response["has_medal"]

/datum/apiModel/HasMedalResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.has_medal) \
	)
		return FALSE

/datum/apiModel/HasMedalResource/ToList()
	. = ..()
	.["has_medal"] = src.has_medal
