
/// GET /players/metadata/get-by-data/{metadata}
/// Get all the ckeys associated with a piece of metadata
/datum/apiRoute/players/metadata/getbydata
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/metadata/get-by-data"
	routeParams = list("metadata") // string
	correct_response = /datum/apiModel/PlayerMetadataArray
