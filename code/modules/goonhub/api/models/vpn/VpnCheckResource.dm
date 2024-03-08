
/// VpnCheckResource
/datum/apiModel/VpnCheckResource
	var/id			= null // integer
	var/round_id	= null // integer
	var/ip			= null // integer
	var/service		= null // string
	var/response	= null // string
	var/error		= null // string
	var/list/meta = null // list(boolean, boolean)
	var/created_at = null // date-time
	var/updated_at = null // date-time

/datum/apiModel/VpnCheckResource/SetupFromResponse(response)
	. = ..()
	if ("id" in response)
		src.round_id = response["id"]
	if ("round_id" in response)
		src.round_id = response["round_id"]
	if ("ip" in response)
		src.ip = response["ip"]
	if ("service" in response)
		src.service = response["service"]
	if ("response" in response)
		src.response = response["response"]
	if ("error" in response)
		src.error = response["error"]
	if ("created_at" in response)
		src.round_id = response["created_at"]
	if ("updated_at" in response)
		src.round_id = response["updated_at"]
	src.meta = response["meta"]

// No parent call, id or date fields can be null for this
/datum/apiModel/VpnCheckResource/VerifyIntegrity()
	if (
		isnull(src.meta) \
	)
		return FALSE
	return TRUE

/datum/apiModel/VpnCheckResource/ToList()
	. = ..()
	.["id"] = src.id
	.["round_id"] = src.round_id
	.["ip"] = src.ip
	.["service"] = src.service
	.["response"] = src.response
	.["error"] = src.error
	.["meta"] = src.meta
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
