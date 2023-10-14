/// GET /job-bans/get-for-player
/// Get all job bans for a given player and server
/datum/apiRoute/jobbans/getforplayer
	method = RUSTG_HTTP_METHOD_GET
	path = "/job-bans/get-for-player"
	queryParams = list("ckey", "server_id") // string, string
	correct_response = /datum/apiModel/JobBansForPlayer
