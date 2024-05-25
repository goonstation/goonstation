/// GET /gauntlets/get-previous
/// Retrieve a count of how many gauntlets a given key has completed
/datum/apiRoute/gauntlet/getprevious
	method = RUSTG_HTTP_METHOD_GET
	path = "/gauntlet/get-previous"
	queryParams = list("key") // string
	correct_response = /datum/apiModel/PreviousGauntlets
