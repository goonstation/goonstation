
/// JobBanResourceList
/datum/apiModel/Paginated/JobBanResourceList

/datum/apiModel/Paginated/JobBanResourceList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/JobBanResource/jobBan = new()
		jobBan.SetupFromResponse(item)
		src.data.Add(jobBan)
