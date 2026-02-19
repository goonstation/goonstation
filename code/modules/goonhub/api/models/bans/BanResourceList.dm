
/// BanList
/datum/apiModel/Paginated/BanList

/datum/apiModel/Paginated/BanList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/Ban/ban = new()
		ban.SetupFromResponse(item)
		src.data.Add(ban)
