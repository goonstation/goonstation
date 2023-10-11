
/// DELETE /players/metadata/clear-by-data/{data}
/// Delete a specific item of metadata
/datum/apiRoute/players/metadata/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/metadata/clear-by-data"
	routeParams = list("data")
	correct_response = /datum/apiModel/Message
