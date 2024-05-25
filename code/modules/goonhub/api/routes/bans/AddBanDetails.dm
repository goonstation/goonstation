/// POST /bans/details/{ban}
/// Add new player details to an existing ban. This should be used when an evasion attempt is detected.
/datum/apiRoute/bans/add_detail
	method = RUSTG_HTTP_METHOD_POST
	path = "/bans/details"
	routeParams = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/add_detail
	correct_response = /datum/apiModel/Tracked/BanDetail

	buildBody(
		game_admin_ckey,
		round_id,
		ckey,
		comp_id,
		ip,
		evasion
	)
		. = ..(args)
