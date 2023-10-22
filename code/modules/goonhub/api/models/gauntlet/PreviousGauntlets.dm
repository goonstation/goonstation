
/// PreviousGauntlets
/datum/apiModel/PreviousGauntlets
	var/gauntlets_completed = null // integer

/datum/apiModel/PreviousGauntlets/SetupFromResponse(response)
	. = ..()
	src.gauntlets_completed = response["gauntlets_completed"]

/datum/apiModel/PreviousGauntlets/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.gauntlets_completed) \
	)
		return FALSE

/datum/apiModel/PreviousGauntlets/ToList()
	. = ..()
	.["gauntlets_completed"] = src.gauntlets_completed
