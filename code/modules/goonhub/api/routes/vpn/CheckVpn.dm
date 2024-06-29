/// GET /vpncheck/{ip}
/// Check if a player is using a VPN
/datum/apiRoute/vpn/check
	method = RUSTG_HTTP_METHOD_GET
	path = "/vpncheck"
	routeParams = "ip"
	queryParams = list("ckey", "round_id")
	correct_response = /datum/apiModel/VpnCheckResource
	allow_retry = FALSE
