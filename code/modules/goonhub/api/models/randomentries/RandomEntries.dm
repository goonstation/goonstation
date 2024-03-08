
/// RandomEntries
/datum/apiModel/RandomEntries
	var/list/datum/apiModel/entries = list() // [Model]

/datum/apiModel/RandomEntries/SetupFromResponse(response, datum/apiRoute/route)
	. = ..()
	var/datum/apiModel/entryType
	switch(route.queryParams["type"])
		if ("tickets")
			entryType = /datum/apiModel/Tracked/EventTicketResource
		if ("fines")
			entryType = /datum/apiModel/Tracked/EventFineResource
		if ("ai_laws")
			entryType = /datum/apiModel/Tracked/EventAiLawResource
		if ("station_names")
			entryType = /datum/apiModel/Tracked/EventStationNameResource

	for (var/item in response)
		var/datum/apiModel/entry = new entryType
		entry.SetupFromResponse(item)
		src.entries.Add(entry)

/datum/apiModel/RandomEntries/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.entries) \
	)
		return FALSE

/datum/apiModel/RandomEntries/ToList()
	. = ..()
	.["entries"] = list()
	for (var/datum/apiModel/entry in src.entries)
		.["entries"] += list(entry.ToList())
