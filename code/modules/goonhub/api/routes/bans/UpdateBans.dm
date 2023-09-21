/// PUT /bans/{ban}
/// Update
/datum/apiRoute/bans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/bans/{ban}"
	parameters = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource
