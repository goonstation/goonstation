
/// DELETE /players/notes
/// Delete list
/datum/apiRoute/players/notes/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/notes"
	routeParams = list("note") // integer, the note ID
	correct_response = "string"
