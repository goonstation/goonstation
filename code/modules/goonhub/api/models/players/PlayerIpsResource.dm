
/// PlayerIpsResource
/datum/apiModel/PlayerIpsResource
	var/datum/apiModel/Tracked/PlayerRes/PlayerConnection/latest_connection = null // PlayerConnection
	var/list/ips = null // [string, integer]

/datum/apiModel/PlayerIpsResource/SetupFromResponse(response)
	. = ..()
	src.latest_connection = new
	src.latest_connection.SetupFromResponse(response["latest_connection"])
	src.ips = response["ips"]

/datum/apiModel/PlayerIpsResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.latest_connection) \
		|| isnull(src.ips)
	)
		return FALSE

/datum/apiModel/PlayerIpsResource/ToList()
	. = ..()
	.["latest_connection"] = src.latest_connection.ToList()
	.["ips"] = src.ips
