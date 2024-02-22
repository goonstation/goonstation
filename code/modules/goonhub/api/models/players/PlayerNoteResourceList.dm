
/// PlayerNoteResourceList
/datum/apiModel/Paginated/PlayerNoteResourceList

/datum/apiModel/Paginated/PlayerNoteResourceList/SetupFromResponse(response)
	. = ..()
	src.data = list()
	for (var/item in response["data"])
		var/datum/apiModel/Tracked/PlayerNoteResource/playerNote = new()
		playerNote.SetupFromResponse(item)
		src.data.Add(playerNote)
