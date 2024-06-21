/// DELETE /polls/option/{pollOption}
/// Delete an existing poll
/datum/apiRoute/polls/options/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/polls/option"
	routeParams = list("pollOption")	// integer (The poll option ID)
	correct_response = 	/datum/apiModel/Message
