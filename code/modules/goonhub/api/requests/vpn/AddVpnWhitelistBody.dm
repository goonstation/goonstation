
/datum/apiBody/vpnwhitelist/add
	fields = list(
		"game_admin_ckey", // string
		"ckey", // string
	)

/datum/apiBody/vpnwhitelist/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["ckey"]) \
	)
		return FALSE
