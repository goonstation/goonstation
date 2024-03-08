
/// ADD /players/metadata
/// Add player metadata
/datum/apiRoute/players/metadata/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/metadata"
	body = /datum/apiBody/players/metadata
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerMetadataResource

	buildBody(
		player_id,
		metadata
	)
		. = ..(args)
