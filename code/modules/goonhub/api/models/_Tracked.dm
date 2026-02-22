
ABSTRACT_TYPE(/datum/apiModel/Tracked)
/// Tracked - ABSTRACT
/// Anything with the two timestamp fields inherit from this
/datum/apiModel/Tracked
	var/id			= null // integer
	var/created_at	= null // date-time | null
	var/updated_at	= null // date-time | null

/datum/apiModel/Tracked/SetupFromResponse(response)
	. = ..()
	src.id = response["id"]
	src.created_at = response["created_at"]
	src.updated_at = response["updated_at"]

/datum/apiModel/Tracked/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.id)
	)
		return FALSE

/datum/apiModel/Tracked/ToList()
	. = ..()
	.["id"] = src.id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
