
/// POST /players/participation
/// Add a player antagonist for a given round
/datum/apiRoute/PlayerParticipation
	method = RUSTG_HTTP_METHOD_POST
	path = "/players/participation"
	body = /datum/apiBody/PlayerParticipation
	correct_response = /datum/apiModel/Tracked/PlayerRes/PlayerParticipationResource
