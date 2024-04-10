/// GameAdminRank
/datum/apiModel/Tracked/GameAdminRank
	var/rank = null // string

/datum/apiModel/Tracked/GameAdminRank/SetupFromResponse(response)
	. = ..()
	src.rank = response["rank"]

/datum/apiModel/Tracked/GameAdminRank/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.rank) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/GameAdminRank/ToList()
	. = ..()
	.["id"] = src.id
	.["rank"] = src.rank
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
