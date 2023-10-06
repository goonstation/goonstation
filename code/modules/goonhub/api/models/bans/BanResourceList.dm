
/// BanResourceList
/datum/apiModel/Paginated/BanResourceList

/datum/apiModel/Paginated/BanResourceList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/BanResource/ban = new()
		ban.SetupFromResponse(item)
		src.data.Add(ban)
