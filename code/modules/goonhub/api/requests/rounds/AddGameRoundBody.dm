
/datum/apiBody/rounds/post
	var/map			= "string"
	var/server_id	= "string"
	var/rp_mode		= FALSE

/datum/apiBody/rounds/post/New(
	map,
	server_id,
	rp_mode
)
	. = ..()
	src.map = map
	src.server_id = server_id
	src.rp_mode = rp_mode

/datum/apiBody/rounds/post/VerifyIntegrity()
	if (
		isnull(src.map) \
		|| isnull(src.server_id) \
		|| isnull(src.rp_mode) \
	)
		return FALSE

/datum/apiBody/rounds/post/toJson()
	return json_encode(list(
		"map"		= src.map,
		"server_id"	= src.server_id,
		"rp_mode"	= src.rp_mode
	))
