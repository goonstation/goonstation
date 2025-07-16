/// GET /bans/check
/// Check
/datum/apiRoute/bans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans/check"
	queryParams = list("ckey", "comp_id", "ip", "server_id", "player_id") // string, string, string, string, integer
	correct_response = /datum/apiModel/Tracked/BanResource
