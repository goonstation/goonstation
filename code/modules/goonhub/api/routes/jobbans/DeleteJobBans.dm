/// DELETE /job-bans/{jobBan}
/// Delete an existing job ban
/datum/apiRoute/jobbans/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/job-bans"
	routeParams = list("jobBan")	// integer
	correct_response = "message"	// string
