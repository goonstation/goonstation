
/// MapSwitch
/datum/apiModel/Tracked/MapSwitch
	var/datum/apiModel/Tracked/MapSwitchInternal/map_switch	= null // Model
	var/status												= null // string

/datum/apiModel/Tracked/MapSwitch/New(
	map_switch,
	status
)
	. = ..()
	src.map_switch	= map_switch
	src.status		= status

/datum/apiModel/Tracked/MapSwitch/VerifyIntegrity()
	if (
		isnull(src.map_switch) \
		|| isnull(src.status) \
	)
		return FALSE

/datum/apiModel/Tracked/MapSwitch/ToString()
	. = list()
	.["map_switch"]	= src.map_switch
	.["status"]		= src.status
	return json_encode(.)
