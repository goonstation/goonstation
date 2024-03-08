/// GET /vpncheck-whitelist/search
/// Check if a player is whitelisted from the VPN checker
/datum/apiRoute/vpnwhitelist/search
	method = RUSTG_HTTP_METHOD_GET
	path = "/vpncheck-whitelist/search"
	queryParams = list("ckey")
	correct_response = /datum/apiModel/VpnWhitelistSearch
