/// GET /medals/has
/// Determine if a player has a medal
/datum/apiRoute/players/medals/has
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/medals/has"
	routeParams = list("player") // integer|string
	queryParams = list("medal") // string
	correct_response = /datum/apiModel/HasMedalResource
