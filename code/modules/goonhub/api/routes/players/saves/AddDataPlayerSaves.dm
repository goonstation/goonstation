
/// POST /players/saves/data
/// Add player data
/datum/apiRoute/players/saves/data/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/saves/data"
	body = /datum/apiBody/PlayerSavesAddData
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerDataResource

	buildBody(
		player_id,
		ckey,
		key,
		value
	)
		. = ..(args)
