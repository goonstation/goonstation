
/// POST /maps/generate
/// Dispatches a job to process map screenshots and upload them to the web map viewer.
/// The uploaded zip file should contain images taken with the ingame Map-World verb.
/// For a regular 300x300 map, this should be 100 images.
/// The names of individual image files should remain as what the Map-World verb names them.
/// This route is intended for out-of-game usage only.
/datum/apiRoute/maps
	method = RUSTG_HTTP_METHOD_POST
	path = "/maps/generate"
	body = /datum/apiBody/maps/generate
	correct_response = "message"
