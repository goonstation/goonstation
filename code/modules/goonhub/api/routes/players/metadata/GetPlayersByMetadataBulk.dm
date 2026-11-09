
/// POST /players/metadata/get-by-data-bulk
/// Get the ckeys associated with multiple pieces of metadata at once, up to `limit` per piece, with a total for each
/datum/apiRoute/players/metadata/getbydatabulk
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/metadata/get-by-data-bulk"
	body = /datum/apiBody/players/metadata/bulk
	correct_response = /datum/apiModel/PlayerMetadataBulk

	buildBody(
		metadata,
		limit
	)
		. = ..(args)
