
/// PlayerStatsResource
/datum/apiModel/Tracked/PlayerStatsResource
	var/ckey			= null // string
	var/key				= null // string
	var/byond_join_date	= null // date
	var/byond_major		= null // integer
	var/byond_minor		= null // integer
	var/played			= null // integer
	var/played_rp		= null // integer
	var/connected		= null // integer
	var/connected_rp	= null // integer
	var/time_played		= null // integer
	var/datum/apiModel/Tracked/PlayerRes/PlayerConnection/latest_connection = null // PlayerConnection

/datum/apiModel/Tracked/PlayerStatsResource/SetupFromResponse(response)
	. = ..()
	src.ckey = response["ckey"]
	src.key = response["key"]
	src.byond_join_date = response["byond_join_date"]
	src.byond_major = response["byond_major"]
	src.byond_minor = response["byond_minor"]
	src.played = response["played"]
	src.played_rp = response["played_rp"]
	src.connected = response["connected"]
	src.connected_rp = response["connected_rp"]
	src.time_played = response["time_played"]

	if (response["latest_connection"])
		src.latest_connection = new
		src.latest_connection.SetupFromResponse(response["latest_connection"])

/datum/apiModel/Tracked/PlayerStatsResource/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.ckey)
	)
		return FALSE

/datum/apiModel/Tracked/PlayerStatsResource/ToList()
	. = ..()
	.["id"] = src.id
	.["ckey"] = src.ckey
	.["key"] = src.key
	.["byond_join_date"] = src.byond_join_date
	.["byond_major"] = src.byond_major
	.["byond_minor"] = src.byond_minor
	.["created_at"] = src.created_at
	.["updated_at"] = src.updated_at
	.["played"] = src.played
	.["played_rp"] = src.played_rp
	.["connected"] = src.connected
	.["connected_rp"] = src.connected_rp
	.["time_played"] = src.time_played
	if (src.latest_connection)
		.["latest_connection"] = src.latest_connection.ToList()
