/// GET /bans
/// Get
/datum/apiRoute/bans/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/bans"
	parameters = list("filters", "sort_by", "descending", "per_page") // string, string, string, string
	correct_response = /datum/apiModel/Tracked/BanResource
