
/// PlayerMedalResourceList
/datum/apiModel/Paginated/PlayerMedalResourceList

/datum/apiModel/Paginated/PlayerMedalResourceList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/PlayerRes/PlayerMedalResource/playerMedal = new()
		playerMedal.SetupFromResponse(item)
		src.data.Add(playerMedal)
