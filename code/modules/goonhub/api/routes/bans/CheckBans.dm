/// GET /bans/check
/// Check
/datum/apiRoute/bans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans/check"
	body = /datum/apiBody/bans/check
	correct_response = /datum/apiModel/Tracked/BanResource
