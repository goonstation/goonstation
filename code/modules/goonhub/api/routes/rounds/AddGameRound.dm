
/// POST /rounds
/// Start a new game round
/datum/apiRoute/rounds/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/rounds"
	body = /datum/apiBody/rounds/post
	correct_response = /datum/apiModel/Tracked/GameRound

	buildBody(
		map,
		server_id,
		rp_mode,
		test_merges
	)
		. = ..(args)
