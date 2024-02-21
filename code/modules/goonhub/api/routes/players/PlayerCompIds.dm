
/// GET /players/get-compids
/// Get a list of computed IDs associated with a player ckey, along with how many times they connected with each computer ID
/datum/apiRoute/players/compids/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/get-compids"
	queryParams = list("ckey") // string
	correct_response = /datum/apiModel/PlayerCompIdsResource
