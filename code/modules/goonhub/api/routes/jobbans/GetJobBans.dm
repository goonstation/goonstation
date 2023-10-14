/// GET /job-bans
/// List filtered and paginated job bans
/datum/apiRoute/jobbans/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/job-bans"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/Paginated/JobBanResourceList
