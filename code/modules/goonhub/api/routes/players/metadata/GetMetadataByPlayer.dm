
/// GET /players/metadata/get-by-player/{ckey}
/// Get all the metadata associated with a ckey
/datum/apiRoute/players/metadata/getbyplayer
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/metadata/get-by-player"
	routeParams = list("ckey") // string
	correct_response = /datum/apiModel/PlayerMetadataArray
