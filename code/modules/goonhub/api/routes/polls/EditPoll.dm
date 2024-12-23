/// PUT /polls/{poll}
/// Edit an existing poll
/datum/apiRoute/polls/edit
	method = RUSTG_HTTP_METHOD_PUT
	path = "/polls"
	routeParams = list("poll") // integer (The poll ID)
	body = /datum/apiBody/polls/edit
	correct_response = /datum/apiModel/Tracked/PollResource

	buildBody(
		question,
		expires_at,
		servers
	)
		. = ..(args)
