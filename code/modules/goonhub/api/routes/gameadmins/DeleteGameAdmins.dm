
/// DELETE /game-admins/{gameAdmin}
/// Delete an existing game admin
/datum/apiRoute/gameadmins/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/game-admins"
	routeParams = list("gameAdmin") // integer
	correct_response = /datum/apiModel/Message
