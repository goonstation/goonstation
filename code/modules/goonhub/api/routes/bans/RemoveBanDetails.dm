/// DELETE /bans/detail/{banDetail}
/// Add Details
/datum/apiRoute/bans/remove_detail
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/bans/details"
	routeParams = list("banDetail")	// integer (The ban ID)
	correct_response = /datum/apiModel/Message
