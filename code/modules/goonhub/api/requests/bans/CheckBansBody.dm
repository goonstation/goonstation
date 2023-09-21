
/datum/apiBody/bans/check
	var/server_id			= "string"
	var/ckey				= "string"
	var/comp_id				= "string"
	var/ip					= "string"

/datum/apiBody/bans/check/New(
	server_id,
	ckey,
	comp_id,
	ip
)
	. = ..()
	src.server_id = server_id
	src.ckey = ckey
	src.comp_id = comp_id
	src.ip = ip

/datum/apiBody/bans/check/VerifyIntegrity()
	if (
		isnull(src.server_id) \
		|| isnull(src.ckey) \
		|| isnull(src.comp_id) \
		|| isnull(src.ip) \
	)
		return FALSE

/datum/apiBody/bans/check/toJson()
	return json_encode(list(
		"server_id"			= src.server_id,
		"ckey"				= src.ckey,
		"comp_id"			= src.comp_id,
		"ip"				= src.ip
	))
