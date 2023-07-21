
/// PlayerResource
/datum/apiModel/PlayerResource
	var/id				= null // integer
	var/ckey			= null // string
	var/key				= null // string
	var/byond_join_date	= null // string
	var/byond_major		= null // integer
	var/byond_minor		= null // integer
	var/created_at		= null // date-time
	var/updated_at		= null // date-time

/datum/apiModel/PlayerResource/New(
	id,
	ckey,
	key,
	byond_join_date,
	byond_major,
	byond_minor,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.ckey = ckey
	src.key = key
	src.byond_join_date = byond_join_date
	src.byond_major = byond_major
	src.byond_minor = byond_minor
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/PlayerResource/VerifyIntegrity()
	if (
		isnull(src.id)
		|| isnull(src.ckey)
		|| isnull(src.key)
		|| isnull(src.byond_join_date)
		|| isnull(src.byond_major)
		|| isnull(src.byond_minor)
		|| isnull(src.created_at)
		|| isnull(src.updated_at)
	)
		return FALSE

/datum/apiModel/PlayerResource/ToString()
	. = list()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["key"] = src.key
	.["byond_join_date"] = src.byond_join_date
	.["byond_major"] = src.byond_major
	.["byond_minor"] = src.byond_minor
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
