/// PUT /bans/{ban}
/// Update
/datum/apiRoute/bans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/bans"
	routeParams = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/Ban

	buildBody(
		game_admin_ckey,
		round_id,
		server_id,
		ckey,
		comp_id,
		ip,
		reason,
		duration,
		requires_appeal
	)
		. = ..(args)
