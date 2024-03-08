
/// GET /numbers-station
/// Get the current numbers representing the password for the numbers station terminal
/datum/apiRoute/numbersstation/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/numbers-station"
	correct_response = /datum/apiModel/NumbersStationPasswordResource
