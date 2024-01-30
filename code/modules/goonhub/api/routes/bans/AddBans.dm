/// POST /bans
/// Add a ban for given player data
/datum/apiRoute/bans/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/bans"
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource

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
