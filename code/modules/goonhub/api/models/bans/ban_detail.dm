
/// BanDetail
/datum/apiModel/banDetail
	var/id			= null
	var/ban_id		= null
	var/ckey		= null
	var/comp_id		= null
	var/ip			= null
	var/created_at	= null
	var/updated_at	= null
	var/deleted_at	= null

/datum/apiModel/banDetail/New(
	id = null,
	ban_id = null,
	ckey = null,
	comp_id = null,
	ip = null,
	created_at = null,
	updated_at = null,
	deleted_at = null
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

/datum/apiModel/banDetail/ToString()
	. = list()
	. += "  id: [src.id]"
	. += "  ban_id: [src.ban_id]"
	. += "  ckey: [src.ckey]"
	. += "  comp_id: [src.comp_id]"
	. += "  ip: [src.ip]"
	. += "  created_at: [src.created_at]"
	. += "  updated_at: [src.updated_at]"
	. += "  deleted_at: [src.deleted_at]"
	. = jointext(., "\n")
