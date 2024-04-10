/// DELETE /job-bans/{jobBan}
/// Delete an existing job ban
/datum/apiRoute/jobbans/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/job-bans"
	body = /datum/apiBody/jobbans/delete
	correct_response = /datum/apiModel/Message

	buildBody(
		game_admin_ckey,
		server_id,
		ckey,
		job
	)
		. = ..(args)
