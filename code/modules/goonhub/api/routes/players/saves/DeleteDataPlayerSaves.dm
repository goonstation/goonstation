
/// DELETE /players/saves/data
/// Delete data for a player
/datum/apiRoute/players/saves/data/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/saves/data"
	body = /datum/apiBody/PlayerSavesDeleteData
	correct_response = /datum/apiModel/Message

	buildBody(
		player_id,
		ckey,
		key
	)
		. = ..(args)
