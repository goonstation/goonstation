
/// Vpn Body Response Model Resource Thing
/datum/apiModel/VpnCheckModel
	var/datum/apiModel/VpnCheckResource/data	= null // Model
	var/datum/apiModel/VpnCheckModel/meta/meta	= null // Model, defined below

/datum/apiModel/VpnCheckModel/New(
	data,
	meta
)
	. = ..()
	src.data	= data
	src.meta		= meta

/datum/apiModel/VpnCheckModel/VerifyIntegrity()
	if (
		isnull(src.data) \
		|| isnull(src.meta) \
	)
		return FALSE

/datum/apiModel/VpnCheckModel/ToString()
	. = list()
	.["data"]	= src.data
	.["meta"]		= src.meta
	return json_encode(.)


// metadata for the parent
/datum/apiModel/VpnCheckModel/meta
	var/cached			= FALSE // Bool
	var/whitelisted		= FALSE // Bool

/datum/apiModel/VpnCheckModel/meta/New(
	cached,
	whitelisted
)
	. = ..()
	src.cached			= cached
	src.whitelisted		= whitelisted

/datum/apiModel/VpnCheckModel/meta/VerifyIntegrity()
	if (
		isnull(src.cached) \
		|| isnull(src.whitelisted) \
	)
		return FALSE

/datum/apiModel/VpnCheckModel/meta/ToString()
	. = list()
	.["cached"]				= src.cached
	.["whitelisted"]		= src.whitelisted
	return json_encode(.)

