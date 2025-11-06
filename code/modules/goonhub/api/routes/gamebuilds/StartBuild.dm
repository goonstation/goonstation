
/// POST /game-builds/build
/// Trigger a build for a given server
/datum/apiRoute/gamebuilds/build
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-builds/build"
	body = /datum/apiBody/gamebuilds/build
	correct_response = /datum/apiModel/Message

	buildBody(
		game_admin_ckey,
		server_id,
		round_id,
		map,
		votes
	)
		. = ..(args)
