
/// PUT /rounds/end/{gameRound}
/// End a game round.
/datum/apiRoute/gameround/end
	method = RUSTG_HTTP_METHOD_PUT
	path = "/rounds/end"
	routeParams = list("gameRound")
	body = list("crashed")
	correct_response = /datum/apiModel/Tracked/GameRound
