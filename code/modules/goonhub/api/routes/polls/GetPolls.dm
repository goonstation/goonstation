/// GET /polls
/// List paginated and filtered polls
/datum/apiRoute/polls/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/polls"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string, string, string, string
	correct_response = /datum/apiModel/Paginated/PollResourceList
