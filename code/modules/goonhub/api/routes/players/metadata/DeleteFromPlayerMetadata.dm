
/// DELETE /players/metadata/clear-by-data/{ckey}
/// Delete all metadata associated with a specific player
/datum/apiRoute/players/metadata/delete/fromplayer
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/metadata/clear-by-data"
	routeParams = list("ckey")
	correct_response = /datum/apiModel/Message
