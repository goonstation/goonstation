/datum/apiBody/gameadmins/put
	var/ckey = "string"
	var/name = "string"
	var/discord_id = "string"
	var/rank = "integer"

/datum/apiBody/gameadmins/put/New(
	ckey,
	name,
	discord_id,
	rank
)
	. = ..()
	src.ckey = ckey
	src.name = name
	src.discord_id = discord_id
	src.rank = rank

/datum/apiBody/gameadmins/put/VerifyIntegrity()
	if (
		isnull(src.ckey) \
		|| isnull(src.name) \
		|| isnull(src.discord_id) \
		|| isnull(src.rank)
	)
		return FALSE

/datum/apiBody/gameadmins/put/toJson()
	return json_encode(list(
		"ckey"				= src.ckey,
		"name"				= src.name,
		"discord_id"		= src.discord_id,
		"rank"				= src.rank,
	))
