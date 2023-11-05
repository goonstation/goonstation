/// GET /medals
/// Show a medal for a player
/datum/apiRoute/players/medals/show
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/medals"
	routeParams = list("player_id") // integer
	queryParams = list("medal") // string
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerMedalResource
