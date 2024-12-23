
/// GET /medals
/// List paginated and filtered player medals
/datum/apiRoute/players/medals/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/medals"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/Paginated/PlayerMedalResourceList
