
/// GET /players/notes
/// Get list
/datum/apiRoute/players/notes/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/notes"
	parameters = list("filters", "sort_by", "descending", "per_page") // string, string, string, string
	correct_response = "string"
