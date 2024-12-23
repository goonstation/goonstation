
/// NumbersStationPasswordResource
/datum/apiModel/NumbersStationPasswordResource
	var/numbers = null // string

/datum/apiModel/NumbersStationPasswordResource/SetupFromResponse(response)
	. = ..()
	src.numbers = response["numbers"]

/datum/apiModel/NumbersStationPasswordResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.numbers) \
	)
		return FALSE

/datum/apiModel/NumbersStationPasswordResource/ToList()
	. = ..()
	.["numbers"] = src.numbers
