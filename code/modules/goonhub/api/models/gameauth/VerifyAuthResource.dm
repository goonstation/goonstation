
/// VerifyAuthResource
/datum/apiModel/VerifyAuthResource
	var/is_admin = null // bool
	var/admin_rank = null // string|null

/datum/apiModel/VerifyAuthResource/SetupFromResponse(response)
	. = ..()
	src.is_admin = response["is_admin"]
	src.admin_rank = response["admin_rank"]

/datum/apiModel/VerifyAuthResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.is_admin)
	)
		return FALSE

/datum/apiModel/VerifyAuthResource/ToList()
	. = ..()
	.["is_admin"] = src.is_admin
	.["admin_rank"] = src.admin_rank
