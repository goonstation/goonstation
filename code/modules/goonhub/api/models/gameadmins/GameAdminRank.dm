/// GameAdminRank
/datum/apiModel/Tracked/GameAdminRank
	var/rank = null // string

/datum/apiModel/Tracked/GameAdminRank/SetupFromResponse(response)
	. = ..()
	src.rank = response["rank"]

/datum/apiModel/Tracked/GameAdminRank/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.rank)
	)
		return FALSE

/datum/apiModel/Tracked/GameAdminRank/ToList()
	. = ..()
	.["rank"] = src.rank
