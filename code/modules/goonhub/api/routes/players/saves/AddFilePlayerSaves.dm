
/// POST /players/saves/file
/// Add player save
/datum/apiRoute/players/saves/file/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/saves/file"
	body = /datum/apiBody/PlayerSavesAddSave
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerSaveResource

	buildBody(
		player_id,
		ckey,
		name,
		data
	)
		. = ..(args)

