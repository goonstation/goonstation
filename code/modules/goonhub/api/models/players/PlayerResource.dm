
/// PlayerResource
/datum/apiModel/Tracked/PlayerResource
	var/ckey			= null // string
	var/key				= null // string
	var/byond_join_date	= null // string
	var/byond_major		= null // integer
	var/byond_minor		= null // integer
	var/is_admin		= null // boolean
	var/admin_rank		= null // string
	var/is_mentor		= null // boolean
	var/is_hos			= null // boolean
	var/is_whitelisted	= null // boolean
	var/can_bypass_cap	= null // boolean

/datum/apiModel/Tracked/PlayerResource/SetupFromResponse(response)
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

/datum/apiModel/Tracked/PlayerResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey) \
		|| isnull(src.key) \
		|| isnull(src.byond_major) \
		|| isnull(src.byond_minor) \
		|| isnull(src.is_admin) \
		|| isnull(src.is_mentor) \
		|| isnull(src.is_hos) \
		|| isnull(src.is_whitelisted) \
		|| isnull(src.can_bypass_cap)
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
	.["is_admin"] = src.is_admin
	.["admin_rank"] = src.admin_rank
	.["is_mentor"] = src.is_mentor
	.["is_hos"] = src.is_hos
	.["is_whitelisted"] = src.is_whitelisted
	.["can_bypass_cap"] = src.can_bypass_cap
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
