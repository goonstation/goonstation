/// GameAdminResource
/datum/apiModel/GameAdminResource
	var/id				 = null // int
	var/ckey			 = null // string
	var/name 			 = null // string - not required
	var/discord_id = null // string - not required
	var/datum/apiModel/Tracked/GameAdminRank/rank = null // not required
	var/created_at = null // string - not required
	var/updated_at = null // string - not required

/datum/apiModel/GameAdminResource/SetupFromResponse(response)
	. = ..()
	src.id = response["id"]
	src.ckey = response["ckey"]
	src.name = response["name"]
	src.discord_id = response["discord_id"]
	src.created_at = response["created_at"]
	src.updated_at = response["updated_at"]

	if (("rank" in response) && islist(response["rank"]))
		src.rank = new
		src.rank = src.rank.SetupFromResponse(response["rank"])

/datum/apiModel/GameAdminResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.id) \
		|| isnull(src.ckey)
	)
		return FALSE

/datum/apiModel/GameAdminResource/ToList()
	. = ..()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["name"] = src.name
	.["discord_id"] = src.discord_id
	if (src.rank)
		.["rank"] = src.rank.ToList()
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
