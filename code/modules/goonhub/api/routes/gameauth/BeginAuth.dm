
/// POST /game-auth/begin
/// Begin an authentication session
/datum/apiRoute/gameauth/begin
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-auth/begin"
	body = /datum/apiBody/gameauth/begin
	correct_response = /datum/apiModel/BeginAuthResource

	buildBody(
		server_id,
		ckey
	)
		. = ..(args)
