
/// POST /map-switch
/// Trigger a map switch for a given server
/datum/apiRoute/mapswitch
	method = RUSTG_HTTP_METHOD_POST
	path = "/map-switch"
	body = /datum/apiBody/mapswitch
	correct_response = list(/datum/apiModel/Tracked/MapSwitch, "status")
