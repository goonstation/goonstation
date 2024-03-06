
/// PlayerResource
/datum/apiModel/Tracked/PlayerResource
	var/ckey			= null // string
	var/key				= null // string
	var/byond_join_date	= null // string
	var/byond_major		= null // integer
	var/byond_minor		= null // integer

/datum/apiModel/Tracked/PlayerResource/SetupFromResponse(response)
	. = ..()
	src.ckey = response["ckey"]
	src.key = response["key"]
	src.byond_join_date = response["byond_join_date"]
	src.byond_major = response["byond_major"]
	src.byond_minor = response["byond_minor"]

/datum/apiModel/Tracked/PlayerResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey) \
		|| isnull(src.key) \
		|| isnull(src.byond_major) \
		|| isnull(src.byond_minor) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerResource/ToList()
	. = ..()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["key"] = src.key
	.["byond_join_date"] = src.byond_join_date
	.["byond_major"] = src.byond_major
	.["byond_minor"] = src.byond_minor
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
