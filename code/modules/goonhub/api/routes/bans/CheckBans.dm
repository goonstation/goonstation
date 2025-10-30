/// GET /bans/check
/// Check
/datum/apiRoute/bans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans/check"
	queryParams = list("ckey", "comp_id", "ip", "player_id") // string, string, string, integer
	correct_response = /datum/apiModel/Tracked/Ban
