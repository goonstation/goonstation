
/// POST /players/playtime/bulk
/// Record playtime for a list of players
/datum/apiRoute/players/playtime
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/playtime/bulk"
	body = /datum/apiBody/players/playtime
	correct_response = /datum/apiModel/Message

	buildBody(
		serverId,
		players
	)
		. = ..(args)
