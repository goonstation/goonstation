
/// GET /players/notes
/// List paginated and filtered player notes
/datum/apiRoute/players/notes/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/notes"
	queryParams = list("filters", "sort_by", "descending", "per_page") // string[], string, string, string
	correct_response = /datum/apiModel/Paginated/PlayerNoteResourceList
