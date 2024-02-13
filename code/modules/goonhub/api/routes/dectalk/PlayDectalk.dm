/// POST /dectalk/play
/// Generate an audio file speaking the text provided.
/datum/apiRoute/dectalk/play
	method = RUSTG_HTTP_METHOD_POST
	path = "/dectalk/play"
	body = /datum/apiBody/dectalk/play
	correct_response = /datum/apiModel/DectalkPlayResource

	buildBody(
		text,
		round_id
	)
		. = ..(args)
