
/// POST /game-admin-ranks
/// Add a new game admin rank
/datum/apiRoute/gameadminrank/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/game-admin-ranks"
	body = list("rank")
	correct_response = /datum/apiModel/Tracked/GameAdminRank
