/// DELETE /bans/{ban}
/// Delete
/datum/apiRoute/bans/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/bans/{ban}"
	parameters = list("ban")	// integer (The ban ID)
	correct_response = list("message")
