
/// VpnCheckResource
/datum/apiModel/VpnCheckResource
	var/id 				= null // integer
	var/round_id	= null // integer
	var/ip			= null // integer
	var/service		= null // string
	var/response	= null // string
	var/error		= null // string
	var/created_at	= null // date-time
	var/updated_at	= null // date-time

/datum/apiModel/VpnCheckResource/New(
	id,
	round_id,
	ip,
	service,
	response,
	error,
	created_at,
	updated_at
)
	. = ..()
	src.id = id
	src.round_id = round_id
	src.ip = ip
	src.service = service
	src.response = response
	src.error = error
	src.created_at = created_at
	src.updated_at = updated_at

/datum/apiModel/VpnCheckResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(round_id) \
		|| isnull(ip) \
		|| isnull(service) \
		|| isnull(response) \
		|| isnull(error) \
		|| isnull(created_at) \
		|| isnull(updated_at) \
	)
		return FALSE

/datum/apiModel/VpnCheckResource/ToString()
	. = list()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["ip"] = src.ip
	.["service"] = src.service
	.["response"] = src.response
	.["error"] = src.error
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	return json_encode(.)
