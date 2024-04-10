/// DELETE /bans/{ban}
/// Delete
/datum/apiRoute/bans/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/bans"
	routeParams = list("ban")	// integer (The ban ID)
	body = /datum/apiBody/bans/delete
	correct_response = 	/datum/apiModel/Message

	buildBody(
		game_admin_ckey
	)
		. = ..(args)
