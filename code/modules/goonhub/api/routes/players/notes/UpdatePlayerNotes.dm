
/// PUT /players/notes
/// Update
/datum/apiRoute/players/notes/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/players/notes"
	parameters = list("note") // integer, the note ID
	body = /datum/apiBody/players/notes/update
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerNoteResource
