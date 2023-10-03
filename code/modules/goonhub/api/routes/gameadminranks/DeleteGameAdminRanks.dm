
/// DELETE /game-admin-ranks/{gameAdmin}
/// Delete an existing game admin
/datum/apiRoute/gameadminranks/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/game-admin-ranks"
	routeParams = list("gameAdminRank") // integer
	correct_response = "string"
