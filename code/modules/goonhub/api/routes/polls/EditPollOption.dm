/// PUT /polls/option/{pollOption}
/// Update an existing poll option
/datum/apiRoute/polls/options/edit
	method = RUSTG_HTTP_METHOD_PUT
	path = "/polls/option"
	routeParams = list("pollOption") // integer (The poll option ID)
	body = /datum/apiBody/polls/options/edit
	correct_response = /datum/apiModel/PollOptionResource

	buildBody(
		option,
		position
	)
		. = ..(args)
