/// GET /bans
/// Get
/datum/apiRoute/bans/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string, string, string, string
	correct_response = /datum/apiModel/Tracked/BanResource
