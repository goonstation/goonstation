/// DELETE /vpncheck-whitelist
/// Delete a whitelist entry
/datum/apiRoute/vpnwhitelist/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/vpncheck-whitelist"
	queryParams = list("ckey")	// string
	correct_response = /datum/apiModel/Message
