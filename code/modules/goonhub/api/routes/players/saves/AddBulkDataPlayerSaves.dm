
/// POST /players/saves/data-bulk
/// Add multiple entries of player data
/datum/apiRoute/players/saves/databulk/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/saves/data-bulk"
	body = /datum/apiBody/PlayerSavesBulkData
	correct_response = /datum/apiModel/Message

	buildBody(
		data
	)
		. = ..(args)
