/// POST /players
/// Register a login for a player with associated details
/datum/apiRoute/players/login
	method = RUSTG_HTTP_METHOD_POST
	path = "/players"
	body = /datum/apiBody/players/login
	correct_response = /datum/apiModel/Tracked/PlayerResource

	buildBody(
		ckey,
		key,
		ip,
		comp_id,
		byond_major,
		byond_minor,
		round_id
	)
		. = ..(args)
