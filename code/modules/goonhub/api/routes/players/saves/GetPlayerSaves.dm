
/// GET /players/saves
/// List all data and saves for a player
/datum/apiRoute/players/saves/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/saves"
	queryParams = list("player_id", "ckey")
	correct_response = /datum/apiModel/GetPlayerSaves
