
/// GET /game-admin-ranks
/// List paginated and filtered game admin ranks
/datum/apiRoute/gameadminranks/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/game-admin-ranks"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/GameAdminResource
