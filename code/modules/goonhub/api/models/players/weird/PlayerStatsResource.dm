
/// PlayerStatsResource
/datum/apiModel/Tracked/PlayerStatsResource
	var/ckey			= null // string
	var/key				= null // string
	var/byond_join_date	= null // string
	var/byond_major		= null // string
	var/byond_minor		= null // string
	var/played			= null // string
	var/played_rp		= null // string
	var/connected		= null // string
	var/connected_rp	= null // string
	var/time_played		= null // string
	var/datum/apiModel/Tracked/PlayerRes/PlayerConnection/latest_connection = null // PlayerConnection

/datum/apiModel/Tracked/PlayerStatsResource/New(
	id,
	ckey,
	key,
	byond_join_date,
	byond_major,
	byond_minor,
	created_at,
	updated_at,
	played,
	played_rp,
	connected,
	connected_rp,
	time_played,
	latest_connection
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
	src.played = played
	src.played_rp = played_rp
	src.connected = connected
	src.connected_rp = connected_rp
	src.time_played = time_played
	src.latest_connection = latest_connection

/datum/apiModel/Tracked/PlayerStatsResource/VerifyIntegrity()
	if (
		isnull(src.id) \
		|| isnull(src.ckey) \
		|| isnull(src.key) \
		|| isnull(src.byond_join_date) \
		|| isnull(src.byond_major) \
		|| isnull(src.byond_minor) \
		|| isnull(src.created_at) \
		|| isnull(src.updated_at) \
		|| isnull(src.played) \
		|| isnull(src.played_rp) \
		|| isnull(src.connected) \
		|| isnull(src.connected_rp) \
		|| isnull(src.time_played) \
		|| isnull(src.latest_connection) \
	)
		return FALSE

/datum/apiModel/Tracked/PlayerStatsResource/ToString()
	. = list()
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
	.["latest_connection"] = src.latest_connection
	return json_encode(.)
