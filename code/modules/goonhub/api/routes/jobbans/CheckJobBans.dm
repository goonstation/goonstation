/// GET /job-bans/check
/// Check if a job ban exists for given player and server details
/datum/apiRoute/jobbans/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/job-bans/check"
	queryParams = list("ckey", "job", "server_id") // string, string, string
	correct_response = /datum/apiModel/Tracked/JobBanResource
