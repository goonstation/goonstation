
/// GetPlayerSaves
/datum/apiModel/GetPlayerSaves
	var/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/data	= null
	var/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/saves	= null

/datum/apiModel/Tracked/GameAdminResource/SetupFromResponse(response)
	. = ..()
	src.data = new
	src.data = src.data.SetupFromResponse(response["data"])
	src.saves = new
	src.saves = src.saves.SetupFromResponse(response["saves"])

/datum/apiModel/GetPlayerSaves/VerifyIntegrity()
	if (
		isnull(src.data) \
		|| isnull(src.saves) \
	)
		return FALSE

/datum/apiModel/GetPlayerSaves/ToString()
	. = list()
	.["data"] = src.data
	.["saves"] = src.saves
	return json_encode(.)
