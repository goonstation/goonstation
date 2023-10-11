
/// DELETE /players/saves/file/{playerSave}
/// Delete a save for a player
/datum/apiRoute/players/saves/file/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/saves/file"
	routeParams = list("playerSave")
	correct_response = /datum/apiModel/Message
