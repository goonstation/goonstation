/// POST /polls/option/{poll}
/// Add a new option to an existing poll
/datum/apiRoute/polls/options/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/polls/option"
	routeParams = list("poll") // integer (The poll ID)
	body = /datum/apiBody/polls/options/add
	correct_response = /datum/apiModel/PollOptionResource

	buildBody(
		option
	)
		. = ..(args)
