
/// PUT /players/notes/{note}
/// Update
/datum/apiRoute/players/notes/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/players/notes"
	routeParams = list("note") // integer, the note ID
	body = /datum/apiBody/players/notes/update
	correct_response = /datum/apiModel/Tracked/PlayerNoteResource
