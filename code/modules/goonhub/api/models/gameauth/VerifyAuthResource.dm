
/// VerifyAuthResource
/datum/apiModel/VerifyAuthResource
	var/player_id = null // integer
	var/ckey = null // string
	var/key = null // string
	var/is_admin = null // bool
	var/admin_rank = null // string|null
	var/is_mentor = null // bool
	var/is_hos = null // bool
	var/is_whitelisted = null // bool
	var/can_bypass_cap = null // bool

/datum/apiModel/VerifyAuthResource/SetupFromResponse(response)
	. = ..()
	src.player_id = response["player_id"]
	src.ckey = response["ckey"]
	src.key = response["key"]
	src.is_admin = response["is_admin"]
	src.admin_rank = response["admin_rank"]
	src.is_mentor = response["is_mentor"]
	src.is_hos = response["is_hos"]
	src.is_whitelisted = response["is_whitelisted"]
	src.can_bypass_cap = response["can_bypass_cap"]

/datum/apiModel/VerifyAuthResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.player_id) \
		|| isnull(src.ckey) \
		|| isnull(src.is_admin) \
		|| isnull(src.is_mentor) \
		|| isnull(src.is_hos) \
		|| isnull(src.is_whitelisted) \
		|| isnull(src.can_bypass_cap)
	)
		return FALSE

/datum/apiModel/VerifyAuthResource/ToList()
	. = ..()
	.["player_id"] = src.player_id
	.["ckey"] = src.ckey
	.["key"] = src.key
	.["is_admin"] = src.is_admin
	.["admin_rank"] = src.admin_rank
	.["is_mentor"] = src.is_mentor
	.["is_hos"] = src.is_hos
	.["is_whitelisted"] = src.is_whitelisted
	.["can_bypass_cap"] = src.can_bypass_cap
