/// POST /polls
/// Add a new poll
/datum/apiRoute/polls/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/polls"
	body = /datum/apiBody/polls/add
	correct_response = /datum/apiModel/Tracked/PollResource

	buildBody(
		game_admin_ckey,
		question,
		multiple_choice,
		expires_at,
		options,
		servers
	)
		. = ..(args)
