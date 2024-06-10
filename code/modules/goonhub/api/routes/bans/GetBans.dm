/// GET /bans
/// Get
/datum/apiRoute/bans/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans"
	queryParams = list("filters", "sort_by", "descending", "page", "per_page") // object, string, string, int, int
	correct_response = /datum/apiModel/Paginated/BanResourceList
