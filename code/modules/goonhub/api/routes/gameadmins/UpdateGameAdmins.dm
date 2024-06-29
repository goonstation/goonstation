
/// PUT /game-admins/{gameAdmin}
/// Update an existing game admin
/datum/apiRoute/gameadmins/put
	method = RUSTG_HTTP_METHOD_PUT
	path = "/game-admins"
	body = /datum/apiBody/gameadmins/put
	routeParams = list("gameAdmin") // integer
	correct_response = /datum/apiModel/GameAdminResource
