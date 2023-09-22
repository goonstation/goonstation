
/// POST /maps/generate
/// Dispatches a job to process map screenshots and upload them to the web map viewer
/datum/apiRoute/maps
	method = RUSTG_HTTP_METHOD_POST
	path = "/maps/generate"
	body = /datum/apiBody/maps/generate
	correct_response = "message"
