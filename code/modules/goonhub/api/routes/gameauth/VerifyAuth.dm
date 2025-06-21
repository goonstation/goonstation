
/// POST /game-auth/verify
/// Verify a session
/datum/apiRoute/gameauth/verify
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-auth/verify"
	body = /datum/apiBody/gameauth/verify
	correct_response = /datum/apiModel/VerifyAuthResource

	buildBody(
		session,
		server_id,
		ip,
		comp_id,
		byond_major,
		byond_minor,
		round_id
	)
		. = ..(args)
