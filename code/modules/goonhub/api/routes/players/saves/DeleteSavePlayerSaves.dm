
/// DELETE /players/saves/file/{playerSave}
/// Delete a save for a player
/datum/apiRoute/players/saves/file/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/saves/file"
	body = /datum/apiBody/PlayerSavesDeleteSave
	correct_response = /datum/apiModel/Message

	buildBody(
		player_id,
		ckey,
		name
	)
		. = ..(args)
