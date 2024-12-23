
/// GET /game-admins
/// List paginated and filtered game admins
/datum/apiRoute/gameadmins/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/game-admins"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/GameAdminResource
