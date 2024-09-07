
/// GET /test
/// Test route for debugging
/datum/apiRoute/test
	method = RUSTG_HTTP_METHOD_GET
	path = "/test"
	correct_response = /datum/apiModel/Message
