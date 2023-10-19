
/// GetPlayerSaves
/datum/apiModel/GetPlayerSaves
	var/list/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/data	= null
	var/list/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/saves	= null

/datum/apiModel/GetPlayerSaves/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/dataItem = new
		dataItem.SetupFromResponse(item)
		src.data.Add(dataItem)

	src.saves = list()
	for (var/item in response["saves"])
		var/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/save = new
		save.SetupFromResponse(item)
		src.saves.Add(save)

/datum/apiModel/GetPlayerSaves/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.data) \
		|| isnull(src.saves) \
	)
		return FALSE

/datum/apiModel/GetPlayerSaves/ToString()
	. = list()
	.["data"] = list()
	for (var/datum/apiModel/Tracked/PlayerRes/PlayerDataResource/data in src.data)
		.["data"] += data.ToString()
	.["saves"] = list()
	for (var/datum/apiModel/Tracked/PlayerRes/PlayerSaveResource/save in src.saves)
		.["saves"] += save.ToString()
	return json_encode(.)
