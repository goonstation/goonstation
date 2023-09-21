/// GET /bans
/// Get
/datum/apiRoute/bans/add
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans"
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource
