
/// BanDetail
/datum/apiModel/BanDetail
	var/ban_id		= null // integer
	var/ckey		= null // string
	var/comp_id		= null // integer
	var/ip			= null // integer
	var/created_at	= null // date-time
	var/updated_at	= null // date-time
	var/deleted_at	= null // date-time

/datum/apiModel/BanDetail/New(
	id,
	ban_id,
	ckey,
	comp_id,
	ip,
	created_at,
	updated_at,
	deleted_at
)
	. = ..()
	src.id = id
	src.ban_id = ban_id
	src.ckey = ckey
	src.comp_id = comp_id
	src.ip = ip
	src.created_at = created_at
	src.updated_at = updated_at
	src.deleted_at = deleted_at

/datum/apiModel/BanDetail/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(src.ban_id)
		|| isnull(src.ckey)
		|| isnull(src.comp_id)
		|| isnull(src.ip)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
		|| isnull(src.deleted_at)
	)
		return FALSE

/datum/apiModel/BanDetail/ToString()
	. = list()
	.["id"] = src.id
	.["ban_id"] = src.ban_id
	.["ckey"] = src.ckey
	.["comp_id"] = src.comp_id
	.["ip"] = src.ip
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["deleted_at"] = src.deleted_at
	return json_encode(.)
