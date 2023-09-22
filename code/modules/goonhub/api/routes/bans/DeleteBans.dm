/// DELETE /bans/{ban}
/// Delete
/datum/apiRoute/bans/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/bans/{ban}"
	routeParams = list("ban")	// integer (The ban ID)
	correct_response = list("message")
