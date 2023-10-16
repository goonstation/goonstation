
/// DELETE /players/metadata/clear-by-data/{metadata}
/// Delete a specific item of metadata
/datum/apiRoute/players/metadata/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/metadata/clear-by-data"
	routeParams = list("metadata")
	correct_response = /datum/apiModel/Message
