
/// PUT /game-admins/{gameAdmin}
/// Update an existing game admin
/datum/apiRoute/admins/put
	method = RUSTG_HTTP_METHOD_PUT
	path = "/game-admins"
	body = /datum/apiBody/admins/put
	routeParams = list("gameAdmin") // integer
	correct_response = /datum/apiModel/Tracked/GameAdminResource
