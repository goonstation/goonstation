
/// DELETE /medals
/// Delete medal for a player
/datum/apiRoute/players/medals/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/players/medals"
	body = /datum/apiBody/players/medals/delete
	correct_response = /datum/apiModel/Message

	buildBody(
		player_id,
		ckey,
		medal
	)
		. = ..(args)
