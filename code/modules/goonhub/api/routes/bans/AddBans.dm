/// POST /bans
/// Add a ban for given player data
/datum/apiRoute/bans/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/bans"
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource
