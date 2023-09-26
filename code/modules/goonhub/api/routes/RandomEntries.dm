
/// GET /random-entries
/// Get a list of random entries by type
/datum/apiRoute/randomEntries
	method = RUSTG_HTTP_METHOD_GET
	path = "/random-entries"
	queryParams = list("type", "count")	// not sure if i should put 0 or "count" here.
	correct_response = /datum/apiModel/Tracked/EventTicketResource // this looks correct? best to double check it
