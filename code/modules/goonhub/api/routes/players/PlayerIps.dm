
/// GET /players/get-ips
/// Get a list of IPs associated with a player ckey, along with how many times they connected with each IP
/datum/apiRoute/players/ips/get
	method = RUSTG_HTTP_METHOD_GET
	path = "/players/get-ips"
	queryParams = list("ckey") // string
	correct_response = /datum/apiModel/PlayerIpsResource
