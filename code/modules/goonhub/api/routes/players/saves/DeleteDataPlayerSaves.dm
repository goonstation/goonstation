
/// DELETE /players/saves/data/{playerData}
/// Delete data for a player
/datum/apiRoute/players/saves/data/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/saves/data"
	routeParams = list("playerData")
	correct_response = /datum/apiModel/Message
