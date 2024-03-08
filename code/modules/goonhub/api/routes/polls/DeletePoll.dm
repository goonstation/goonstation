/// DELETE /polls/{poll}
/// Delete an existing poll
/datum/apiRoute/polls/delete
	method = RUSTG_HTTP_METHOD_DELETE
	path = "/polls"
	routeParams = list("poll")	// integer (The poll ID)
	correct_response = 	/datum/apiModel/Message
