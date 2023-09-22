
/// POST /game-admins
/// Add a new game admin
/datum/apiRoute/admins/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-admins"
	body = /datum/apiBody/admins/post
	correct_response = /datum/apiModel/Tracked/GameAdminResource
