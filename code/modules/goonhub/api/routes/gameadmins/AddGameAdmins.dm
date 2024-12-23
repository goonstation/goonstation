
/// POST /game-admins
/// Add a new game admin
/datum/apiRoute/gameadmins/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-admins"
	body = /datum/apiBody/gameadmins/post
	correct_response = /datum/apiModel/GameAdminResource
