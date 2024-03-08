/// POST /polls/option/pick/{pollOption}
/// Register that a player picked a poll option
/datum/apiRoute/polls/options/pick
	method = RUSTG_HTTP_METHOD_POST
	path = "/polls/option/pick"
	routeParams = list("pollOption") // integer (The poll option ID)
	body = /datum/apiBody/polls/options/pickUnpick
	correct_response = /datum/apiModel/Tracked/PollAnswerResource

	buildBody(
		player_id
	)
		. = ..(args)
