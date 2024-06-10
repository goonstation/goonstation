/// GameAdminResource
/datum/apiModel/Tracked/GameAdminResource
	var/ckey			= null // string
	var/name 			= null // string
	var/discord_id 		= null // string
	var/datum/apiModel/Tracked/GameAdminRank/rank = null

/datum/apiModel/Tracked/GameAdminResource/SetupFromResponse(response)
	. = ..()
	src.ckey = response["ckey"]
	src.name = response["name"]
	src.discord_id = response["discord_id"]

	if ("rank" in response)
		src.rank = new
		src.rank = src.rank.SetupFromResponse(response["rank"])

/datum/apiModel/Tracked/GameAdminResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey)
	)
		return FALSE

/datum/apiModel/Tracked/GameAdminResource/ToList()
	. = ..()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["name"] = src.name
	.["discord_id"] = src.discord_id
	if (src.rank)
		.["rank"] = src.rank.ToList()
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
