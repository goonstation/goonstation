/// GameAdminResource
/datum/apiModel/Tracked/GameAdminResource
	var/ckey			= null // string
	var/name 			= null // string
	var/discord_id 		= null // string
	var/datum/apiModel/Tracked/GameAdminRank/rank = null

/datum/apiModel/Tracked/GameAdminResource/New(
	id,
	ckey,
	name,
	discord_id,
	rank,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.ckey = ckey
	src.name = name
	src.discord_id = discord_id
	src.rank = rank
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/Tracked/GameAdmin/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.ckey) \
		|| isnull(src.name) \
		|| isnull(src.discord_id) \
		|| isnull(src.rank) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/Tracked/GameAdmin/ToString()
	. = list()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["name"] = src.name
	.["discord_id"] = src.discord_id
	.["rank"] = src.rank
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
