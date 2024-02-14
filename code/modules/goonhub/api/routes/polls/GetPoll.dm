/// GET /polls/{poll}
/// Get a specific poll
/datum/apiRoute/polls/show
	method = RUSTG_HTTP_METHOD_GET
	path = "/polls"
	routeParams = list("poll") // integer (The poll ID)
	correct_response = /datum/apiModel/Tracked/PollResource
