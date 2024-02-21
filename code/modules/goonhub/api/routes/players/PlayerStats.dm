
/// GET /players/stats
/// Get various statistics associated with a player
/datum/apiRoute/players/stats/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/stats"
	queryParams = list("ckey") // string
	correct_response = /datum/apiModel/Tracked/PlayerStatsResource
