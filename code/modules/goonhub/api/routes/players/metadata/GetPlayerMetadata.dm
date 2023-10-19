
/// GET /players/metadata
/// List paginated and filtered player metadata
/datum/apiRoute/players/metadata/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/metadata"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/Paginated/PlayerMetadataList
