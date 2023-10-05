
/// BanResourceList
/datum/apiModel/Paginated/BanResourceList

/datum/apiModel/Paginated/BanResourceList/setupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/list/item in response["data"])
		var/datum/apiModel/Tracked/BanResource/ban = new()
		ban.setupFromResponse(item)
		src.data.Add(ban)
