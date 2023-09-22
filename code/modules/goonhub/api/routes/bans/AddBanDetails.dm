/// POST /bans/details/{ban}
/// Add new player details to an existing ban. This should be used when an evasion attempt is detected.
/datum/apiRoute/bans/add_detail
	method = RUSTG_HTTP_METHOD_POST
	path = "/bans/details/{ban}"
	parameters = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/add_detail
	correct_response = /datum/apiModel/Tracked/BanResource
