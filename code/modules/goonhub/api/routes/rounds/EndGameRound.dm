
/// PUT /rounds/end/{gameRound}
/// End a game round.
/datum/apiRoute/rounds/end
	method = RUSTG_HTTP_METHOD_PUT
	path = "/rounds/end"
	routeParams = list("gameRound")
	body = /datum/apiBody/rounds/end
	correct_response = /datum/apiModel/Tracked/GameRound

	buildBody(
		crashed
	)
		. = ..(args)
