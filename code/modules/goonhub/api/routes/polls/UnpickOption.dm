/// POST /polls/option/unpick/{pollOption}
/// Register that a player removed their pick of a poll option
/datum/apiRoute/polls/options/unpick
	method = RUSTG_HTTP_METHOD_POST
	path = "/polls/option/unpick"
	routeParams = list("pollOption") // integer (The poll option ID)
	body = /datum/apiBody/polls/options/pickUnpick
	correct_response = /datum/apiModel/Message

	buildBody(
		player_id
	)
		. = ..(args)
