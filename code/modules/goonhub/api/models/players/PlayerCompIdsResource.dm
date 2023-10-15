
/// PlayerCompIdsResource
/datum/apiModel/PlayerCompIdsResource
	var/datum/apiModel/Tracked/PlayerRes/PlayerConnection/latest_connection = null // PlayerConnection
	var/list/comp_ids = null // [string, integer]

/datum/apiModel/PlayerCompIdsResource/SetupFromResponse(response)
	. = ..()
	src.latest_connection = new
	src.latest_connection.SetupFromResponse(response["latest_connection"])
	src.comp_ids = response["comp_ids"]

/datum/apiModel/PlayerCompIdsResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.latest_connection) \
		|| isnull(src.comp_ids)
	)
		return FALSE

/datum/apiModel/PlayerCompIdsResource/ToString()
	. = list()
	.["latest_connection"] = src.latest_connection.ToString()
	.["comp_ids"] = src.comp_ids
	return json_encode(.)
