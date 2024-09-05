
/// PUT /game-admin-ranks/{gameAdminRank}
/// Update an existing game admin
/datum/apiRoute/gameadminranks/put
	method = RUSTG_HTTP_METHOD_PUT
	path = "/game-admin-ranks"
	body = list("rank")
	routeParams = list("gameAdminRank") // integer
	correct_response = /datum/apiModel/GameAdminResource
