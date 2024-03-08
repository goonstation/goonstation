
/// PollResourceList
/datum/apiModel/Paginated/PollResourceList

/datum/apiModel/Paginated/PollResourceList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/PollResource/poll = new()
		poll.SetupFromResponse(item)
		src.data.Add(poll)
