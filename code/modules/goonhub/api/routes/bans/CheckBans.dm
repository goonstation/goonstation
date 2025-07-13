/// GET /bans/check
/// Check
/datum/apiRoute/bans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans/check"
	queryParams = list("ckey", "comp_id", "ip", "server_id") // string, string, string, string
	correct_response = /datum/apiModel/Tracked/BanResource
