/// POST /medals/transfer
/// Transfer medals from one player to another
/datum/apiRoute/players/medals/transfer
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/medals/transfer"
	body = /datum/apiBody/players/medals/transfer
	correct_response = /datum/apiModel/Message

	buildBody(
		source_ckey,
		target_ckey
	)
		. = ..(args)
