
/// GET /random-entries
/// Get a list of random entries by type
/datum/apiRoute/randomEntries
	method = RUSTG_HTTP_METHOD_GET
	path = "/random-entries"
	queryParams = list("type", "count")
	correct_response = /datum/apiModel/RandomEntries
