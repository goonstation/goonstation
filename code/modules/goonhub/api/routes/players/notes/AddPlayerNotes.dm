
/// POST /players/notes
/// Add a new player note
/datum/apiRoute/players/notes/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/notes"
	body = /datum/apiBody/players/notes/post
	correct_response = /datum/apiModel/Tracked/PlayerNoteResource

	buildBody(
		game_admin_ckey,
		round_id,
		server_id,
		ckey,
		note
	)
		. = ..(args)
