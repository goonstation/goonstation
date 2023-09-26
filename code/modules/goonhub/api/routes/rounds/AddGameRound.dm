
/// POST /rounds
/// Start a new game round
/datum/apiRoute/gameround/post
	method = RUSTG_HTTP_METHOD_POST
	path = "/rounds"
	body = /datum/apiBody/gameround/post
	correct_response = /datum/apiModel/Tracked/GameRound
