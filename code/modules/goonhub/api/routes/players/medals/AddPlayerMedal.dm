/// POST /medals
/// Add a medal for a player
/datum/apiRoute/players/medals/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/medals"
	body = /datum/apiBody/players/medals/add
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerMedalResource

	buildBody(
		player_id,
		ckey,
		medal,
		round_id
	)
		. = ..(args)
