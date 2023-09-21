/// POST /bans/details/{ban}
/// Add Details
/datum/apiRoute/bans/add_detail
	method = RUSTG_HTTP_METHOD_POST
	path = "/bans/details/{ban}"
	parameters = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/add_detail
	correct_response = /datum/apiModel/Tracked/BanResource
