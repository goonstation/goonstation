
/// POST /players/notes
/// Add
/datum/apiRoute/players/notes/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/notes"
	body = /datum/apiBody/players/notes/post
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerNoteResource
