/// POST /vpncheck-whitelist
/// Add a player into the whitelist. This will allow them to skip VPN checks.
/datum/apiRoute/vpnwhitelist/add
	method = RUSTG_HTTP_METHOD_POST
	path = "/vpncheck-whitelist"
	body = /datum/apiBody/vpnwhitelist/add
	correct_response = /datum/apiModel/Tracked/VpnWhitelistResource

	buildBody(
		game_admin_ckey,
		ckey
	)
		. = ..(args)
