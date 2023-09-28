/// POST /job-bans
/// Add a new job ban
/datum/apiRoute/jobbans/get
	method = RUSTG_HTTP_METHOD_POST
	path = "/job-bans"
	body = /datum/apiBody/jobbans/add
	correct_response = /datum/apiModel/Tracked/JobBanResource
