
/// Player
/datum/apiModel/Tracked/Player
	var/ckey						= null // string
	var/key							= null // string|null
	var/byond_join_date	= null // string|null
	var/byond_major			= null // integer|null
	var/byond_minor			= null // integer|null
	var/is_admin				= null // boolean - not required
	var/admin_rank			= null // string - not required
	var/is_mentor				= null // boolean - not required
	var/is_hos					= null // boolean - not required
	var/is_whitelisted	= null // boolean - not required
	var/can_bypass_cap	= null // boolean - not required

/datum/apiModel/Tracked/Player/SetupFromResponse(response)
	. = ..()
	src.ckey = response["ckey"]
	src.key = response["key"]
	src.byond_join_date = response["byond_join_date"]
	src.byond_major = response["byond_major"]
	src.byond_minor = response["byond_minor"]
	src.is_admin = response["is_admin"]
	src.admin_rank = response["admin_rank"]
	src.is_mentor = response["is_mentor"]
	src.is_hos = response["is_hos"]
	src.is_whitelisted = response["is_whitelisted"]
	src.can_bypass_cap = response["can_bypass_cap"]

/datum/apiModel/Tracked/Player/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey)
	)
		return FALSE

/datum/apiModel/Tracked/Player/ToList()
	. = ..()
	.["ckey"] = src.ckey
	.["key"] = src.key
	.["byond_join_date"] = src.byond_join_date
	.["byond_major"] = src.byond_major
	.["byond_minor"] = src.byond_minor
	.["is_admin"] = src.is_admin
	.["admin_rank"] = src.admin_rank
	.["is_mentor"] = src.is_mentor
	.["is_hos"] = src.is_hos
	.["is_whitelisted"] = src.is_whitelisted
	.["can_bypass_cap"] = src.can_bypass_cap
