
/// POST /players/participation
/// Add a player participation for a given round
/datum/apiRoute/players/participationsBulk
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/participations/bulk"
	body = /datum/apiBody/PlayerParticipationBulk
	correct_response = /datum/apiModel/Message

	buildBody(players, round_id)
		. = ..(args)
