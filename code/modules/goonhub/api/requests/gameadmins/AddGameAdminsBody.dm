/datum/apiBody/gameadmins/post
	var/ckey = "string"
	var/name = "string"
	var/discord_id = "string"
	var/rank = "integer"

/datum/apiBody/gameadmins/post/New(
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

/datum/apiBody/gameadmins/post/VerifyIntegrity()
	if (
		isnull(src.ckey) \
		|| isnull(src.name) \
		|| isnull(src.discord_id) \
		|| isnull(src.rank)
	)
		return FALSE

/datum/apiBody/gameadmins/post/toJson()
	return json_encode(list(
		"ckey"				= src.ckey,
		"name"				= src.name,
		"discord_id"		= src.discord_id,
		"rank"				= src.rank,
	))
