
/// PlayerSearchResource
/datum/apiModel/PlayerSearchResource
	var/id = null // int
	var/ip			= null 	// string
	var/comp_id		= null 	// string
	var/player_id	= null 	// string
	var/ckey		= null 	// string
	var/created_at	= null 	// string

// ZEWAKA TODO: WTF NO UPDATED_AT????


/datum/apiModel/PlayerSearchResource/New(
	id,
	ip,
	comp_id,
	player_id,
	ckey,
	created_at
)
	. = ..()
	src.id = id
	src.ip = ip
	src.comp_id = comp_id
	src.player_id = player_id
	src.ckey = ckey
	src.created_at = created_at

/datum/apiModel/PlayerSearchResource/VerifyIntegrity()
	if (
		isnull(id) \
		|| isnull(src.ip) \
		|| isnull(src.comp_id) \
		|| isnull(src.player_id) \
		|| isnull(src.ckey) \
		|| isnull(src.created_at) \
	)
		return FALSE

/datum/apiModel/PlayerSearchResource/ToList()
	. = ..()
	.["id"] = src.id
	.["ip"] = src.ip
	.["comp_id"] = src.comp_id
	.["player_id"] = src.player_id
	.["ckey"] = src.ckey
	.["created_at"] = src.created_at
