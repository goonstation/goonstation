
/// POST /players/participation
/// Add a player participation for a given round
/datum/apiRoute/players/participations
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/participation"
	body = /datum/apiBody/PlayerParticipation
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource
