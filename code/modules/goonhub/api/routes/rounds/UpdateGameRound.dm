
/// PUT /rounds/{gameRound}
/// Update a game round. This should be used when game round data we care about is set after the start of the round.
/datum/apiRoute/gameround/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/rounds"
	routeParams = list("gameRound")
	body = list("game_type")
	correct_response = /datum/apiModel/Tracked/GameRound
