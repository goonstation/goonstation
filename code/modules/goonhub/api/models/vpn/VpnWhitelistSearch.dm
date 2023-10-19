
/// VpnWhitelistSearch
/datum/apiModel/VpnWhitelistSearch
	var/whitelisted = null // boolean

/datum/apiModel/VpnWhitelistSearch/SetupFromResponse(response)
	. = ..()
	src.whitelisted = response["whitelisted"]

/datum/apiModel/VpnWhitelistSearch/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.whitelisted) \
	)
		return FALSE

/datum/apiModel/VpnWhitelistSearch/ToString()
	. = list()
	.["whitelisted"] = src.whitelisted
	return json_encode(.)
