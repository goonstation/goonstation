
/datum/apiBody/bans/add_detail
	var/ckey				= "string"
	var/comp_id				= "string"
	var/ip					= "string"

/datum/apiBody/bans/add_detail/New(
	ckey,
	comp_id,
	ip
)
	. = ..()
	src.ckey = ckey
	src.comp_id = comp_id
	src.ip = ip

/datum/apiBody/bans/add_detail/VerifyIntegrity()
	if (
		isnull(src.ckey) \
		|| isnull(src.comp_id) \
		|| isnull(src.ip) \
	)
		return FALSE

/datum/apiBody/bans/add_detail/toJson()
	return json_encode(list(
		"ckey"				= src.ckey,
		"comp_id"			= src.comp_id,
		"ip"				= src.ip
	))
