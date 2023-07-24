
// TODO ZEWAKA CREATED AT

/// GameAdmin
/datum/apiModel/GameAdmin
	var/ckey		= null // integer
	var/name		= null // string
	var/discord_id	= null // string
	var/rank_id		= null // integer
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/GameAdmin/New(
	id,
	ckey,
	name,
	discord_id,
	rank_id,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.ckey = ckey
	src.name = name
	src.discord_id = discord_id
	src.rank_id = rank_id
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/GameAdmin/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.ckey) \
		|| isnull(src.name) \
		|| isnull(src.discord_id) \
		|| isnull(src.rank_id) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
	)
		return FALSE

/datum/apiModel/GameAdmin/ToString()
	. = list()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["name"] = src.name
	.["discord_id"] = src.discord_id
	.["rank_id"] = src.rank_id
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
