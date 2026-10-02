
/// POST /players/metadata/bulk
/// Add multiple pieces of metadata to a player at once, skipping any they already have
/datum/apiRoute/players/metadata/addbulk
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/metadata/bulk"
	body = /datum/apiBody/players/metadata/addbulk
	correct_response = /datum/apiModel/Message

	buildBody(
		player_id,
		metadata
	)
		. = ..(args)
