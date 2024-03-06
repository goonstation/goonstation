
/// PlayerConnection
/datum/apiModel/Tracked/PlayerRes/PlayerConnection
	var/round_id			= null // integer
	var/ip					= null // string
	var/comp_id				= null // string
	var/list/legacy_data	= null // [string]
	var/country				= null // string
	var/country_iso			= null // string

/datum/apiModel/Tracked/PlayerRes/PlayerConnection/SetupFromResponse(response)
	. = ..()
	src.round_id = response["round_id"]
	src.ip = response["ip"]
	src.comp_id = response["comp_id"]
	src.legacy_data = response["legacy_data"]
	src.country = response["country"]
	src.country_iso = response["country_iso"]

/datum/apiModel/Tracked/PlayerRes/PlayerConnection/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.player_id) \
		|| isnull(src.round_id) \
		|| isnull(src.ip) \
		|| isnull(src.comp_id) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerRes/PlayerConnection/ToList()
	. = ..()
	.["id"] = src.id
	.["player_id"] = src.player_id
	.["round_id"] = src.round_id
	.["ip"] = src.ip
	.["comp_id"] = src.comp_id
	.["legacy_data"] = src.legacy_data
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["country"] = src.country
	.["country_iso"] = src.country_iso
