
/// PlayerConnection
/datum/apiModel/PlayerRes/PlayerConnection
var/round_id			= null // integer
var/ip					= null // string
var/comp_id				= null // string
var/list/legacy_data	= null // [string]
var/country				= null // string
var/country_iso			= null // string


/datum/apiModel/PlayerRes/PlayerConnection/New(
	id,
	player_id,
	round_id,
	ip,
	comp_id,
	legacy_data,
	created_at,
	updated_at,
	country,
	country_iso
)
	. = ..()
	src.id = id
	src.player_id = player_id
	src.round_id = round_id
	src.ip = ip
	src.comp_id = comp_id
	src.legacy_data = legacy_data
	src.created_at = created_at
	src.updated_at = updated_at
	src.country = country
	src.country_iso = country_iso

/datum/apiModel/PlayerRes/PlayerConnection/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(src.player_id)
		|| isnull(src.round_id)
		|| isnull(src.ip)
		|| isnull(src.comp_id)
		|| isnull(src.legacy_data)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
		|| isnull(src.country)
		|| isnull(src.country_iso)
	)
		return FALSE

/datum/apiModel/PlayerRes/PlayerConnection/ToString()
	. = list()
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
	return json_encode(.)
