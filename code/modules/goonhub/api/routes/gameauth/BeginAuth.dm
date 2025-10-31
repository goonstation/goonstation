
/// POST /game-auth/begin
/// Begin an authentication session
/datum/apiRoute/gameauth/begin
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-auth/begin"
	body = /datum/apiBody/gameauth/begin
	correct_response = /datum/apiModel/BeginAuthResource

	buildBody(
		timeout,
		server_id,
		ckey,
		key,
		ip,
		comp_id,
		byond_major,
		byond_minor,
		round_id
	)
		. = ..(args)
