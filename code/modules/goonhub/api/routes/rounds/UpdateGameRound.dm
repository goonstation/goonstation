
/// PUT /rounds/{gameRound}
/// Update a game round. This should be used when game round data we care about is set after the start of the round.
/datum/apiRoute/rounds/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/rounds"
	routeParams = list("gameRound")
	body = /datum/apiBody/rounds/update
	correct_response = /datum/apiModel/Tracked/GameRound

	buildBody(
		game_type
	)
		. = ..(args)
