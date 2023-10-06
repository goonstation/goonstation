
ABSTRACT_TYPE(/datum/apiModel/Tracked)
/// Tracked - ABSTRACT
/// Anything with the two timestamp fields inherit from this
/datum/apiModel/Tracked
	var/id = null // int
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/Tracked/New(
	id,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.created_at) \
	)
		return FALSE
	return TRUE

/datum/apiModel/Tracked/ToString()
	. = list()
	.["id"] = src.id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
