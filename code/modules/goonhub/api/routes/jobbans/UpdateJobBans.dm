/// PUT /job-bans/{jobBan}
/// Update an existing job ban
/datum/apiRoute/jobbans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/job-bans"
	routeParams = list("jobBan")	// integer
	body = /datum/apiBody/jobbans/update
	correct_response = /datum/apiModel/Tracked/JobBanResource

	buildBody(
		server_id,
		job,
		reason,
		duration
	)
		. = ..(args)
